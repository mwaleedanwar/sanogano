import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/verify_controller.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/authentication/widgets/auth_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/bottom_text.dart';
import 'package:sano_gano/view/pages/authentication/widgets/custom_button.dart';

class VerifyEmailPage extends StatelessWidget {
  /* FirebaseAuth _auth = FirebaseAuth.instance ;
  User _user ;
  Timer _timer ;*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // bottomSheet: Container(
      //   color: Colors.white,
      //   child: Align(
      //       heightFactor: 1,
      //       alignment: Alignment.bottomCenter,
      //       child: TextButton(
      //           style: ButtonStyle(
      //             backgroundColor:
      //                 MaterialStateProperty.all<Color>(Colors.white),
      //           ),
      //           onPressed: () {
      //             Get.find<VerifyController>().goBackToLogin();
      //           },
      //           child: Text(
      //             "Already Have an Account?",
      //             style: TextStyle(
      //                 color: Color(0xFF42538D), fontWeight: FontWeight.bold),
      //           ))),
      // ),
      body: GetX<VerifyController>(
        init: Get.put(VerifyController()),
        builder: (VerifyController controller) {
          return Container(
            width: Get.width,
            margin: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                AuthText("Confirm Your Account", 17.0),
                addHeight(20),
                controller.isVerified
                    ? Text("Verified")
                    : Container(
                        width: Get.width * 0.8,
                        child: Text(
                          "Follow the link sent to your email address to confirm your account.",
                          textAlign: TextAlign.center,
                        )),
                addHeight(20),
                Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      controller.sendEmailVerification();
                      Get.snackbar("Success", "Check Your Email Inbox",
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    child: Container(
                      height: 40.0,
                      width: Get.width * 0.8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Resend Email Verification",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                BottomText(
                  "Already Have an Account?",
                  () {
                    Get.find<VerifyController>().goBackToLogin();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

/*  void checkEmailVerified() async {
    _user = _auth.currentUser ;
    await _user.reload();

    print("Checking ..");
    if(_user.emailVerified){
      Get.to(()=> ProfileSetUpPage());
      Get.find<AuthController>().updateUser(_user);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }*/

}
