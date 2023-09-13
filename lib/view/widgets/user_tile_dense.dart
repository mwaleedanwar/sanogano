import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class DenseUserTile extends StatelessWidget {
  final UserModel user;

  DenseUserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        title: Text(
          user.username!,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: UserAvatar(
          user.id!,
          radius: 20,
        ),
      ),
    );
  }
}

class DenseUserTag extends StatelessWidget {
  final UserModel? user;
  final bool disableTap;

  const DenseUserTag({this.user, this.disableTap = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (disableTap) return;
        String currentUid = Get.find<AuthController>().user!.uid;
        user!.id == currentUid
            ? Get.to(
                ProfilePage(
                  userID: currentUid,
                  hideBack: true,
                ),
              )
            : Get.to(() => ProfilePage(userID: user!.id!));
      },
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              user!.id,
              radius: 12,
              isdisabledTap: disableTap,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              user!.username!,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
