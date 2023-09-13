import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/activity/activityWIdget.dart';
import 'package:sano_gano/view/pages/activity/custom_scroller.dart';

import '../../../controllers/activity_controller.dart';
import '../../../controllers/helpers/scroll_focus_controller_helper.dart';
import '../../../models/notificationModel.dart';

class LikesActivityTab extends StatelessWidget {
  LikesActivityTab({Key? key}) : super(key: key);
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
        List<DetailedNotificationModel>? likesActivity = activityController
            .detailedActivityList!
            .where((element) =>
                element.notificationModel.notificationBody!.contains('liked'))
            .toList();
        return CustomScroller(children: [
          ...List.generate(
              likesActivity.length,
              (index) => ActivityWidget(
                    notification: likesActivity[index],
                  ))
        ], scrollController: sfc.activityLikesScrollController);
      }
    });
  }
}
