import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/components/paginated_widgets.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/widgets/profile_image.dart';
import 'package:sano_gano/view/widgets/createRecipe.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/gym_page.dart';
import 'package:sano_gano/view/widgets/popup_menu_builder.dart';
import 'package:sano_gano/view/widgets/view_recipe.dart';

import '../../controllers/helpers/scroll_focus_controller_helper.dart';
import 'recipe_controller.dart';

class CookbookPage extends StatefulWidget {
  final bool? selectionMode;
  final Function(RecipeModel)? onRecipeSelectedCallback;
  final String? uid;
  final String? username;
  final bool? healthMode;
  final bool? isRoot;
  final bool isFromCreatePost;
  CookbookPage(
      {Key? key,
      this.selectionMode = false,
      this.onRecipeSelectedCallback,
      this.uid,
      this.username,
      this.isRoot = false,
      this.healthMode = false,
      this.isFromCreatePost = false})
      : super(key: key);

  @override
  State<CookbookPage> createState() => _CookbookPageState();
}

class _CookbookPageState extends State<CookbookPage> {
  final db = Database();

  var gymMode = false;

  bool get isCurrentUser => Get.find<UserController>().currentUid == widget.uid;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecipeController>(
      init: RecipeController(),
      initState: (_) {
        gymMode = isGymMode;
        isGymMode = false;
      },
      builder: (controller) {
        if (gymMode && isCurrentUser)
          return GymPage(
            healthMode: true,
            onCookbookPressedCallback: () {
              gymMode = !gymMode;
              controller.update();
            },
            uid: widget.uid!,
            isRoot: true,
            username: widget.username!,
          );

        return Scaffold(
          appBar: CustomAppBar(
            onTapTitle: () {
              if (widget.selectionMode ?? false) return;
              sfc.healthPageScrollController.animateTo(0,
                  duration: Duration(milliseconds: 500), curve: Curves.ease);
            },
            leading: IconButton(
                onPressed: () {
                  if (widget.healthMode!) {
                    gymMode = !gymMode;
                    controller.update();
                  }
                },
                icon: gymIcon),
            multiline: true,
            back: !widget.healthMode!,
            title: widget.selectionMode!
                ? "Select Recipe"
                : isCurrentUser
                    ? "Cookbook"
                    : "${widget.username}'s Cookbook",
            iconButton: !isCurrentUser
                ? buildPopupMenu([
                    PopupItem(
                        title: "Save All",
                        callback: () async {
                          controller.saveAllRecipes(widget.uid!);
                        })
                  ])
                : !widget.isRoot!
                    ? Container()
                    : IconButton(
                        onPressed: () => createRecipe(
                            isFromCreatePost: widget.isFromCreatePost),
                        icon: addIcon),
          ),
          body: buildCookbookBody(controller),
        );
      },
    );
  }

  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();
  Padding buildCookbookBody(RecipeController controller) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<Object>(
          stream: controller.db.savedRecipes(widget.uid!).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return Center(
                child: Text("No Recipes"),
              );
            }

            return buildPaginatedGrid(
                controller.db
                    .savedRecipes(widget.uid!)
                    // .orderBy("recipeName") //Removed for [client said to sort from most recent to old]
                    .orderBy('timestamp', descending: true), (_, docs, index) {
              return StreamBuilder<RecipeModel?>(
                  stream: db.getRecipeStream(docs[index].id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    RecipeModel recipe = snapshot.data!;
                    return buildMiniRecipe(recipe);
                  });
            },
                emptyText: "",
                fontSize: context.theme.textTheme.bodyMedium?.fontSize);
          }),
    );
  }

  void createRecipe({bool isFromCreatePost = false}) async {
    var result = await showImagePicker(Get.context,
        squareMode: true, recipeMode: true, skipMode: true, onSkip: () async {
      if (!isFromCreatePost) {
        Get.back();
      }
      0.75.seconds.delay().then((value) async {
        await Get.to(CreateRecipe(
          recipeImage: null,
          skipMode: true,
        ));
        setState(() {});
      });
    });

    if (result != null) {
      Get.back();
      0.75.seconds.delay().then((value) async {
        await Get.to(CreateRecipe(
          recipeImage: result,
        ));
        setState(() {});
      });
    }
  }

  Widget buildMiniRecipe(RecipeModel recipe) {
    return GestureDetector(
      onTap: () async {
        widget.selectionMode!
            ? widget.onRecipeSelectedCallback!(recipe)
            : await Get.to(() {
                print(recipe.recipeCoverURL);
                return ViewRecipe(
                  recipeModel: recipe,
                );
              });
        setState(() {});
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(recipe.isDefaultImage ? 8 : 8),
            child: Image.network(
              recipe.recipeCoverURL!,
              height: Get.width * 0.3,
              width: Get.width * 0.3,
              fit: recipe.recipeCoverURL == defaultRecipeImage
                  ? BoxFit.contain
                  : BoxFit.cover,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Expanded(
            child: AutoSizeText(
              recipe.recipeName! + "\n",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 8),
            ),
          ),
          SizedBox(
            height: 5,
          )
        ],
      ),
    );
    // return StreamBuilder<RecipeModel?>(
    //     stream: db.getRecipeStream(recipeId),
    //     builder: (context, snapshot) {
    //       // if (snapshot.connectionState == ConnectionState.waiting) {
    //       //   return SizedBox(
    //       //     height: Get.width * 0.3,
    //       //     width: Get.width * 0.3,
    //       //     child: Shimmer.fromColors(
    //       //       baseColor: Colors.black45,
    //       //       highlightColor: Colors.grey[100]!,
    //       //       child: Column(
    //       //         children: [
    //       //           Container(
    //       //             height: Get.width * 0.3,
    //       //             width: Get.width * 0.3,
    //       //             child: Text(""),
    //       //             color: Colors.black45,
    //       //           ),
    //       //           SizedBox(
    //       // //             height: 5,
    //       // //           ),
    //       // //           Container(
    //       // //             height: Get.width * 0.05,
    //       // //             width: Get.width * 0.3,
    //       // //             child: Text(""),
    //       // //             color: Colors.black45,
    //       // //           ),
    //       // //         ],
    //       // //       ),
    //       // //     ),
    //       // //   );
    //       // // }
    //       // if (!snapshot.hasData) return SizedBox();
    //       // // return SizedBox(
    //       // //   height: Get.width * 0.3,
    //       // //   width: Get.width * 0.3,
    //       // //   child: Shimmer.fromColors(
    //       // //     baseColor: Colors.black45,
    //       // //     highlightColor: Colors.grey[100]!,
    //       // //     child: Column(
    //       // //       children: [
    //       // //         Container(
    //       // //           height: Get.width * 0.3,
    //       // //           width: Get.width * 0.3,
    //       // //           child: Text(""),
    //       // //           color: Colors.black45,
    //       // //         ),
    //       // //         SizedBox(
    //       // //           height: 5,
    //       // //         ),
    //       // //         Container(
    //       // //           height: Get.width * 0.05,
    //       // //           width: Get.width * 0.3,
    //       // //           child: Text(""),
    //       // //           color: Colors.black45,
    //       // //         ),
    //       // //       ],
    //       // //     ),
    //       // //   ),
    //       // // );
    //       // var recipe = snapshot.data;
    //       // if (recipe == null) return SizedBox();
    //       // print(recipe!.recipeName);
    //       return Container(
    //         height: 100,
    //         width: 100,
    //         decoration: BoxDecoration(color: Colors.black),
    //       );
    //       return GestureDetector(
    //         onTap: () async {
    //           widget.selectionMode!
    //               ? widget.onRecipeSelectedCallback!(recipe)
    //               : await Get.to(() => ViewRecipe(
    //                     recipeModel: recipe,
    //                   ));
    //           setState(() {});
    //         },
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             ClipRRect(
    //               borderRadius:
    //                   BorderRadius.circular(recipe.isDefaultImage ? 8 : 8),
    //               child: OptimizedCacheImage(
    //                 imageUrl: recipe.recipeCoverURL!,
    //                 height: Get.width * 0.3,
    //                 width: Get.width * 0.3,
    //                 fit: recipe.recipeCoverURL == defaultRecipeImage
    //                     ? BoxFit.contain
    //                     : BoxFit.cover,
    //                 errorWidget: (context, url, error) => SvgPicture.asset(
    //                     cookbookIconAsset,
    //                     fit: BoxFit.contain),
    //               ),
    //             ),
    //             SizedBox(
    //               height: 5,
    //             ),
    //             Expanded(
    //               child: AutoSizeText(
    //                 recipe.recipeName! + "\n",
    //                 maxLines: 2,
    //                 overflow: TextOverflow.ellipsis,
    //                 textAlign: TextAlign.center,
    //                 style:
    //                     TextStyle(fontWeight: FontWeight.normal, fontSize: 8),
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     });
  }
}
