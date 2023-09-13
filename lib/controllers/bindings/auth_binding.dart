import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/activity_controller.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/chat_controller.dart';
import 'package:sano_gano/controllers/editprofile_controller.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/helpers/scroll_focus_controller_helper.dart';
import 'package:sano_gano/controllers/leaderboard_controller.dart';
import 'package:sano_gano/controllers/recent_search_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';

import '../search_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(context: Get.context!));
    Get.lazyPut<LeaderBoardController>(() => LeaderBoardController());
    Get.lazyPut<SearchController>(() => SearchController());
    Get.lazyPut<RecentSearchController>(() => RecentSearchController());
    Get.lazyPut<ScrollAndFocusControllerHelper>(
        () => ScrollAndFocusControllerHelper());
    // Get.lazyPut<EditProfileController>(()=>EditProfileController());

    Get.lazyPut<UserController>(
      () => UserController(),
      fenix: true,
    );
    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
