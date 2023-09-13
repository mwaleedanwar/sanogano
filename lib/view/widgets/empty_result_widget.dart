import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmptyResultWidget extends StatelessWidget {
  final Widget onEmptyWidget;
  final Widget onDataWidget;
  final Query query;

  const EmptyResultWidget(
      {Key? key,
      this.onEmptyWidget = emptyWidget,
      required this.query,
      required this.onDataWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData)
          return Center(
            child: CircularProgressIndicator.adaptive(),
          );
        if (snapshot.data!.docs.isEmpty)
          return Container(
              height: Get.height, width: Get.width, child: onEmptyWidget);
        return onDataWidget;
      },
    );
  }
}

const Widget emptyWidget = const Center(
  child: const Text("Empty"),
);
