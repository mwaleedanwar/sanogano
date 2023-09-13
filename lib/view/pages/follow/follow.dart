import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/suggestedFriends.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/follow/followers.dart';
import 'package:sano_gano/view/pages/follow/followings.dart';

class FollowPage extends StatelessWidget {
  int tabNumber;
  String username;
  String id;
  FollowPage(this.id, this.username, {this.tabNumber = 0});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: tabNumber,
      length: 2,
      child: Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: username,
          iconButton: Get.find<UserController>().userModel.id == id
              ? InkWell(
                  onTap: () {
                    Get.to(() => SuggestedFriends());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 5),
                    child: suggestedIcon,
                  ),
                )
              : null,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 50,
              child: AppBar(
                backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
                bottom: TabBar(
                  labelColor: !Get.isDarkMode ? Colors.black : Colors.white,
                  indicatorColor: !Get.isDarkMode ? Colors.black : Colors.white,
                  unselectedLabelStyle: TextStyle(
                      // fontSize: 16,

                      ),
                  labelStyle: TextStyle(
                      // fontSize: 16,
                      fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(
                      text: "Followers",
                    ),
                    Tab(
                      text: "Following",
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  FollowerPage(id),
                  FollowingPage(id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
