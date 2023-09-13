import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> sgDialog(
    {String? message,
    bool dismissible = true,
    VoidCallback onConfirm = goback,
    VoidCallback onCancel = goback,
    String? confirmMessage,
    bool noOptions = false}) async {
  await Get.defaultDialog(
    onWillPop: () => dismissible ? Future.value(false) : Future.value(true),
    barrierDismissible: dismissible,
    title: "Alert!",
    content: Text(message ?? "Are You Sure?"),
    confirm: noOptions
        ? SizedBox()
        : TextButton(
            onPressed: () => onConfirm(),
            child: Text(confirmMessage ?? "Delete",
                style: TextStyle(color: Colors.red))),
    cancel: noOptions
        ? SizedBox()
        : TextButton(
            onPressed: () => onCancel(),
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: !Get.isDarkMode ? Colors.black : Colors.white),
            )),
  );
  return;
}

Future<void> showColorChangingDialog() async {
  print("showing color changing dialog");
  await Get.defaultDialog(
    onWillPop: () => Future.value(false),
    barrierDismissible: false,
    titleStyle: TextStyle(fontSize: 0),
    content: Text("Restart App to See New Theme"),
  );
}

void goback() {
  Get.back();
}
