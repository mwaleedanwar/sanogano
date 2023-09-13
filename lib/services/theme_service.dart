// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:sano_gano/const/theme.dart';
// import 'package:sano_gano/view/global/custom_icon.dart';

// class ThemeService {
//   final _box = GetStorage();
//   bool isDarkMode = false;
//   // ThemeService();
//   Future<void> init() async {
//     print("=============");
//     print("initializing theme ");
//     print(_box.read("color"));

//     isDarkMode = _box.read<bool>("darkMode") ?? false;
//     var defaultColour = isDarkMode ? 0xFFFFFFFF : 0xFF000000;
//     globalColor = Color(_box.read("color") ?? defaultColour);

//     print(globalColor.value);
//     print("&&&&&&&&&&");
//     print(isDarkMode);
//   }

//   // ThemeData get theme => getTheme(_box.read("theme"));

//   // ThemeData getTheme(int? index) {
//   //   print(index ?? "");

//   //   switch (index) {
//   //     case 1:
//   //       {
//   //         return blackTheme;
//   //       }

//   //     case 2:
//   //       {
//   //         return greenTheme;
//   //       }

//   //     case 3:
//   //       {
//   //         return lightTheme;
//   //       }

//   //     case 4:
//   //       {
//   //         return redTheme;
//   //       }

//   //     case 5:
//   //       {
//   //         return goldenTheme;
//   //       }

//   //     default:
//   //       {
//   //         return lightTheme;
//   //       }
//   //   }
//   // }

//   // var themes = [
//   //   blackTheme,
//   //   greenTheme,
//   //   lightTheme,
//   //   redTheme,
//   //   goldenTheme,
//   // ];
//   // void setTheme(int index) {
//   //   if (index <= themes.length - 1) globalColor = themes[index].primaryColor;

//   //   switch (index) {
//   //     case 1:
//   //       {
//   //         if (Get.isDarkMode) {
//   //           Get.changeThemeMode(ThemeMode.light);
//   //         } else {
//   //           Get.changeThemeMode(ThemeMode.dark);
//   //         }

//   //         print("theme changed");
//   //       }
//   //       break;

//   //     // case 2:
//   //     //   {
//   //     //     Get.changeTheme(greenTheme);
//   //     //     print("theme changed");
//   //     //   }
//   //     //   break;

//   //     // case 3:
//   //     //   {
//   //     //     Get.changeTheme(lightTheme);
//   //     //     print("theme changed");
//   //     //   }
//   //     //   break;

//   //     // case 4:
//   //     //   {
//   //     //     Get.changeTheme(redTheme);
//   //     //     print("theme changed");
//   //     //   }
//   //     //   break;

//   //     // case 5:
//   //     //   {
//   //     //     Get.changeThemeMode(ThemeMode.light);
//   //     //     Get.changeTheme(goldenTheme);
//   //     //     print("theme changed");
//   //     //   }
//   //     //   break;

//   //     default:
//   //       {
//   //         if (index <= themes.length - 1)
//   //           globalColor = themes[index].primaryColor;
//   //         Get.changeThemeMode(ThemeMode.light);

//   //         // Get.changeTheme(lightTheme);
//   //       }
//   //       break;
//   //   }
//   // }
// }
