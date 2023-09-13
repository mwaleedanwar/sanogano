import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/activity_controller.dart';
import 'package:sano_gano/view/pages/activity/scroll_behavior.dart';

import '../../../controllers/helpers/scroll_focus_controller_helper.dart';

class CustomScroller extends StatefulWidget {
  final List<Widget> children;
  final ScrollController scrollController;
  CustomScroller(
      {Key? key, required this.children, required this.scrollController})
      : super(key: key);

  @override
  State<CustomScroller> createState() => _CustomScrollerState();
}

class _CustomScrollerState extends State<CustomScroller> {
  ActivityController activityController = Get.find<ActivityController>();

  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();

  @override
  void initState() {
    widget.scrollController.addListener(() {
      print("All Activity Scroll Controller Listener");
      if (widget.scrollController.position.pixels ==
          widget.scrollController.position.maxScrollExtent) {
        if (activityController.hasMore) {
          print("fetching activities");

          activityController.fetchActivities();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => activityController.refreshActivity(),
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      color: Theme.of(context).primaryColor,
      child: ScrollConfiguration(
        behavior: NoGlowScrollAnimation(),
        child: ListView(
          controller: widget.scrollController,
          physics: AlwaysScrollableScrollPhysics(),
          children: widget.children,
        ),
      ),
    );
  }
}
