import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/activity/activityWIdget.dart';
import 'package:sano_gano/view/pages/activity/custom_scroller.dart';

import '../../../controllers/activity_controller.dart';
import '../../../controllers/helpers/scroll_focus_controller_helper.dart';
import '../../../models/notificationModel.dart';

class TagsActivityTab extends StatelessWidget {
  TagsActivityTab({Key? key}) : super(key: key);
  ActivityController activityController = Get.find<ActivityController>();
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (activityController.isLoading) {
        return Center(
            child: CircularProgressIndicator.adaptive(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
        ));
      }
      if (activityController.detailedActivityList!.isEmpty) {
        return Center(child: SizedBox.shrink());
      } else {
        List<DetailedNotificationModel>? tagsActivity = activityController
            .detailedActivityList!
            .where((element) =>
                element.notificationModel.notificationBody!.contains('tagged'))
            .toList();
        List<DetailedNotificationModel>? postActivity = tagsActivity
            .where((element) =>
                element.notificationModel.notificationBody!.contains('post'))
            .toList();
        List<DetailedNotificationModel>? replyActivity = tagsActivity
            .where((element) =>
                element.notificationModel.notificationBody!.contains('reply'))
            .toList();
        List<DetailedNotificationModel>? commentActivity = tagsActivity
            .where((element) =>
                element.notificationModel.notificationBody!.contains('comment'))
            .toList();
        postActivity.sort((a, b) => b.notificationModel.timestamp!
            .compareTo(a.notificationModel.timestamp!));
        return CustomScroller(children: [
          // postActivity.isNotEmpty
          //     ? Container(
          //         color: Colors.grey[200],
          //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          //         child: Text("Post",
          //             style:
          //                 TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          //       )
          //     : SizedBox(),
          ...List.generate(
              postActivity.length,
              (index) => ActivityWidget(
                    notification: postActivity[index],
                  )),
          // commentActivity.isNotEmpty
          //     ? Container(
          //         color: Colors.grey[200],
          //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          //         child: Text("Comment",
          //             style:
          //                 TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          //       )
          //     : SizedBox(),
          ...List.generate(
              commentActivity.length,
              (index) => ActivityWidget(
                    notification: commentActivity[index],
                  )),
          // replyActivity.isNotEmpty
          //     ? Container(
          //         color: Colors.grey[200],
          //         padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          //         child: Text("Reply",
          //             style:
          //                 TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          //       )
          //     : SizedBox(),
          ...List.generate(
              replyActivity.length,
              (index) => ActivityWidget(
                    notification: replyActivity[index],
                  )),
        ], scrollController: sfc.activityTaggedScrollController);

        // return Scaffold(
        //   // appBar: PreferredSize(
        //   //     child: Column(
        //   //       children: [
        //   //         SizedBox(
        //   //           height: 10,
        //   //         ),
        //   //         // TabBar(
        //   //         //     controller: sfc.tagsTabController,
        //   //         //     isScrollable: false,
        //   //         //     // labelPadding: EdgeInsets.zero,
        //   //         //     labelStyle:
        //   //         //         TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        //   //         //     indicatorColor:
        //   //         //         Get.isDarkMode ? Colors.white : Colors.black,
        //   //         //     unselectedLabelStyle: TextStyle(
        //   //         //         fontWeight: FontWeight.normal, fontSize: 12),
        //   //         //     labelColor: Get.isDarkMode ? Colors.white : Colors.black,
        //   //         //     // padding: EdgeInsets.zero,
        //   //         //     tabs: [
        //   //         //       Tab(
        //   //         //         height: 30,
        //   //         //         text: "Post",
        //   //         //       ),
        //   //         //       Tab(
        //   //         //         height: 30,
        //   //         //         text: "Comment",
        //   //         //       ),
        //   //         //       Tab(
        //   //         //         height: 30,
        //   //         //         text: "Reply",
        //   //         //       ),
        //   //         //     ]),
        //   //       ],
        //   //     ),
        //   //     preferredSize: Size(Get.width, 50)),
        //   body: TabBarView(controller: sfc.tagsTabController, children: [
        //     TagsPostTab(
        //         postActivity: tagsActivity
        //             .where((element) => element
        //                 .notificationModel.notificationBody!
        //                 .contains('post'))
        //             .toList()),
        //     TagsCommentTab(
        //         commentsActivity: tagsActivity
        //             .where((element) => element
        //                 .notificationModel.notificationBody!
        //                 .contains('comment'))
        //             .toList()),
        //     TagsPostTab(
        //         postActivity: tagsActivity
        //             .where((element) => element
        //                 .notificationModel.notificationBody!
        //                 .contains('reply'))
        //             .toList())
        //   ]),
        // );
        // return CustomScroller(children: [
        //   ...List.generate(
        //       tagsActivity.length,
        //       (index) => ActivityWidget(
        //             notifcation: tagsActivity[index],
        //           ))
        // ], scrollController: sfc.activityTaggedScrollController);
      }
    });
  }
}
