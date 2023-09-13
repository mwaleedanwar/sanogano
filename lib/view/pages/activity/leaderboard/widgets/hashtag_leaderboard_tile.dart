import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/hashtag_model.dart';

import '../../../../widgets/comments_page.dart';
import '../../../../widgets/hashtag_screen.dart';
import '../helpers/leaderboard_type.dart';
import 'leaderboard_tile.dart';

class HashtagLeaderBoardTile extends StatelessWidget {
  final int index;
  final HashtagModel hashtag;
  const HashtagLeaderBoardTile(
      {super.key, required this.index, required this.hashtag});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(HashtagsScreen(
          hashtag: hashtag.id,
          sortMode: SortMode.new_to_old,
        ));
      },
      child: LeaderBoardTile(
        data: hashtag.toMap(),
        dataType: LeaderboardType.hashtags,
        index: index,
      ),
    );
  }
}
