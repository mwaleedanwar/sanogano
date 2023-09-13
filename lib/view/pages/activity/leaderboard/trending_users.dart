import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/leaderboard_controller.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/helpers/leaderboard_type.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/leaderboard_tile.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/user_learderboard_tile.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../models/user.dart';

class TrendingUsers extends StatelessWidget {
  TrendingUsers({super.key});
  LeaderBoardController controller = Get.find<LeaderBoardController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<UserModel>? usersList = controller.usersModelList;
      String id = Get.find<AuthController>().user!.uid;
      int _index = 0;
      Rx<UserModel?> _myUser = controller.usersModelList!.firstWhereOrNull(
        (element) {
          _index = controller.usersModelList!.indexOf(element);
          return element.id == id;
        },
      ).obs;
      return Scaffold(
        bottomSheet: _myUser.value == null
            ? SizedBox.shrink()
            : Container(
                height: 50,
                margin: EdgeInsets.fromLTRB(3, 0, 3, 30),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Get.isDarkMode ? Colors.white : Colors.black,
                      width: 1),
                ),
                child: UserLeaderBoardTile(
                    index: _index + 1, user: _myUser.value!),
              ),
        body: ListView.builder(
            shrinkWrap: false,
            itemCount: usersList!.length < 100 ? usersList.length : 100,
            itemBuilder: (_, index) {
              UserModel _user = usersList[index];
              return UserLeaderBoardTile(user: _user, index: index + 1);
            }),
      );
    });
  }
}


//* Junk Code:
  // if (_index < 10) {
              //   return UserLeaderBoardTile(user: _user, index: index + 1);
              // } else {
              //   return _user.id != id
              //       ? UserLeaderBoardTile(user: _user, index: index + 1)
              //       : Container();
              // }