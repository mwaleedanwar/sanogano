import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/theme_controller.dart';

class ChangingTheme extends StatelessWidget {
  ChangingTheme({super.key});
  ThemeController controller = Get.find<ThemeController>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: controller.isDarkMode ? Colors.black : Colors.white,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "Applying Theme...",
                style: TextStyle(
                    color: controller.isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(
                  controller.isDarkMode ? Colors.black : Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
