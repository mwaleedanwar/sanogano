import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

var messageColor = Color(0xFF7789CB);
ThemeData get lightTheme => ThemeData(
      iconTheme: IconThemeData(color: Colors.black),
      fontFamily: 'Roboto',
      primaryColor: Get.isDarkMode ? Color(0xFF7789CB) : Color(0xFF42528D),
      brightness: Brightness.light,
      hintColor: Color(0xFF9E9E9E),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
      ),
      pageTransitionsTheme: _transitionsTheme,
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
    );

// ThemeData get blackTheme =>
//     FlexColorScheme.dark(scheme: FlexScheme.mandyRed).toTheme.copyWith(
//           primaryColor: Get.isDarkMode ? Color(0xFF7789CB) : Color(0xFF42528D),
//           brightness: Brightness.light,
//           accentColor: Colors.white,
//           hintColor: Color(0xFF9E9E9E),
//           pageTransitionsTheme: _transitionsTheme,
//         );

// ThemeData get redTheme => ThemeData(
//       fontFamily: 'Roboto',
//       primaryColor: Get.isDarkMode ? Color(0xFF943E3D) : Color(0xFFDE4D54),
//       brightness: Brightness.light,
//       accentColor: Colors.white,
//       hintColor: Color(0xFF9E9E9E),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: Colors.white,
//       ),
//       pageTransitionsTheme: _transitionsTheme,
//     );

// ThemeData get blueTheme => ThemeData(
//       fontFamily: 'Roboto',
//       primaryColor: Get.isDarkMode ? Color(0xFF008AC9) : Color(0xFF007596),
//       brightness: Brightness.light,
//       accentColor: Colors.white,
//       hintColor: Color(0xFF9E9E9E),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: Colors.white,
//       ),
//       pageTransitionsTheme: _transitionsTheme,
//     );

// ThemeData get goldenTheme => ThemeData(
//       fontFamily: 'Roboto',
//       primaryColor: Get.isDarkMode ? Color(0xFFF29B54) : Color(0xFFAC6434),
//       brightness: Brightness.light,
//       accentColor: Colors.white,
//       hintColor: Color(0xFF9E9E9E),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: Colors.white,
//       ),
//       pageTransitionsTheme: _transitionsTheme,
//     );

// ThemeData get greenTheme => ThemeData(
//       fontFamily: 'Roboto',
//       primaryColor: Color(0xFF007596),
//       brightness: Brightness.light,
//       accentColor: Colors.white,
//       hintColor: Color(0xFF9E9E9E),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: Colors.white,
//       ),
//       pageTransitionsTheme: _transitionsTheme,
//     );

// var blackText = TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black);

PageTransitionsTheme _transitionsTheme = PageTransitionsTheme(builders: {
  TargetPlatform.android: ZoomPageTransitionsBuilder(),
  TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
  TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
});

String get defaultRecipeImage {
  return "https://firebasestorage.googleapis.com/v0/b/sanogano-bf152.appspot.com/o/defaults%2Frecipe.png?alt=media&token=8dcf066b-12ad-40a7-953b-4ea8bf2c9095";
}

String get defaultWorkoutImage {
  return "https://firebasestorage.googleapis.com/v0/b/sanogano-bf152.appspot.com/o/defaults%2Fworkout.png?alt=media&token=af0b1624-7c64-46f7-85ed-c3526c272ab9";
}

class AppThemes {
  ThemeData finalLightTheme() {
    return lightTheme.copyWith(
      scaffoldBackgroundColor: Colors.white,
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.white),
      tabBarTheme: TabBarTheme(
        labelColor: Colors.black,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          color: Get.theme.primaryColor,
        ),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  ThemeData darkTheme() {
    return FlexColorScheme.dark(scheme: FlexScheme.mandyRed).toTheme.copyWith(
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.black,
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.black,
          ),
          dialogBackgroundColor: Colors.black,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.black,
          ),
          backgroundColor: Colors.black,
          inputDecorationTheme: InputDecorationTheme(
            fillColor: Colors.black,
          ),
        );
  }
}
