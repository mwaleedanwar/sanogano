import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/view/global/custom_icon.dart';

import '../settings.dart';

class EditAppBar extends StatelessWidget with PreferredSizeWidget {
  VoidCallback onPressed;

  EditAppBar({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    Widget _buildSVG(String image) {
      return SvgPicture.asset(
        image,
        width: 25.0,
        height: 25.0,
        color: Colors.black,
      );
    }

    return AppBar(
      leading: InkWell(
        onTap: () {
          Get.back();
        },
        child: Container(
          child: Center(child: backIcon),
        ),
      ),
      title: Center(
        child: Text(
          "Edit Profile",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        InkWell(
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
            child: Text(
              "Done",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
