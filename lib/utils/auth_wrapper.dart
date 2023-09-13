import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/pages/authentication/login.dart';
import 'package:sano_gano/view/pages/authentication/setup_profile.dart';
import 'package:sano_gano/view/pages/authentication/verify_email.dart';
import 'package:sano_gano/view/pages/root/root.dart';

class AuthWrapper extends GetWidget<AuthController> {
  final bool? isNewUser;
  AuthWrapper({
    this.isNewUser = false,
  });
  @override
  Widget build(BuildContext context) {
    return GetX<AuthController>(
        init: AuthController(),
        builder: (authController) {
          var user = authController.user;
          // print("user ::: $user");

          if (!(user != null && !user.isAnonymous)) {
            return LoginPage();
          } else {
            if (!kDebugMode) if (!user.emailVerified) return VerifyEmailPage();
            return GetBuilder<UserController>(
                init: UserController(),
                autoRemove: false,
                builder: (userController) {
                  return userController.userModel.isNull
                      ? Scaffold(
                          backgroundColor:
                              Get.isDarkMode ? Colors.black : Colors.white,
                          body: Center(
                            child: CircularProgressIndicator(),
                          ))
                      : userController.userModel.username?.isNotEmpty ?? false
                          ? RootPage()
                          : ProfileSetUpPage();
                });
          }
        });
  }
}
