import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/view/pages/search/recipe_tile_widget.dart';
import 'package:sano_gano/view/pages/search/search_item_widget.dart';

import '../../../models/recipeModel.dart';
import '../../widgets/view_recipe.dart';
import 'build_initial.dart';

class RecipeSearchScreen extends StatelessWidget {
  RecipeSearchScreen({super.key});
  SearchController sc = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // _currentScreen.value = 2;
      return Column(children: <Widget>[
        Expanded(
            child: sc.isHitListEmpty && sc.textFieldController.text.isEmpty
                ? BuildInitial(index: 2)
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ...List.generate(sc.searchCount, (index) {
                          var snapshot = sc.hitsList![index];

                          var recipe = RecipeModel.fromMap(snapshot.data);
                          if (recipe.recipeId == null) return SizedBox();
                          return SearchItemWidget(
                            id: recipe.recipeId!,
                            onTap: () =>
                                Get.to(ViewRecipe(recipeModel: recipe)),
                            map: recipe.toMap(),
                            child: RecipeSearchTile(recipe: recipe),
                          );
                        })
                      ],
                    ),
                  )),
      ]);
    });
  }
}
