import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/authentication/forgot_password.dart';
import 'package:sano_gano/view/pages/authentication/signup.dart';
import 'package:sano_gano/view/pages/authentication/widgets/auth_image.dart';
import 'package:sano_gano/view/pages/authentication/widgets/auth_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/custom_button.dart';
import 'package:sano_gano/view/pages/authentication/widgets/input_decor.dart';

class LoginPage extends GetWidget<AuthController> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  GlobalKey<FormState> _loginFormKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Widget _buildEmail() {
      return TextFormField(

        controller: _emailController,
        // style: TextStyle(fontWeight: FontWeight.bold),// need to know if textfield's text should be bold
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Email or Username Required';
          }
          if (controller.errorString.isNotEmpty) {
            return controller.errorString;
            // return 'Email or Username Incorrect';
          }

          return null;
        },

        textInputAction:
            Platform.isIOS ? TextInputAction.done : TextInputAction.done,
        decoration: inputDecoration(
          "Email or Username",
        ),
      );
    }

    Widget _buildPassword() {
      return TextFormField(

        controller: _passwordController,
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Password Required';
          }
          if (controller.wrongPassword) {
            return 'Password Incorrect';
          }
          // if (value.length < 8) {
          //   return 'password should be 8 characters long';
          // }
          return null;
        },
        obscureText: controller.getLoginObscureText,
        decoration: passwordDecoration(controller),
      );
    }

    return KeyboardDismisser(
      child: Scaffold(
        // backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
        body: Obx(
          () => ModalProgressHUD(
            inAsyncCall: controller.loading,
            child: Form(
              key: _loginFormKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoImage(),
                    addHeight(40.0),
                    _buildEmail(),
                    addHeight(20.0),
                    _buildPassword(),
                    addHeight(15.0),
                    Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                            onTap: () {
                              Get.to(() => ForgotPasswordPage());
                            },
                            child: AuthText("Forgot Password ?", 12.0))),
                    addHeight(15.0),
                    CustomButton(
                      text: "Log In",
                      onPressed: () async {
                        controller.wrongPassword = false;
                        controller.errorString = '';
                        if (!_loginFormKey.currentState!.validate()) {
                          print(_emailController.text);
                          print(_passwordController.text);
                        } else {
                          FocusScope.of(context)
                              .requestFocus(new FocusNode()); //remove focus
                          _loginFormKey.currentState!.save();

                          var result = await controller.login(
                              _emailController.text, _passwordController.text,
                              usernameMode: !_emailController.text.isEmail);
                          if (!result) _loginFormKey.currentState!.validate();
                        }
                      },
                    ),
                    addHeight(20.0),
                    InkWell(
                        onTap: () {
                          Get.to(() => SignUpPage());
                        },
                        child: Container(
                            width: 100,
                            child: Center(
                                child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                            )))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration passwordDecoration(controller, {String? label}) =>
    InputDecoration(
        isCollapsed: false,
        isDense: true,
        suffixIconConstraints: BoxConstraints(
            maxHeight: 200, maxWidth: 200, minHeight: 20, minWidth: 20),
        suffixIcon: InkWell(
            onTap: controller.setLoginObscureText,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
              child: controller.getLoginObscureText
                  ? hidePasswordIcon.copyWith(size: 20)
                  : showPasswordIcon.copyWith(size: 20),
            )),
        labelText: label ?? "Password",
        labelStyle: TextStyle(
          color: Get.theme.primaryColor.withOpacity(0.5),
        ),
        // contentPadding:
        //     EdgeInsets.symmetric(vertical: 5.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Color(0xFF707070), width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Get.theme.primaryColor, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Color(0xFF707070), width: 1.0),
        ));
