import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';

class ThemeController extends GetxController {
  RxBool _isDarkMode = false.obs;
  RxInt _globalColor = 0xFF000000.obs;
  RxInt _currentActiveColorIndex = 0.obs;
  GetStorage _box = GetStorage();
  bool get isDarkMode => _isDarkMode.value;
  int get globalColor => _globalColor.value;
  int get currentActiveColorIndex => _currentActiveColorIndex.value;
  RxBool refreshApp = false.obs;

  @override
  void onInit() {
    initializeTheme();
    _box.listenKey("darkMode", (value) {
      log("darkMode changed to $value");
      _isDarkMode.value = value;
    });
    _box.listenKey("color", (value) {
      log("color changed to $value");
      _globalColor.value = value;
    });
    _box.listenKey("currentActiveColorIndex", (value) {
      log("currentActiveColorIndex changed to $value");
      _currentActiveColorIndex.value = value ?? 0;
    });
    super.onInit();
  }

  void setDarkMode(bool value) {
    _isDarkMode.value = value;
  }

  void setGlobalColor(int value) {
    _globalColor.value = value;
  }

  void initializeTheme() {
    _isDarkMode.value = _box.read<bool>("darkMode") ?? false;
    var defaultColor = isDarkMode ? 0xFFFFFFFF : 0xFF000000;
    _globalColor.value = _box.read("color") ?? defaultColor;
    _currentActiveColorIndex.value = _box.read("currentActiveColorIndex") ?? 0;
  }

  void toggleDarkMode() {
    _box.write("darkMode", true);
    if (currentActiveColorIndex == 0) {
      _box.write("color", themeColors()[_currentActiveColorIndex.value].value);
      _box.write("currentActiveColorIndex", 0);
    } else {
      _box.write("color", themeColors()[_currentActiveColorIndex.value].value);

      _box.write(
          "currentActiveColorIndex", themeColors().indexOf(Color(globalColor)));
    }
  }

  void toggleLightMode() {
    _box.write("darkMode", false);
    if (currentActiveColorIndex == 0) {
      _box.write("color", themeColors()[_currentActiveColorIndex.value].value);
      _box.write("currentActiveColorIndex", 0);
    } else {
      _box.write("color", themeColors()[_currentActiveColorIndex.value].value);

      _box.write(
          "currentActiveColorIndex", themeColors().indexOf(Color(globalColor)));
    }
  }

  Future<void> changeThemeMode(BuildContext context) async {
    if (isDarkMode) {
      toggleLightMode();
    } else {
      toggleDarkMode();
    }
    refreshApp.value = !refreshApp.value;
    1.seconds.delay().then((value) => refreshApp.value = !refreshApp.value);
  }

  Future<void> changeThemeColor(int index, BuildContext context) async {
    _box.write("darkMode", isDarkMode);
    _box.write("color", themeColors()[index].value);
    _box.write("currentActiveColorIndex", index);
    refreshApp.value = !refreshApp.value;
    1.seconds.delay().then((value) => refreshApp.value = !refreshApp.value);
  }

  List<Color> themeColors() {
    return [
      Color(isDarkMode ? 0xFFFFFFFF : 0xFF000000), //white or black
      Color(isDarkMode ? 0xFF008AC9 : 0xFF007596), // light blue
      Color(isDarkMode ? 0xFF7789CB : 0xFF42528D), // light purple
      Color(isDarkMode ? 0xFFDE4D54 : 0xFF943E3D), // light red
      Color(isDarkMode ? 0xFFF29B54 : 0xFFAC6434), // light orange
    ];
  }
}
