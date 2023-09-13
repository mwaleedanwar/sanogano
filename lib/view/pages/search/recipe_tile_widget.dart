import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/models/recipeModel.dart';

import '../../widgets/user_header_tile.dart';
import '../../widgets/view_recipe.dart';

class RecipeSearchTile extends StatelessWidget {
  final RecipeModel recipe;
  const RecipeSearchTile({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: () => Get.to(ViewRecipe(
      //   recipeModel: recipe,
      // )),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          recipe.recipeCoverURL ?? "",
          fit: BoxFit.cover,
          height: Get.width * 0.1,
          width: Get.width * 0.1,
        ),
      ),
      title: Text(
        recipe.recipeName ?? "No Name",
        maxLines: 2,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UsernameWidget(
            uid: recipe.ownerId!,
          ),
          Text(
            recipe.saveCount.toString() +
                " Save${recipe.saveCount == 1 ? '' : 's'}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
