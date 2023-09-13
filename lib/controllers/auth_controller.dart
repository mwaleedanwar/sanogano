import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/controllers/recent_search_controller.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/auth_wrapper.dart';
import 'package:sano_gano/view/pages/authentication/verify_email.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as sc;

import '../view/pages/home/ad_controller.dart';
import 'activity_controller.dart';

class AuthController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<User?> _firebaseUser = Rxn<User?>();
  // User get user => _firebaseUser.value;
  User? get user => _firebaseUser.value;

  var _loading = false.obs;
  bool get loading => _loading.value;

  /// Obscure Text
  var _loginObscureText = true.obs;
  var _signUpObscureText = true.obs;
  var _confirmPsObscureText = true.obs;
  bool get getLoginObscureText => _loginObscureText.value;
  void setLoginObscureText() {
    _loginObscureText.value = !_loginObscureText.value;
    _signUpObscureText.value = !_signUpObscureText.value;
  }

  bool get getSignUpObscureText => _signUpObscureText.value;
  void setSignUpObscureText() =>
      _signUpObscureText.value = !_signUpObscureText.value;
  bool get getConfirmPsObscureText => _confirmPsObscureText.value;
  void setConfirmPsObscureText() =>
      _confirmPsObscureText.value = !_confirmPsObscureText.value;

  @override
  void onInit() {
    _firebaseUser.bindStream(_auth.authStateChanges());
    _firebaseUser.listen((user) {});
    super.onInit();
  }

  bool get isNew {
    if (FirebaseAuth.instance.currentUser == null) {
      return false;
    }
    return FirebaseAuth.instance.currentUser!.metadata.creationTime!
            .difference(DateTime.now())
            .inSeconds >
        30;
  }

  void signUp(String email, String password) async {
    try {
      _loading.value = true;

      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.to(() => VerifyEmailPage());
      _loading.value = false;
    } on FirebaseAuthException catch (e) {
      _loading.value = false;
      Get.snackbar("Error", e.message!, snackPosition: SnackPosition.BOTTOM);
    }
  }

  void setUserData(String name, String username) async {
    bool exist = (await FirebaseFirestore.instance
                .collection("users")
                .where("plainUsername", isEqualTo: username.toLowerCase())
                .get())
            .docs
            .length >
        0;
    if (!exist) {
      UserModel _user = UserModel(
          id: _firebaseUser.value!.uid,
          name: name,
          email: _firebaseUser.value!.email!,
          username: username,
          established: DateTime.now(),
          followers: 0,
          following: 0);
      try {
        if (await UserDatabase().createUser(_user)) {
          Get.find<UserController>().userModel = _user;
          // Get.find<UserController>().initChatConnection();
          Get.off(() => AuthWrapper(
                isNewUser: true,
              ));
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar("Error", e.message!, snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      // Get.snackbar("Error", "Username Not Available ",
      //     snackPosition: SnackPosition.BOTTOM);
    }
  }

  String errorString = '';
  bool wrongPassword = false;

  Future<bool> login(String email, String password,
      {bool usernameMode = false}) async {
    try {
      _loading.value = true;
      if (usernameMode) {
        await _auth.signInAnonymously();
        var docs = await FirebaseFirestore.instance
            .collection("users")
            .where('plainUsername', isEqualTo: email.toLowerCase())
            .get();
        await _auth.currentUser!.delete();

        if (docs.docs.length > 0) {
          email = UserModel.fromFirestore(docs.docs.first).email!;
        } else {
          _loading.value = false;
          errorString = "Username Does Not Exist";
          // Get.snackbar("Error", "Invalid Username",
          //     snackPosition: SnackPosition.BOTTOM);
          return false;
        }
      }
      UserCredential _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      errorString = '';
      Get.find<UserController>().currentUser =
          (await UserDatabase().getUser(_authResult.user!.uid)).obs;

      _loading.value = false;
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorString = "Email Does Not Exist";
      }

      if (e.code == "wrong-password") {
        wrongPassword = true;
        errorString = '';
      }
      _loading.value = false;

      // Get.snackbar("Error", errorString ?? "",
      //     snackPosition: SnackPosition.BOTTOM);
      return false;
    } catch (e) {
      //  Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  void updateUser(User user) {
    _firebaseUser.value = user;
  }

  void sendPasswordResetEmail(String email) async {
    try {
      _loading.value = true;
      await _auth.sendPasswordResetEmail(email: email);
      _loading.value = false;

      Get.back();
      // Get.defaultDialog(
      //     content: Text(
      //         "An email has been sent to your mailbox with instructions to reset your password"));
      Get.snackbar("Success",
          "An email has been sent to your mailbox with instructions to reset your password",
          snackPosition: SnackPosition.BOTTOM);
    } on FirebaseAuthException catch (e) {
      _loading.value = false;
      Get.snackbar("Error", e.message!, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteNotificationToken() async {
    // this will make sure that user dont receive any notifications after signout
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseUser.value!.uid)
        .update({'androidNotificationToken': ''});
  }

  void signOut() async {
    try {
      await deleteNotificationToken();
      await sc.StreamChat.of(Get.context!).client.disconnectUser();

      await _auth.signOut();
      if (Get.isRegistered<UserController>()) {
        Get.delete<UserController>();
      }
      if (Get.isRegistered<ActivityController>()) {
        Get.delete<ActivityController>();
      }
      if (Get.isRegistered<StreamFeedController>()) {
        Get.delete<StreamFeedController>();
      }
      if (Get.isRegistered<PostController>()) {
        Get.delete<PostController>();
      }
      if (Get.isRegistered<SearchController>()) {
        Get.delete<SearchController>();
      }
      if (Get.isRegistered<RecentSearchController>()) {
        Get.delete<RecentSearchController>();
      }
      if (Get.isRegistered<AdController>()) {
        Get.delete<AdController>();
      }

      // Get.find<UserController>().clear();
    } on FirebaseAuthException catch (e) {
      print(e);
      Get.snackbar("Error", e.message!, snackPosition: SnackPosition.BOTTOM);
    }
  }
}
