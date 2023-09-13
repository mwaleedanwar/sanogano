import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';

import 'blocked_users_screen.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  _PrivacyScreenState createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  var isPrivate = false;
  var userController = Get.find<UserController>();

  var showStories = false;

  var touchIDEnabled = false;
  @override
  void initState() {
    super.initState();
    isPrivate = userController.userModel.isPrivate!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Privacy",
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            onTap: () => Get.to(() => BlockedUsersScreen()),
            title: Text(
              "Blocked Accounts",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: forwardDIcon,
          ),
        ],
      ),
    );
  }
}
