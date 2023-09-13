import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/post_leaderboard_tile.dart';

import '../../../../controllers/leaderboard_controller.dart';

class PopularPost extends StatelessWidget {
  PopularPost({super.key});
  LeaderBoardController controller = Get.find<LeaderBoardController>();

  @override
  Widget build(BuildContext context) {
    List<PostModel>? postsList = controller.popularPosts;
    return controller.isLoading
        ? Center(
            child: CircularProgressIndicator.adaptive(),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(postsList!.length, (index) {
                  return PostLeaderBoardTile(
                      post: postsList[index], index: index + 1);
                })
                // for (int i = 0; i < postsList!.length; i++)
                //   PostLeaderBoardTile(post: postsList[i], index: i + 1),
              ],
            ),
          );
  }
}
