import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart'
    as refresher;
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/view/pages/notFoundPages/recipe_not_found.dart';
import 'package:sano_gano/view/pages/notFoundPages/workout_not_found.dart';
import 'package:sano_gano/view/pages/search/recipe_tile_widget.dart';
import 'package:sano_gano/view/pages/search/search_item_widget.dart';
import 'package:sano_gano/view/pages/search/workout_search_tile.dart';
import 'package:sano_gano/view/widgets/custom_refresher.dart';

import '../../../models/hashtag_model.dart';
import '../../../models/recipeModel.dart';
import '../../../models/user.dart';
import '../../../models/workoutModel.dart';
import '../../widgets/custom_refresher.dart';
import '../../widgets/user_header_tile.dart';
import '../../widgets/view_recipe.dart';
import '../../widgets/view_workout.dart';
import 'hashtag_search_tile.dart';

class BuildInitial extends StatefulWidget {
  final int index;
  BuildInitial({super.key, required this.index});

  @override
  State<BuildInitial> createState() => _BuildInitialState();
}

class _BuildInitialState extends State<BuildInitial> {
  SearchController sc = Get.find<SearchController>();

  refresher.RefreshController controller = refresher.RefreshController();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (sc.isInitialDataEmpty) {
        return Container();
      } else {
        return RefreshWidget(
          controller: controller,
          onRefresh: () async {
            await sc.loadInitialTrendingData();
            controller.refreshCompleted();
            setState(() {});
          },
          child: ListView.builder(
            itemCount: sc.initialTrendingData[widget.index]!.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (_, i) {
              var data = sc.initialTrendingData[widget.index]![i];
              // print(data);
              switch (widget.index) {
                case 0:
                  return UserHeaderTile(
                    uid: data['id'],
                    userModel: UserModel.fromJson(data),
                    viewFollow: true,
                    withFollowers: true,
                    searchMode: true,
                    isFromSearch: true,
                  );
                case 1:
                  return HashtagSearchTile(
                    hashtagModel: HashtagModel.fromMap(data),
                  );
                case 2:
                  RecipeModel recipe = RecipeModel.fromMap(data);
                  return SearchItemWidget(
                    id: recipe.recipeId!,
                    onTap: () async {
                      bool isExist = await sc.getRecipe(recipe.recipeId!);
                      if (isExist) {
                        Get.to(() => ViewRecipe(recipeModel: recipe));
                      } else {
                        Get.to(() => RecipeNotFound());
                      }
                    },
                    map: recipe.toMap(),
                    child: RecipeSearchTile(recipe: recipe),
                  );
                case 3:
                  WorkoutModel workout = WorkoutModel.fromMap(data);
                  return SearchItemWidget(
                    id: workout.workoutId!,
                    onTap: () async {
                      bool isExist = await sc.getWorkout(workout.workoutId!);
                      if (isExist) {
                        Get.to(() => ViewWorkout(
                              workoutModel: workout,
                            ));
                      } else {
                        Get.to(() => WorkoutNotFound());
                      }
                    },
                    map: workout.toMap(),
                    child: WorkoutSearchTile(workout: workout),
                  );
                default:
                  return Container();
              }
            },
          ),
        );
      }
    });
  }
}
