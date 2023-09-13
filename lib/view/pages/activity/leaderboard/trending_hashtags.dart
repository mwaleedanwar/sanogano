import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/hashtag_model.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/hashtag_leaderboard_tile.dart';

import '../../../../controllers/leaderboard_controller.dart';

class TrendingHashtags extends StatelessWidget {
  TrendingHashtags({super.key});
  LeaderBoardController controller = Get.find<LeaderBoardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<HashtagModel>? hashtagsList = controller.popularHashtags;
      return controller.isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.builder(
              shrinkWrap: false,
              itemCount: hashtagsList!.length,
              itemBuilder: (_, index) {
                HashtagModel _hashtag = hashtagsList[index];
                return HashtagLeaderBoardTile(
                    hashtag: _hashtag, index: index + 1);
              });
    });
  }
}
