import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/editprofile_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';
import 'package:validated/validated.dart';

import 'edit_theme.dart';

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  var userController = Get.find<UserController>();

  // var c = Get.put(EditProfileController());
  @override
  Widget build(BuildContext context) {
    Widget _buildText(String text) {
      return Container(
        width: 90,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: AutoSizeText(
            text,
            maxLines: 1,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    var size = MediaQuery.of(context).size;

    return KeyboardDismisser(
      child: GetX<EditProfileController>(
          init: EditProfileController(),
          builder: (controller) {
            return Scaffold(
              appBar: CustomAppBar(
                  back: true,
                  title: "Edit Profile",
                  iconButton: Opacity(
                    opacity: controller.edited ? 1 : 0.5,
                    child: InkWell(
                      onTap: () {
                        if (!controller.editProfileFormKey.currentState!
                            .validate()) {
                          print("Null Data");
                        } else {
                          FocusScope.of(context)
                              .requestFocus(new FocusNode()); //remove focus
                          controller.editProfileFormKey.currentState!.save();
                          controller.updateUserData();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 20),
                        child: Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: !Get.isDarkMode
                                  ? Colors.black
                                  : Colors.white),
                        ),
                      ),
                    ),
                  )),
              body: SingleChildScrollView(
                child: Container(
                  height: size.height * .85,
                  width: size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              controller.showPicker(context, false);
                            },
                            child:
                                userController.userModel.bannerURL!.isNotEmpty
                                    ? Image.network(
                                        userController.userModel.bannerURL!,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/banner.png",
                                        height: 120,
                                        fit: BoxFit.fill,
                                      ),
                          )),
                      Positioned(
                        top: 67.5,
                        child: InkWell(
                          onTap: () {
                            controller.showPicker(context, true);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Obx(
                              () => UserAvatar(
                                userController.currentUid,
                                isdisabledTap: true,
                                radius: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 200,
                        left: 10,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            width: size.width - 20,
                            child: Form(
                              key: controller.editProfileFormKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: _buildText("Username")),
                                      Expanded(
                                          flex: 3,
                                          child: BuildUserNameField(
                                            onChanged: () {
                                              setState(() {});
                                            },
                                          ))
                                    ],
                                  ),
                                  addHeight(10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1, child: _buildText("Name")),
                                      Expanded(
                                          flex: 3,
                                          child: BuildNameField(
                                            onChanged: () {
                                              setState(() {});
                                            },
                                          )),
                                    ],
                                  ),
                                  addHeight(10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1, child: _buildText("Bio")),
                                      Expanded(
                                          flex: 3,
                                          child: BuildBioField(
                                            onChanged: () {
                                              setState(() {});
                                            },
                                          )),
                                    ],
                                  ),
                                  addHeight(10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: _buildText("Website")),
                                      Expanded(
                                          flex: 3,
                                          child: BuildWebsite(
                                            onChanged: () {
                                              setState(() {});
                                            },
                                          )),
                                    ],
                                  ),
                                  addHeight(20),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: _buildText("Theme"),
                                      ),
                                      Expanded(
                                          child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: ChangeTheme(),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class BuildWebsite extends StatelessWidget {
  final VoidCallback onChanged;
  BuildWebsite({
    super.key,
    required this.onChanged,
  });
  EditProfileController controller = Get.find<EditProfileController>();
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          maxLength: 32,
          validator: (String? value) {
            if (value!.length > 150) {
              return "Bio should be less than 150 characters";
            }
            return null;
          },
          onChanged: (val) {
            onChanged();
          },
          decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: standardContrastColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[200]!))),
          controller: controller.websiteController,
        ),
      ),
    );
  }
}

class BuildBioField extends StatelessWidget {
  final VoidCallback onChanged;
  BuildBioField({
    super.key,
    required this.onChanged,
  });
  EditProfileController controller = Get.find<EditProfileController>();
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          maxLines: 2,
          textAlignVertical: TextAlignVertical.center,
          maxLength: 64,
          onChanged: (val) {
            onChanged();
          },

