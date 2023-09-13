import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/editprofile_controller.dart';
import 'package:sano_gano/utils/auth_wrapper.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/authentication/widgets/auth_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/custom_button.dart';
import 'package:sano_gano/view/pages/authentication/widgets/input_decor.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:validated/validated.dart';

class ProfileSetUpPage extends GetWidget<AuthController> {
  final GlobalKey<FormState> _setUpProfileFormKey = GlobalKey();
  var editProfileController = Get.put(EditProfileController());
  TextEditingController _nameController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget _buildName() {
      return TextFormField(

        controller: _nameController,
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Name Required';
          }
          if (value.length > 32) {
            return 'Name Must Be 32 Characters or Less';
          }
          return null;
        },
        decoration: inputDecoration("Name"),
      );
    }

    Widget _buildUsername() {
      return TextFormField(

        controller: _usernameController,
        onChanged: (val) {
          editProfileController.username.value = val;
        },
        validator: (String? value) {
          if (value!.isEmpty) {
            return 'Username Required';
          }
          if (value.length > 17) {
            return 'Username Must Be 17 Characters or Less';
          }
          if (isEmoji(value) || value.contains('#')) {
            return "Only Letters (a-Z), Numbers (0-9), and Underscores (_) Allowed";
          }
          if (value.contains('@')) {
            return "username cannot contain @";
          }

          if (value.contains(" ")) {
            return "Spaces Not Allowed";
          }

          for (var i = 0; i < value.length; i++) {
            if (RegExp(r'[a-zA-Z0-9_]').hasMatch(value[i])) {
            } else {
              return "Only Letters (a-Z), Numbers (0-9), and Underscores (_) Allowed";
            }
          }
          if (!editProfileController.isValid) {
            return 'Username Already Exists';
          }
          return null;
        },
        decoration: inputDecoration("Username"),
      );
    }

    Widget _buildPrivacyPolicy() {
      return Container(
        width: Get.width,
        // alignment: Alignment.bottomCenter,
        // color: Colors.black,
        child: ParsedText(
            selectable: true,
            alignment: TextAlign.center,
            parse: [
              MatchText(
                  type: ParsedType.CUSTOM,
                  pattern: "Terms of Use",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                  onTap: (val) {
                    _launchURL("https://www.sanogano.com/terms");
                  }),
              MatchText(
                  type: ParsedType.CUSTOM,
                  pattern: "Privacy Policy",
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                  onTap: (val) {
                    _launchURL("https://www.sanogano.com/privacy");
                  }),
            ],
            style: TextStyle(color: standardContrastColor),
            text:
                "By tapping Sign Up, you agree to our Terms of Use and Privacy Policy"),
      );
    }

    return Scaffold(
      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18.0),
        child: _buildPrivacyPolicy(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _setUpProfileFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer(),
              // LogoImage(),
              addHeight(20),
              AuthText("Create Your Profile", 17.0),

              addHeight(20.0),
              _buildUsername(),
              addHeight(20.0),
              _buildName(),
              addHeight(20.0),
              CustomButton(
                text: "Sign Up",
                onPressed: () {
                  if (!_setUpProfileFormKey.currentState!.validate()) {
                    print(_nameController.text);
                  } else {
                    _setUpProfileFormKey.currentState!.save();

                    controller.setUserData(
                        _nameController.text, _usernameController.text);
                  }
                },
              ),
              addHeight(5.0),

              TextButton(
                  onPressed: () {
                    controller.signOut();
                    // Get.offAll(AuthWrapper());
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor),
                  )),
              // Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
