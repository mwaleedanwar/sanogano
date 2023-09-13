import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    as refresher;
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/home/show_ad.dart';
import 'package:sano_gano/view/widgets/custom_refresher.dart';

import '../../controllers/theme_controller.dart';
import 'comments_page.dart';
import 'post_widget.dart';

class HashtagsScreen extends StatefulWidget {
  final String hashtag;
  final SortMode? sortMode;

  const HashtagsScreen({required this.hashtag, this.sortMode});

  @override
  _HashtagsScreenState createState() => _HashtagsScreenState();
}

class _HashtagsScreenState extends State<HashtagsScreen> {
  var sortMode = SortMode.new_to_old;
  @override
  void initState() {
    sortMode = widget.sortMode ?? SortMode.new_to_old;
    print(sortMode);
    print(widget.sortMode);
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    super.dispose();
  }

  var db = Database();
  Query get query {
    switch (sortMode) {
      case SortMode.most_liked:
        return db.postsCollection
            .where('hashtags', arrayContains: widget.hashtag)
            .orderBy('likeCount', descending: true);

      case SortMode.new_to_old:
        return db.postsCollection
            .where('hashtags', arrayContains: widget.hashtag)
            .orderBy('timestamp', descending: true);

      case SortMode.old_to_new: //Trending
        return db.postsCollection
            .where('hashtags', arrayContains: widget.hashtag)
            .where('timestamp',
                isGreaterThanOrEqualTo: DateTime.now()
                    .subtract(Duration(days: 1))
                    .millisecondsSinceEpoch)
            .orderBy('timestamp', descending: false)
            .orderBy('likeCount', descending: true);

      default:
        return db.postsCollection
            .where('hashtags', arrayContains: widget.hashtag)
            .orderBy('timestamp', descending: true);
    }
  }

  sort(SortMode _sortMode) {
    sortMode = _sortMode;
    setState(() {});
  }

  refresher.RefreshController _refreshController =
      refresher.RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    log("vieweing screen for hashtag ${widget.hashtag}");

    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: widget.hashtag,
        iconButton: PopupMenuButton<SortMode>(
          icon: sortDIcon,
          onSelected: (value) => sort(value),
          itemBuilder: (context) => [
            PopupMenuItem<SortMode>(
              value: SortMode.most_liked,
              child: Text("Most Liked"),
              textStyle: sortMode == SortMode.most_liked
                  ? TextStyle(
                      color: Color(Get.find<ThemeController>().globalColor),
                      fontWeight: FontWeight.bold,
                      fontSize: 16)
                  : null,
            ),
            PopupMenuItem<SortMode>(
              value: SortMode.new_to_old,
              child: Text("Most Recent"),
              textStyle: sortMode == SortMode.new_to_old
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(Get.find<ThemeController>().globalColor))
                  : null,
            ),
            PopupMenuItem<SortMode>(
              value: SortMode.old_to_new, // add trending type
              child: Text("Trending"),
              textStyle: sortMode == SortMode.old_to_new
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(Get.find<ThemeController>().globalColor))
                  : null,
            ),
          ],
        ),
      ),
      body: StreamBuilder<SortMode>(
          stream: Stream.value(sortMode),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            }

            return RefreshWidget(
                onRefresh: () async {
                  await 1.25.seconds.delay();
                  setState(() {});
                },
                child: PaginateFirestore(
                  physics: ClampingScrollPhysics(),
                  onEmpty: Center(
                    child: Container(),
                  ),
                  shrinkWrap: true,
                  //item builder type is compulsory.
                  itemBuilder: (_, docs, index) {
                    Map<String, dynamic> data =
                        docs[index].data() as Map<String, dynamic>;
                    var post = PostModel.fromMap(data);
                    if (index != 0 && index % 10 == 0) {
                      return Column(
                        children: [
                          ShowAd(
                            index: index,
                            adScreen: AdScreen.hashtag,
                          ),
                          PostWidget(
                            postModel: post,
                            postId: post.postId,
                          )
                        ],
                      );
                    }
                    return PostWidget(
                      postModel: post,
                      postId: post.postId,
                    );
                  },
                  // orderBy is compulsory to enable pagination
                  query: query,
                  //Change types accordingly
                  itemBuilderType: PaginateBuilderType.listView,
                  // to fetch real-time data
                  isLive: true,
                  // sortByField: (a, b) {
                  //   int.tryParse((a.get('likeCount') ?? 0).toString()).compareTo(
                  //       int.tryParse((b.get('likeCount') ?? 0).toString()));
                  // },
                ),
                controller: _refreshController);
          }),
    );
  }

  // int page = 0;
  // Future<List<PostModel>> pageFetch(int offset) async {
  //   List<PostModel> posts = [];
  //   print(offset);
  //   page = (offset / 10).round();
  //   QuerySnapshot<Object> docs;
  //    switch (sortMode) {
  //     case SortMode.most_liked:
  //        db.postsCollection
  //           .where('hashtags', arrayContains: widget.hashtag)
  //           .orderBy('likeCount', descending: true);

  //       break;
  //     case SortMode.new_to_old:
  //        db.postsCollection
  //           .where('hashtags', arrayContains: widget.hashtag)
  //           .orderBy('timestamp', descending: true);

  //       break;
  //     case SortMode.old_to_new: //Trending
  //        db.postsCollection
  //           .where('hashtags', arrayContains: widget.hashtag)
  //           .where('timestamp',
  //               isGreaterThanOrEqualTo: DateTime.now()
  //                   .subtract(Duration(days: 1))
  //                   .millisecondsSinceEpoch)
  //           .orderBy('timestamp', descending: false)
  //           .orderBy('likeCount', descending: true);

  //       break;
  //     default:
  //        db.postsCollection
  //           .where('hashtags', arrayContains: widget.hashtag)
  //           .orderBy('timestamp', descending: true);
  //   }
  //   return posts;
  // }
}
