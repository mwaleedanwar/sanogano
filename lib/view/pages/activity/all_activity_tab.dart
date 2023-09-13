import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/activity/activityWIdget.dart';
import 'package:sano_gano/view/pages/activity/custom_scroller.dart';

import '../../../controllers/activity_controller.dart';
import '../../../controllers/helpers/scroll_focus_controller_helper.dart';

class AllActivityTab extends StatefulWidget {
  AllActivityTab({Key? key}) : super(key: key);

  @override
  State<AllActivityTab> createState() => _AllActivityTabState();
}

class _AllActivityTabState extends State<AllActivityTab> {
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
        return CustomScroller(children: [
          ...List.generate(
              activityController.detailedActivityList!.length,
              (index) => ActivityWidget(
                    notification:
                        activityController.detailedActivityList![index],
                  )),
          if (activityController.isActivityLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Center(
                  child: CircularProgressIndicator.adaptive(
                strokeWidth: 1.5,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
              )),
            )
        ], scrollController: sfc.allActivityScrollController);
      }
    });
  }
}
