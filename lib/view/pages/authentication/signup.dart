import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/authentication/login.dart';
import 'package:sano_gano/view/pages/authentication/widgets/auth_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/bottom_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/custom_button.dart';
import 'package:sano_gano/view/pages/authentication/widgets/input_decor.dart';

class SignUpPage extends GetWidget<AuthController> {
  final GlobalKey<FormState> _signUpFormKey = GlobalKey();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  FocusNode emailNode = FocusNode();
  FocusNode passNode = FocusNode();
  FocusNode cPassNode = FocusNode();
  var showPassword = false;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    Widget _buildEmail() {
      return TextFormField(

        inputFormatters: [
          LengthLimitingTextInputFormatter(320),
        ],
        focusNode: emailNode,
        maxLength: 320,
        buildCounter: (context,
                {required currentLength,
                required isFocused,
                required maxLength}) =>
            null,
        controller: _emailController,
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Email Required';
          }
          if (value.length > 320) {
            return 'Email Must Be 320 Characters or Less';
          }
          if (!GetUtils.isEmail(value)) {
            return 'Email Does Not Exist';
          }

          return null;
        },
        decoration: inputDecoration("Enter Your Email Address"),
      );
    }

    Widget _buildPassword() {
      return TextFormField(

        focusNode: passNode,
        controller: _passwordController,
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Password Required';
          }
          if (value.length < 8) {
            return 'Password Must Have At Least 8 Characters';
          }
          return null;
        },
        obscureText: controller.getSignUpObscureText,
        decoration: passwordDecoration(controller),
      );
    }

    Widget _buildConfirmPassword() {
      return TextFormField(

        focusNode: cPassNode,
        controller: _confirmPasswordController,
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Password Required';
          }
          if (value != _passwordController.text) {
            return 'Passwords Must Match';
          }
          return null;
        },
        obscureText: controller.getSignUpObscureText,
        decoration: passwordDecoration(controller, label: "Confirm Password"),
      );
    }

    return KeyboardDismisser(
      child: Container(
        color: Get.isDarkMode ? Colors.black : Colors.white,
        child: Scaffold(
          backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
          // resizeToAvoidBottomInset: false ,
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            onVerticalDragDown: (details) {
              FocusScope.of(context).unfocus();
            },
            child: Obx(
              () => ModalProgressHUD(
                inAsyncCall: controller.loading,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20),
                      child: Form(
                        key: _signUpFormKey,
                        child: Container(
                          child: Column(
                            children: [
                              AuthText("Create Your Account", 17.0),
                              addHeight(20.0),
                              _buildEmail(),
                              addHeight(20.0),
                              _buildPassword(),
                              addHeight(20.0),
                              _buildConfirmPassword(),
                              addHeight(20.0),
                              CustomButton(
                                text: "Continue",
                                onPressed: () {
                                  if (!_signUpFormKey.currentState!
                                      .validate()) {
                                    print(_emailController.text);
                                  } else {
                                    _signUpFormKey.currentState!.save();

                                    FocusScope.of(context).requestFocus(
                                        new FocusNode()); //remove focus

                                    controller.signUp(_emailController.text,
                                        _passwordController.text);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 2,
                    ),
                    BottomText(
                      "Already Have an Account?",
                      () {
                        Get.back();
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
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
