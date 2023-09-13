import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/theme_controller.dart';

class CustomIcon extends StatelessWidget {
  String image;
  double size;
  Color? color;
  double? opacity;
  CustomIcon({
    Key? key,
    required this.image,
    required this.size,
    this.color,
    this.opacity,
  }) : super(key: key);

  CustomIcon copyWith({double? size, Color? color, double? opacity}) {
    return CustomIcon(
      image: this.image,
      size: size ?? this.size,
      color: color ?? this.color,
    );
  }

  // CustomIcon(this.image, this.size, this.opacity,{this.color});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      image,
      width: size,
      height: size,
      color: color ?? Color(Get.find<ThemeController>().globalColor),
      // Get.isDarkMode ? color ?? Colors.white : color ?? globalColor,
    );
  }
}

// Color globalColor = Color(Get.find<ThemeController>().globalColor);

class CustomIconColored extends StatelessWidget {
  String image;
  double size;
  Color color;
  CustomIconColored({
    Key? key,
    required this.image,
    required this.size,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      image,
      width: size,
      height: size,
      color: color,
    );
  }
}
