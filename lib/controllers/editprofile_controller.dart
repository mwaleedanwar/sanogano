import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/services/ImagePickerServices.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/widgets/parse/extensions.dart';

class EditProfileController extends GetxController {
  final GlobalKey<FormState> editProfileFormKey = GlobalKey();

  Rx<TextEditingController> _nameController = TextEditingController().obs;
  TextEditingController get nameController => _nameController.value;
  Rx<TextEditingController> _usernameController = TextEditingController().obs;
  TextEditingController get usernameController => _usernameController.value;
  Rx<TextEditingController> _bioController = TextEditingController().obs;
  TextEditingController get bioController => _bioController.value;
  Rx<TextEditingController> _websiteController = TextEditingController().obs;
  TextEditingController get websiteController => _websiteController.value;

  String get initialName => userController.userModel.name?.isNotEmpty ?? false
      ? userController.userModel.name!
      : "";
  String get initialUsername =>
      userController.userModel.username?.isNotEmpty ?? false
          ? userController.userModel.username!
          : "";
  String get initialBio => userController.userModel.bio?.isNotEmpty ?? false
      ? userController.userModel.bio!
      : "";
  String get initialWebsite =>
      userController.userModel.website?.isNotEmpty ?? false
          ? userController.userModel.website!
          : "";

  var username = ''.obs;
  bool isValid = false;

  var _profileURL = "".obs;
  String get profileURL => _profileURL.value;

  var _loading = false.obs;
  bool get loading => _loading.value;

  var userController = Get.find<UserController>();
  RxBool _edited = false.obs;
  bool get edited => _edited.value;
  set setEdited(bool value) => _edited.value = value;
  var db = Database();
  var usernameloading = false;
  @override
  void onInit() {
    userController = Get.find<UserController>();

    _nameController.value = TextEditingController(
        text: userController.userModel.name?.isNotEmpty ?? false
            ? userController.userModel.name
            : "");
    _usernameController.value = TextEditingController(
        text: userController.userModel.username?.isNotEmpty ?? false
            ? userController.userModel.username
            : "");
    _bioController.value = TextEditingController(
        text: userController.userModel.bio?.isNotEmpty ?? false
            ? userController.userModel.bio
            : null);
    _websiteController.value = TextEditingController(
        text: userController.userModel.website?.isNotEmpty ?? false
            ? userController.userModel.website
            : null);
    _profileURL.value = userController.userModel.profileURL?.isNotEmpty ?? false
        ? userController.userModel.profileURL!
        : "";

    nameController.addListener(() {
      if (nameController.text == initialName) {
        _edited = false.obs;
      } else {
        _edited = true.obs;
      }
    });
    usernameController.addListener(() {
      if (usernameController.text == initialUsername) {
        _edited = false.obs;
      } else {
        _edited = true.obs;
      }
    });
    bioController.addListener(() {
      if (bioController.text == initialBio) {
        _edited = false.obs;
      } else {
        _edited = true.obs;
      }
    });
    websiteController.addListener(() {
      if (websiteController.text == initialWebsite) {
        _edited = false.obs;
      } else {
        _edited = true.obs;
      }
    });

    debounce<String>(username, (username) async {
      if (!username.isValidUsername) {
        isValid = false;
        update();
        return;
      }
      usernameloading = true;
      update();
      var docs = await db.usersCollection
          .where('plainUsername', isEqualTo: username.toLowerCase())
          .get();
      if (docs.docs.length == 0 && username.isNotEmpty) {
        usernameloading = false;
        isValid = true;
        update();
      } else {
        usernameloading = false;
        isValid = false;
        update();
      }
    }, time: Duration(seconds: 1));
    super.onInit();
  }

  void updateUserData() {
    _loading.value = true;

    var id = userController.userModel.id;
    var _name = nameController.text;
    var _username = usernameController.text;
    var _bio = bioController.text;
    var _website = websiteController.text;

    try {
      FirebaseFirestore.instance.collection("users").doc(id).update({
        "name": _name,
        "username": _username,
        "plainUsername": _username.toLowerCase(),
        "bio": _bio,
        "website": _website,
      });

      userController.updateUserController(_name, _username, _bio, _website);

      _loading.value = false;

      Get.back();
    } on FirebaseException catch (e) {
      _loading.value = false;
      Get.snackbar("Error", e.message!, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showPicker(context, bool isProfilePicture) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: cameraDIcon,
                    title: Text('Camera'),
                    onTap: () async {
                      await _imgFromSource(
                          ImageSource.camera, isProfilePicture);
                      Get.back();
                    },
                  ),
                  ListTile(
                      leading: galleryDIcon,
                      title: Text('Library'),
                      onTap: () async {
                        await _imgFromSource(
                            ImageSource.gallery, isProfilePicture);

                        Get.back();
                      }),
                  ListTile(
                      leading: trashDIcon,
                      title: Text('Remove'),
                      onTap: () async {
                        if (isProfilePicture) {
                          await setProfileURL('');
                        } else {
                          await userController.currentUserReference
                              .update({'bannerURL': ''});
                          update();
                        }
                        Get.back();
                      }),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _imgFromSource(ImageSource source, bool isProfilePicture) async {
    try {
      var pickedImage = await ImagePicker().pickImage(
        source: source,
      );
      if (pickedImage != null) {
        File? croppedImage = await ImagePickerServices.cropImage(
            File(pickedImage.path),
            coverPhoto: !isProfilePicture,
            profilePic: isProfilePicture);
        if (croppedImage != null) {
          showLoading(loadingText: "Uploading...");
          if (isProfilePicture) {
            var url = await FirebaseStorageServices.uploadToStorage(
              file: croppedImage,
              folderName: 'profileImages',
              isVideo: false,
            );
            await setProfileURL(url);
          } else {
            await userController.currentUserReference.update({
              'bannerURL': await FirebaseStorageServices.uploadToStorage(
                  isVideo: false, file: croppedImage, folderName: "Banners")
            });
            update();
          }
          hideLoading();
        }
      }

      // if (imagePath != null) {

      // }
    } on Exception catch (e) {
      hideLoading();
      return;
      // TODO
    }
  }

  Future<void> setProfileURL(String profileURL) async {
    await userController.updateProfileImage(profileURL);
    var _user = Get.find<AuthController>().user;
    await _user!.updatePhotoURL(profileURL);
    return;
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    websiteController.dispose();
  }

  Future<void> removeImage() async {
    userController.currentUserReference.update({'profileURL': ''});
  }
}
