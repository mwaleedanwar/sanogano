import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/view/widgets/view_recipe.dart';

import '../helpers/leaderboard_type.dart';
import 'leaderboard_tile.dart';

class RecipeLeaderBoardTile extends StatelessWidget {
  final int index;
  final RecipeModel recipe;
  const RecipeLeaderBoardTile(
      {super.key, required this.index, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => ViewRecipe(recipeModel: recipe),
          transition: Transition.rightToLeft),
      child: LeaderBoardTile(
        data: recipe.toMap(),
        dataType: LeaderboardType.recipes,
        index: index,
      ),
    );
  }
}
