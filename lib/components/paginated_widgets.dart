import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/view/widgets/custom_widgets/custom_paginate_firestore.dart';

Widget buildPaginatedGrid<T>(
    Query query,
    Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)
        itemBuilder,
    {String emptyText = "",
    ScrollController? scrollController,
    bool reverse = false,
    double? fontSize}) {
  // return PaginationView<T>(
  //   physics: BouncingScrollPhysics(),

  //   key: key,
  //   preloadedItems: Get.find<UserController>()
  //       .cacheManager
  //       .getData(storageKey)
  //       .map((e) => null),

  //   paginationViewType: PaginationViewType.gridView,
  //   itemBuilder: (BuildContext context, PostModel postModel, int index) {
  //     return PostWidget(
  //       postModel: postModel,
  //     );
  //   },

  //   pageFetch: pageFetch,
  //   onError: (dynamic error) => Center(
  //     child: Text('Something went wrong.'),
  //   ),
  //   onEmpty: Center(
  //     child: Container(
  //         //  child: Text("On Empty"),
  //         ),
  //   ),
  //   bottomLoader: Container(
  //     height: Get.height * 0.2,
  //     child: Center(
  //       child: CircularProgressIndicator.adaptive(),
  //     ),
  //   ),
  //   initialLoader: Container(
  //       //  child: Text("initial Loader"),
  //       ),

  //   //  ListView.builder(
  //   //   itemCount: 3,
  //   //   itemBuilder: (BuildContext context, int index) {
  //   //     return PostShimmer();
  //   //   },
  //   // ),
  // );
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();
  return CustomPaginateFirestore(
      physics: BouncingScrollPhysics(),
      scrollController: scrollController ?? sfc.healthPageScrollController,
      initialLoader: SizedBox(),
      reverse: reverse,
      isLive: true,
      onEmpty: Center(
        child: Text(emptyText),
      ),
      itemBuilder: itemBuilder,
      query: query,
      itemBuilderType: PaginateBuilderType.gridView,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.90,
          mainAxisSpacing: 5,
          crossAxisSpacing: 5,
          mainAxisExtent: Get.width * 0.3 +
              5 +
              (fontSize ?? 16) * 2.5), //33 is offset idk if correct
      shrinkWrap: true);
}
