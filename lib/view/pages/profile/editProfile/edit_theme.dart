import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/theme_controller.dart';

class ChangeTheme extends StatelessWidget {
  ThemeController themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...List.generate(
                themeController.themeColors().length,
                (index) => Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (index != themeController.currentActiveColorIndex) {
                        print("changing theme");
                        themeController.changeThemeColor(index, context);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                              themeController.currentActiveColorIndex == index
                                  ? Border.all(
                                      color: Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 3,
                                    )
                                  : null,
                          // borderRadius: BorderRadius.circular(10),
                          color: themeController.themeColors()[index],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              TextButton(
                child: Text(!themeController.isDarkMode ? 'Dark' : 'Light',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Get.isDarkMode ? Colors.white : Colors.black)),
                onPressed: () async {
                  themeController.changeThemeMode(
                      context); // await box.write("darkMode", !Get.isDarkMode);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
