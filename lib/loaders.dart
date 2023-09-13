import 'package:flutter/material.dart';
import 'package:get/get.dart';

bool isLoading = false;
showLoading({String loadingText = "Loading.."}) async {
  isLoading = true;
  await Get.dialog(AlertDialog(
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator.adaptive(),
        SizedBox(
          width: 10,
        ),
        Text(loadingText),
      ],
    ),
  ));
  isLoading = false;
}

hideLoading() async {
  if (isLoading) {
    Get.back();
  }
  return;
}