          validator: (String? value) {
            if (value!.length > 64) {
              return "Bio should be less than 64 characters";
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: standardContrastColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[200]!))),
          // maxLines: 2,
          controller: controller.bioController,
        ),
      ),
    );
  }
}

class BuildNameField extends StatelessWidget {
  final VoidCallback onChanged;
  BuildNameField({super.key, required this.onChanged});
  EditProfileController controller = Get.find<EditProfileController>();
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          maxLength: 32,
          decoration: InputDecoration(
              isDense: true,
              isCollapsed: true,
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: standardContrastColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[200]!))),
          controller: controller.nameController,
          onChanged: (val) {
            onChanged();
          },
          validator: (String? value) {
            if (value!.isEmpty) {
              return 'Name Required';
            }
            if (value.length > 32) {
              return "Name must Be 32 Characters or Less";
            }
            return null;
          },
        ),
      ),
    );
  }
}

class BuildUserNameField extends StatelessWidget {
  final VoidCallback onChanged;
  BuildUserNameField({
    super.key,
    required this.onChanged,
  });

  EditProfileController controller = Get.find<EditProfileController>();
  UserController userController = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SizedBox(
        width: 200,
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          maxLength: 17,
          decoration: InputDecoration(
            errorMaxLines: 2,
            isDense: true,
            isCollapsed: true,
            suffixIconConstraints: BoxConstraints(
              maxHeight: 200,
              maxWidth: 200,
              minHeight: 20,
              minWidth: 20,
            ),
            suffixIcon: controller.usernameController.text !=
                    userController.userModel.username
                ? controller.usernameloading
                    ? CircularProgressIndicator.adaptive()
                    : controller.isValid
                        ? checkmarkDIcon.copyWith(
                            color: Colors.green,
                          )
                        : xDIcon.copyWith(color: Colors.red)
                : null,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.blue[200]!,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: standardContrastColor.withOpacity(0.3),
              ),
            ),
          ),
          controller: controller.usernameController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (value) {
            controller.username.value = value;
            onChanged();
          },
          validator: (String? value) {
            if (controller.loading) return null;
            if (value!.isEmpty) {
              return 'Username Required';
            }
            if (value.contains('@')) {
              return "username cannot contain @";
            }
            if (value.length > 17) {
              return "Username should be less than 17 characters";
            }

            if (isEmoji(value) || value.contains('#')) {
              return "Only Letters (a-Z), Numbers (0-9), and Underscores (_) Allowed";
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
            if (controller.usernameController.text ==
                userController.userModel.username) return null;

            if (!controller.usernameloading && !controller.isValid) {
              return "Username Already Exists";
            }

            return null;
          },
        ),
      ),
    );
  }
}

// class BuildTextField extends StatelessWidget {
//   TextEditingController textController;
//   Function(String?) validator;
//   int maxLength;

//   const BuildTextField({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 20),
//       child: SizedBox(
//         width: 200,
//         child: TextFormField(
//           textAlignVertical: TextAlignVertical.center,
//           maxLength: 32,
//           validator: (String? value) {
//             if (value!.length > 150) {
//               return "Bio should be less than 150 characters";
//             }
//             return null;
//           },
//           decoration: InputDecoration(
//               isDense: true,
//               isCollapsed: true,
//               enabledBorder: UnderlineInputBorder(
//                 borderSide: BorderSide(
//                   color: standardContrastColor.withOpacity(0.3),
//                 ),
//               ),
//               focusedBorder: UnderlineInputBorder(
//                   borderSide: BorderSide(color: Colors.blue[200]!))),
//           controller: controller.websiteController,
//         ),
//       ),
//     );
//   }
// }

/// returns white for dark theme, and black for white theme
Color get standardContrastColor => Get.isDarkMode ? Colors.white : Colors.black;
Color get standardThemeModeColor =>
    Get.isDarkMode ? Colors.black : Colors.white;
