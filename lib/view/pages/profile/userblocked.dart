import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';

class BlockedView extends StatelessWidget {
  final String blockedBy;
  final UserModel blockedUser;
  final Function unblockedCallback;
  final controller = Get.find<UserController>();

  BlockedView(
      {Key? key,
      required this.blockedBy,
      required this.blockedUser,
      required this.unblockedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        back: true,
        title: "",
        iconButton: Container(),
      ),
      body: Center(
        child: controller.userModel.id == blockedBy
            ? TextButton(
                onPressed: () {
                  print("unblocking");
                  controller.unblockUser(blockedUser.id!);
                  unblockedCallback();
                },
                child: Text(
                  "Unblock ${blockedUser.username}",
                  style: TextStyle(
                    color: standardContrastColor,
                  ),
                ))
            : Container(),
      ),
    );
  }
}
