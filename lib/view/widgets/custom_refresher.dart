import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sano_gano/view/global/custom_icon.dart';
import 'package:sano_gano/view/widgets/shimmer_header.dart';

import '../../controllers/theme_controller.dart';

class RefreshWidget extends StatelessWidget {
  void Function() onRefresh;
  // String textCompleted;
  // String duringRefreshing;
  // String textBeforeRefreshing;
  Widget child;
  RefreshController controller;
  RefreshWidget(
      {Key? key,
      required this.onRefresh,
      // required this.textCompleted,
      // required this.duringRefreshing,
      // required this.textBeforeRefreshing,
      required this.child,
      required this.controller})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: controller,
      enablePullDown: true,
      physics: ClampingScrollPhysics(),
      header: MaterialClassicHeader(
        color: Color(Get.find<ThemeController>().globalColor),
        backgroundColor: Colors.white,
      ),
      // header: ShimmerHeader(
      //   textCompleted: Text(
      //     textCompleted,
      //     style: TextStyle(color: Colors.grey, fontSize: 22),
      //   ),
      //   duringRefreshing: Text(
      //     duringRefreshing,
      //     style: TextStyle(color: Colors.grey, fontSize: 22),
      //   ),
      //   text: Text(
      //     textBeforeRefreshing,
      //     style: TextStyle(color: Colors.grey, fontSize: 22),
      //   ),
      // ),
      onRefresh: onRefresh,
      child: child,
    );
  }
}
