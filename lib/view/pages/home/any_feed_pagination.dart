import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/view/pages/home/show_ad.dart';
import 'package:sano_gano/view/pages/home/trending_posts_controller.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';
import 'package:stream_feed/stream_feed.dart';

import '../../../controllers/theme_controller.dart';

class AnyFeedPagination extends StatelessWidget {
  final FlatFeed feed;
  final Filter? feedFilter;
  final String? ranking;
  final bool Function(PostModel)? restrictLoadIfTrue;

  const AnyFeedPagination(
      {Key? key,
      required this.feed,
      this.ranking,
      this.feedFilter,
      this.restrictLoadIfTrue})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetX<TrendingPostsController>(
        init: TrendingPostsController(
            feed: feed,
            ranking: ranking,
            feedFilter: feedFilter,
            restrictLoadIfTrue: restrictLoadIfTrue),
        builder: (controller) {
          return controller.allPosts!.isEmpty
              ? buildInitialTimeline()
              : RefreshIndicator(
                  color: Color(Get.find<ThemeController>().globalColor),
                  onRefresh: () async => await controller.onRefresh(),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (notification) {
                      notification.disallowIndicator();
                      return true;
                    },
                    child: SingleChildScrollView(
                      controller: controller.scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),
                              itemBuilder: (context, i) {
                                //  log("building $i ${allPosts[i].postCaption}");
                                if (i % 10 == 0 && i != 0) {
                                  return Column(
                                    children: [
                                      ShowAd(
                                        index: i,
                                        adScreen: AdScreen.home,
                                      ), // inappropriate name
                                      PostWidget(
                                        key:
                                            Key(controller.allPosts![i].postId),
                                        postModel: controller.allPosts![i],
                                        postId: controller.allPosts![i].postId,
                                      )
                                    ],
                                  );
                                }
                                return PostWidget(
                                  key: Key(controller.allPosts![i].postId),
                                  postModel: controller.allPosts![i],
                                  postId: controller.allPosts![i].postId,
                                );
                              },
                              itemCount: controller.allPosts!.length),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }

  Widget buildInitialTimeline() {
    print("building initial timeline with no loaded posts");
    return Container();
  }
}
