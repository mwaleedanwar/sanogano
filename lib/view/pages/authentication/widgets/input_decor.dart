import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

InputDecoration inputDecoration(String hintText) {
  return InputDecoration(
    isCollapsed: false,
    isDense: true,
    errorMaxLines: 2,
    labelStyle: TextStyle(
      color: Get.theme.primaryColor.withOpacity(0.5),
    ),
    //  hintText: hintText,
    labelText: hintText,
    // contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Color(0xFF707070), width: 1.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Color(0xFF707070), width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Get.theme.primaryColor, width: 2.0),
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
  );
}
