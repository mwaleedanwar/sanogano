import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/authentication/login.dart';
import 'package:sano_gano/view/pages/authentication/setup_profile.dart';
import 'auth_controller.dart';

class VerifyController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late User _user;
  late Timer _timer;

  var _isVerified = false.obs;
  bool get isVerified => _isVerified.value;

  @override
  void onInit() {
    sendEmailVerification();

    _timer = Timer.periodic(Duration(seconds: 4), (timer) {
      checkEmailVerified();
    });

    super.onInit();
  }

  void checkEmailVerified() async {
    _user = _auth.currentUser!;
    await _user.reload();

    print("Checking ..");
    if (_user.emailVerified) {
      _isVerified.value = true;

      Get.to(() => ProfileSetUpPage());

      Get.find<AuthController>().updateUser(_user);

      if (_timer.isActive) _timer.cancel();
    }
  }

  void sendEmailVerification() {
    _user = _auth.currentUser!;
    _user.sendEmailVerification();
  }

  void goBackToLogin() {
    Get.find<AuthController>().signOut();
    Get.offAll(LoginPage());
    // Get.back();
    if (_timer.isActive) _timer.cancel();
  }

  @override
  void dispose() {
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }
}
