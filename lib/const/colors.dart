import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeColor {
  Color getColor(int index) {
    if (index == 1)
      return Get.isDarkMode ? Colors.white : Colors.black;
    else if (index == 2)
      return Color(0xFF007596);
    else if (index == 3)
      return Color(0xFF42528D);
    else if (index == 4)
      return Color(0xFF943E3D);
    else if (index == 5) return Color(0xFFAC6434);
    return Get.isDarkMode ? Colors.white : Colors.black;
  }

  Color getLeaderBoardColor(int index) {
    switch (index) {
      case 1:
        {
          return Color(0xFFB8F2FF);
        }
        break;

      case 2:
        {
          return Color(0xFF79A7A4);
        }
        break;

      case 3:
        {
          return Color(0xFFFFD700);
        }
        break;

      case 4:
        {
          return Color(0xFFC0C0C0);
        }
        break;

      case 5:
        {
          return Color(0xFFCD7F32);
        }
        break;

      default:
        {
          return Get.isDarkMode ? Colors.white : Colors.black;
        }
        break;
    }
  }
}
