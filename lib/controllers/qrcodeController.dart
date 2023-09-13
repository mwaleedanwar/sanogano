import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';

class QRController extends GetxController {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  UserModel? scannedUser = UserModel();
  var usercontroller = Get.find<UserController>();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getPermissions();
  }

  bool hasCameraPermission = false;
  getPermissions() async {
    await Permission.camera.request().then((value) {
      if (value.isGranted) {
        hasCameraPermission = true;
      }
    });

    update();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Widget qrCodeFromUID({double? size}) {
    return QrImage(
      data: usercontroller.userModel.id!,
      version: 3, //QrVersions.auto,
      // embeddedImage: AssetImage("assets/app_icon.png"),
      size: size ?? 300.0,
      foregroundColor: Colors.black, //messageColor,
    );
  }
}
