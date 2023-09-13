import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/activity/activityWIdget.dart';
import 'package:sano_gano/view/pages/activity/custom_scroller.dart';
import 'package:sano_gano/view/pages/activity/scroll_behavior.dart';

import '../../../controllers/activity_controller.dart';
import '../../../controllers/helpers/scroll_focus_controller_helper.dart';
import '../../../models/notificationModel.dart';

class CommentsActivityTab extends StatelessWidget {
  CommentsActivityTab({Key? key}) : super(key: key);
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
        List<DetailedNotificationModel>? commentActivity = activityController
            .detailedActivityList!
            .where((element) =>
                element.notificationModel.notificationBody!
                    .contains('commented') ||
                element.notificationModel.notificationBody!.contains('replied'))
            .toList();
        return CustomScroller(children: [
          ...List.generate(
              commentActivity.length,
              (index) => ActivityWidget(
                    notification: commentActivity[index],
                  ))
        ], scrollController: sfc.activityCommentScrollController);
      }
    });
  }
}
