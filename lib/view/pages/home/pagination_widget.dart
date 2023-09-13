import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/local_database.dart';
import 'package:sano_gano/view/pages/home/show_ad.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';
import 'package:stream_feed/stream_feed.dart';

import '../../../controllers/theme_controller.dart';
import '../../../controllers/user_controller.dart';

class PaginatedTimeline extends StatefulWidget {
  final ScrollController scrollController;

  const PaginatedTimeline({Key? key, required this.scrollController})
      : super(key: key);

  @override
  State<PaginatedTimeline> createState() => _PaginatedTimelineState();
}

class _PaginatedTimelineState extends State<PaginatedTimeline>
    with SingleTickerProviderStateMixin {
  ScrollController get _scrollController => widget.scrollController;
  var sfc = Get.put(StreamFeedController());
  var uc = Get.find<UserController>();
  List<List<String>> followingIdsChunks = [];

  int count = 1;

  bool response = true;

  bool loadingFirstTime = true;
  var refreshing = false;
  Future<void> onRefresh() async {
    try {
      refreshing = true;
      setState(() {});
      _scrollController.animateTo(0,
          duration: Duration(seconds: 1), curve: Curves.linear);
      await getNewsFeed();
      refreshing = false;
      setState(() {});
      return;
    } catch (e) {
      print(e);
    }
  }

  var postCount = 0;
  var loadingMore = false;
  @override
  initState() {
    sfc.timelineFeed!.subscribe((message) {
      if (message == null || message.newActivities == null) return;
      var newPersonal = message.newActivities!.firstWhere((element) =>
          PostModel.fromActivity(activityEnriched: element).ownerId ==
          uc.currentUid);
      allPosts.insert(0, PostModel.fromActivity(activityEnriched: newPersonal));
      setState(() {});
    });
    _scrollController.addListener(() async {
      if (_scrollController.offset >=
              _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        try {
          loadingMore = true;
          setState(() {});
          count++;
          List<PostModel> posts = [];
          // if (sc.getIDLT(sc.paginated!.next!) == null) return [];
          var p = await sfc.timelineFeed!.getPaginatedEnrichedActivities(
            limit: 20, ranking: 'time', offset: postCount,
            flags: EnrichmentFlags().withRecentReactions().withReactionCounts(),

            // filter: Filter().idLessThan(sc.getIDLT(sc.paginated!.next!)!),
          );
          sfc.paginated = p;

          posts = p.results!
              .map((e) => PostModel.fromActivity(activityEnriched: e))
              .toList();
          allPosts.addAll(posts);
          postCount = allPosts.length;
          loadingMore = false;
          setState(() {});
        } catch (e) {
          print(e);
        }
        //at bottom
      }
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {
        //at top
      }
    });
    Future.delayed(Duration(seconds: 0), () async {
      try {
        await getNewsFeed();
      } catch (e) {
        print(e);
      }
    });
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  var allPosts = <PostModel>[];
  Future<void> getNewsFeed() async {
    try {
      // await _followingFollowerProvider.followingFollowersCount();
      // await _followingFollowerProvider.getFollowings();
      allPosts = (await sfc.timelineFeed!
              .getPaginatedEnrichedActivities(limit: 20, offset: 0))
          .results!
          .map((e) => PostModel.fromActivity(activityEnriched: e))
          .toList();
      await LocalDatabase().addToPostCache(
          allPosts.map((e) => e.postId).toList(),
          Get.find<AuthController>().user!.uid);
      postCount = allPosts.length;
      var pc = 0;
      for (var element in allPosts) {
        // log("$pc" + element.postCaption.toString());
        pc++;
      }
      setState(() {});
    } catch (e) {
      throw e;
    } finally {
      setState(() => loadingFirstTime = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return allPosts.isEmpty || refreshing
        ? buildInitialTimeline()
        : RefreshIndicator(
            color: Color(Get.find<ThemeController>().globalColor),
            onRefresh: () async => await onRefresh(),
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        itemBuilder: (context, i) {
                          //show container after 5 posts
                          if (i % 10 == 0 && i != 0) {
                            return Column(
                              children: [
                                ShowAd(
                                  index: i,
                                  adScreen: AdScreen.home,
                                ), // inappropriate name
                                PostWidget(
                                  key: Key(allPosts[i].postId),
                                  postModel: allPosts[i],
                                  postId: allPosts[i].postId,
                                )
                              ],
                            );
                          }
                          return PostWidget(
                            key: Key(allPosts[i].postId),
                            postModel: allPosts[i],
                            postId: allPosts[i].postId,
                          );
                        },
                        itemCount: allPosts.length),
                    //
                    if (allPosts.length > 0 && loadingMore)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color:
                                Color(Get.find<ThemeController>().globalColor),
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget buildInitialTimeline() {
    print("building initial timeline with no loaded posts");
    String uid = Get.find<AuthController>().user!.uid;
    return FutureBuilder(
        future: Hive.openBox(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          var posts = Hive.box(uid).values;
          print(posts);
          return ListView.builder(
            shrinkWrap: true,
            itemCount: posts.length,
            itemBuilder: (BuildContext context, int index) {
              return PostWidget(postId: posts.elementAt(index));
            },
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
