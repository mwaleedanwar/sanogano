import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

Future<void> showDmDeletionDialog(Channel channel) async {
  Get.defaultDialog(
    title: "Alert!",
    titlePadding: EdgeInsets.fromLTRB(30, 12.5, 30, 5),
    content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Text(
          "Delete this chat?",
          textAlign: TextAlign.center,
        )),
    actions: [
      TextButton(
        child: Text(
          "Cancel",
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      TextButton(
        child: Text(
          "Delete",
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () async {
          await channel.delete();
          Get.back();
        },
      ),
    ],
  );
}

Future<void> showGroupDeletionDialog(Channel channel) async {
  Get.defaultDialog(
    title: "Alert!",
    titlePadding: EdgeInsets.fromLTRB(30, 12.5, 30, 5),
    content: Text(
      "Leave this group?",
      textAlign: TextAlign.center,
    ),
    actions: [
      TextButton(
        child: Text(
          "Cancel",
          style: TextStyle(color: Colors.black),
        ),
        onPressed: () {
          Get.back();
        },
      ),
      TextButton(
        child: Text(
          "Leave",
          style: TextStyle(color: Colors.red),
        ),
        onPressed: () async {
          await channel
              .removeMembers([Get.find<UserController>().userModel.id!]);
          Get.back();
        },
      ),
    ],
  );
}
