import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/view/global/custom_icon.dart';

class CustomAppbar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final Widget trailingActionButton;

  CustomAppbar({required this.title, required this.trailingActionButton});

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
      elevation: 0.0,
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
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      actions: [
        trailingActionButton,
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
