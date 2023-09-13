import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/helpers/leaderboard_type.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/leaderboard_tile.dart';

import '../../../../../controllers/auth_controller.dart';
import '../../../../../controllers/follow_controller.dart';
import '../../../../../models/user.dart';
import '../../../profile/profile.dart';

class UserLeaderBoardTile extends StatelessWidget {
  final int index;
  final UserModel user;
  const UserLeaderBoardTile(
      {super.key, required this.index, required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ProfilePage(userID: user.id!));
        Get.put<FollowController>(FollowController());
        var id = Get.find<AuthController>().user!.uid;
        Get.find<FollowController>().checkFollowed(id, user.id!);
      },
      child: LeaderBoardTile(
        data: user.toMap(),
        dataType: LeaderboardType.users,
        index: index,
      ),
    );
  }
}
