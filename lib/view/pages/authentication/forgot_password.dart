import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/authentication/widgets/auth_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/bottom_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/custom_button.dart';
import 'package:sano_gano/view/pages/authentication/widgets/input_decor.dart';

import 'login.dart';

class ForgotPasswordPage extends GetWidget<AuthController> {
  final bool changePasswordMode;

  TextEditingController _emailController = TextEditingController();

  final GlobalKey<FormState> _forgotPasswordFormKey = GlobalKey();

  ForgotPasswordPage({this.changePasswordMode = false}) {
    _emailController = TextEditingController(
        text: !changePasswordMode
            ? null
            : Get.find<AuthController>().user!.email);
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildEmail() {
      return TextFormField(
        controller: _emailController,

        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Email is required';
          }
          if (value.length > 320) {
            return 'Email should be less than 320 characters';
          }
          if (!GetUtils.isEmail(value)) {
            return 'Email Does Not Exist';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        decoration: inputDecoration("Enter Your Email Address"),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        iconButton: Container(),
        title: "",
      ),
      body: Obx(
        () => ModalProgressHUD(
          inAsyncCall: controller.loading,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Form(
              key: _forgotPasswordFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer(),
                  addHeight(Get.height * 0.3),
                  AuthText("What’s Your Email Address?", 17.0),
                  addHeight(20.0),
                  _buildEmail(),
                  addHeight(20.0),
                  CustomButton(
                    text: "Continue",
                    onPressed: () {
                      if (!_forgotPasswordFormKey.currentState!.validate()) {
                        print(_emailController.text);
                      } else {
                        _forgotPasswordFormKey.currentState!.save();
                        FocusScope.of(context)
                            .requestFocus(new FocusNode()); //remove focus

                        controller
                            .sendPasswordResetEmail(_emailController.text);
                      }
                    },
                  ),
                  Spacer(),
                  SizedBox(
                    height: 2,
                  ),
                  if (!changePasswordMode)
                    BottomText(
                      "Remember Password?",
                      () {
                        Get.back();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
