import 'package:flutter/material.dart';
import 'package:sano_gano/models/postmodel.dart';

import '../helpers/leaderboard_type.dart';
import 'leaderboard_tile.dart';

class PostLeaderBoardTile extends StatelessWidget {
  final int index;
  final PostModel post;
  const PostLeaderBoardTile(
      {super.key, required this.index, required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: LeaderBoardTile(
        data: post.toMap(),
        dataType: LeaderboardType.posts,
        index: index,
      ),
    );
  }
}
