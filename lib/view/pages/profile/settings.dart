import 'package:flutter/material.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/utils/auth_wrapper.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/authentication/forgot_password.dart';
import 'package:sano_gano/view/pages/profile/about_page.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:url_launcher/url_launcher.dart';

import 'privacy_screen.dart';
import 'settingsPages/notification_settings_screen.dart';

class SettingsPage extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    Widget _buildTitle(String title) {
      return Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Container(
            child: Center(child: backIcon),
          ),
        ),
        centerTitle: true,
        title: _buildTitle("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ListTile(
              leading: editProfileDIcon.copyWith(size: 30),
              title: _buildTitle("Edit Profile"),
              onTap: () {
                //Get.put<EditProfileController>(EditProfileController());
                Get.to(() => EditProfilePage());
              },
            ),
            // ListTile(
            //   leading: inviteFriendsIcon.copyWith(size: 30),
            //   title: _buildTitle("Invite Friends"),
            //   onTap: () {
            //     Clipboard.setData(ClipboardData(text: "www.sanogano.com"))
            //         .whenComplete(() {
            //       Get.snackbar('Alert', 'Text copied to clipboard');
            //     });
            //   },
            // ),
            ListTile(
              leading: notificationsDIcon.copyWith(size: 30),
              title: _buildTitle("Notifications"),
              onTap: () {
                Get.to(() => NotificationSettingsScreen());
              },
            ),
            ListTile(
              leading: passwordDIcon.copyWith(size: 30),
              title: _buildTitle("Password"),
              onTap: () {
                Get.to(() => ForgotPasswordPage(
                      changePasswordMode: true,
                    ));
              },
            ),
            ListTile(
              leading: privacyDIcon.copyWith(size: 30),
              title: _buildTitle("Privacy"),
              onTap: () {
                Get.to(() => PrivacyScreen());
              },
            ),
            // ListTile(
            //   leading: qRCodeDIcon.copyWith(size: 30),
            //   title: _buildTitle("QR Code"),
            //   onTap: () {
            //     Get.put<QRController>(QRController());
            //     Get.to(() => QRScanPage());
            //   },
            // ),
            ListTile(
              leading: helpDIcon.copyWith(size: 30),
              title: _buildTitle("Support"),
              onTap: () {
                launch("https://www.sanogano.com/support");
              },
            ),
            ListTile(
              leading: aboutDIcon.copyWith(size: 30),
              title: _buildTitle("About"),
              onTap: () {
                Get.to(() => AboutPage());
              },
            ),
            ListTile(
              leading: logOutIcon.copyWith(size: 30),
              title: _buildTitle("Log Out"),
              onTap: () {
                Get.defaultDialog(
                    title: Get.find<UserController>().userModel.username!,
                    barrierDismissible: false,
                    textConfirm: "Log Out",
                    buttonColor: Colors.transparent,
                    confirmTextColor: Colors.red,
                    cancelTextColor:
                        Get.isDarkMode ? Colors.white : Colors.black,
                    textCancel: "Cancel",
                    content: Text("Log Out of SanoGano?"),
                    onConfirm: () async {
                      await Get.find<UserController>()
                          .chatClient
                          .disconnectUser(flushChatPersistence: true);
                      Get.find<UserController>().clear();
                      controller.signOut();

                      Get.offAll(() => AuthWrapper());
                    });
              },
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
