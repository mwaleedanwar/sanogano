import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'custom_icon.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  String? title;
  bool back;
  Widget? iconButton;
  bool? centerTitle;
  PreferredSizeWidget? bottom;
  Widget? leading;
  VoidCallback? onTapTitle;
  bool multiline;

  CustomAppBar(
      {required this.back,
      this.title,
      this.iconButton,
      this.leading,
      this.centerTitle = true,
      this.onTapTitle,
      this.multiline = false,
      this.bottom});

  @override
  Widget build(BuildContext context) {
    iconButton = iconButton ?? Container();
    return AppBar(
      elevation: 0,
      leading: back
          ? InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                child: Center(child: backDIcon),
              ),
            )
          : leading ??
              Container(
                width: 20,
                height: 20,
              ),
      title: InkWell(
        onTap: onTapTitle,
        child: Text(
          title ?? "",
          maxLines: multiline ? 2 : 1,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: multiline ? 16 : 20,
              fontWeight: FontWeight.bold,
              color: Get.textTheme.bodyText1!.color),
        ),
      ),
      actions: [
        iconButton!,
      ],
      bottom: bottom,
      centerTitle: centerTitle,
      //backgroundColor: Colors.white,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
