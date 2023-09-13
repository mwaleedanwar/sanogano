import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/pages/activity/all_activity_tab.dart';
import 'package:sano_gano/view/pages/activity/comments_activity.dart';
import 'package:sano_gano/view/pages/activity/followed_activity.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/leaderboard.dart';
import 'package:sano_gano/view/pages/activity/like_activity.dart';
import 'package:sano_gano/view/pages/activity/tags_activity.dart';
import 'package:sano_gano/view/pages/activity/trending_screen.dart';

import '../../../controllers/activity_controller.dart';

class ActivityPage extends GetWidget<ActivityController> {
  final cUID = Get.find<UserController>().currentUid;
  ActivityController activityController = Get.find<ActivityController>();
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //TODO remove trending
          leading: InkWell(
            onTap: () {
              Get.to(() => TrendingPosts());
            },
            child: Container(
              child: Center(child: trendingIcon.copyWith(size: 23)),
            ),
          ),
          title: Center(
            child: InkWell(
              onTap: () => sfc.animateAllActivityControllersToTopOfPage(),
              child: Text(
                "Activity",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          elevation: 0,
          actions: [
            InkWell(
              onTap: () {
                Get.to(() => LeaderBoardPage());
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                child: leaderboardIcon.copyWith(size: 23),
              ),
            )
          ],
          bottom: PreferredSize(
              preferredSize: Size(Get.width, 30),
              child: TabBar(
                onTap: (index) {
                  handleScrolls(index);
                },
                controller: sfc.activityTabController,
                isScrollable: false,
                labelPadding: EdgeInsets.zero,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                indicatorColor: Get.isDarkMode ? Colors.white : Colors.black,
                unselectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
                labelColor: Get.isDarkMode ? Colors.white : Colors.black,
                padding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    height: 30,
                    text: "All",
                  ),
                  Tab(
                    height: 30,
                    text: "Followers",
                  ),
                  Tab(
                    height: 30,
                    text: "Likes",
                  ),
                  Tab(
                    height: 30,
                    text: "Comments",
                  ),
                  Tab(
                    height: 30,
                    text: "Tags",
                  )
                ],
              )),
        ),
        body: TabBarView(controller: sfc.activityTabController, children: [
          AllActivityTab(),
          FollowersActivityTab(),
          LikesActivityTab(),
          CommentsActivityTab(),
          TagsActivityTab()
        ]));
  }

  void handleScrolls(int index) {
    switch (index) {
      case 0:
        sfc.animateControllerToStartOfPage(sfc.allActivityScrollController);
        break;
      case 1:
        sfc.animateControllerToStartOfPage(sfc.activityFollowScrollController);
        break;
      case 2:
        sfc.animateControllerToStartOfPage(sfc.activityLikesScrollController);
        break;
      case 3:
        sfc.animateControllerToStartOfPage(sfc.activityCommentScrollController);
        break;
      case 4:
        sfc.animateControllerToStartOfPage(sfc.activityTaggedScrollController);
        break;
      default:
    }
  }
}
