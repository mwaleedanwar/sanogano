import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/recipe_leaderboard_tile.dart';

import '../../../../controllers/leaderboard_controller.dart';

class TrendingRecipes extends StatelessWidget {
  TrendingRecipes({super.key});
  LeaderBoardController controller = Get.find<LeaderBoardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<RecipeModel>? hashtagsList = controller.popularRecipes;
      return controller.isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.builder(
              shrinkWrap: false,
              itemCount: hashtagsList!.length,
              itemBuilder: (_, index) {
                RecipeModel _recipe = hashtagsList[index];
                return RecipeLeaderBoardTile(recipe: _recipe, index: index + 1);
              });
    });
  }
}
