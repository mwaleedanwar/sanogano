import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/dialog.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/edit_recipe.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';

import 'recipe_controller.dart';

class ViewRecipe extends StatefulWidget {
  RecipeModel? recipeModel;

  ViewRecipe({required this.recipeModel});

  @override
  _ViewRecipeState createState() => _ViewRecipeState();
}

enum AttachmentOptions { Edit, Delete }

class _ViewRecipeState extends State<ViewRecipe> {
  var userModel = Get.find<UserController>().userModel;
  var uc = Get.find<UserController>();
  var formKey = GlobalKey<FormState>();
  String get bullet => "\u2022 ";

  @override
  void initState() {
    super.initState();
  }

  String putComma(String str) {
    if (str.length > 3) {
      var s = str[0] + "," + str[1] + str[2] + str[3];
      return s;
    } else {
      return str;
    }
  }

  Widget buildRecipeOptions() {
    return PopupMenuButton<AttachmentOptions>(
      icon: optionsSIcon,
      onSelected: (value) {
        switch (value) {
          case AttachmentOptions.Edit:
            onPressAction(value);

            break;
          case AttachmentOptions.Delete:
            onPressAction(value);

            break;
          default:
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<AttachmentOptions>(
          value: AttachmentOptions.Edit,
          child: Text("Edit"),
        ),
        PopupMenuItem<AttachmentOptions>(
          value: AttachmentOptions.Delete,
          child: Text("Delete"),
        ),
      ],
    );
  }

  var db = Database();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<RecipeController>(
      init: RecipeController(),
      initState: (_) {},
      builder: (rController) {
        return Scaffold(
          appBar: CustomAppBar(
            multiline: true,
            back: true,
            title: widget.recipeModel?.recipeName ?? "",
            iconButton: widget.recipeModel!.ownerId != userModel.id
                ? StreamBuilder<bool>(
                    stream: rController
                        .isSavedStream(widget.recipeModel!.recipeId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        print("no data");
                        return Container(
                          width: 10,
                        );
                      }
                      return IconButton(
                          onPressed: () async {
                            await rController.toggleSave(
                                widget.recipeModel!, snapshot.data!);
                            setState(() {});
                          },
                          icon: (snapshot.data!) ? savedDIcon : saveDIcon);
                    })
                : buildRecipeOptions(),
          ),
          // bottomSheet: Container(
          //   height: Get.height * 0.05,
          //   color: Colors.transparent,
          //   alignment: Alignment.bottomCenter,
          //   child: Text(
          //       "Created ${DateFormat.MMMd().format(widget.recipeModel.createdOn)}"),
          // ),
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: FutureBuilder<UserModel?>(
                        future: UserDatabase()
                            .getUser(widget.recipeModel!.ownerId!),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return SizedBox(
                              height: 20,
                            );
                          return DenseUserTag(
                            user: snapshot.data!,
                          );
                        }),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(child: timeServingHeader()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        descriptionTile(),
                        SizedBox(
                          height: 10,
                        ),
                        ingredientTile(),
                        SizedBox(
                          height: 10,
                        ),
                        instructionTile(),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget descriptionTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Description",
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Container(
          constraints: BoxConstraints(
            minHeight: Get.height * 0.07,
          ),
          child: Text(
            widget.recipeModel!.description!,
            style: TextStyle(fontSize: 15),
          ),
        ),
        SizedBox(
          height: 10,
        ),
      ],
    );
  }

  var ingredients = "";
  Widget ingredientTile() {
    ingredients = widget.recipeModel!.ingredients!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            constraints: BoxConstraints(
              minHeight: Get.height * 0.07,
            ),
            child: Text(ingredients)),
        SizedBox(
          height: 5,
        ),
        // ListView.builder(
        //   physics: ClampingScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: ingredients.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return Row(
        //       textBaseline: TextBaseline.ideographic,
        //       crossAxisAlignment: CrossAxisAlignment.baseline,
        //       children: [
        //         Expanded(
        //             flex: 4,
        //             child: Text(
        //               bullet + " " + ingredients[index],
        //               style: TextStyle(fontSize: 15),
        //             )),
        //       ],
        //     );
        //   },
        // ),
      ],
    );
  }

  var instructions = "";
  Widget instructionTile() {
    instructions = widget.recipeModel!.instructions!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Instructions",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(
          height: 10,
        ),
        // ListView.builder(
        //   physics: ClampingScrollPhysics(),
        //   shrinkWrap: true,
        //   itemCount: instructions.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return Row(
        //       textBaseline: TextBaseline.ideographic,
        //       crossAxisAlignment: CrossAxisAlignment.baseline,
        //       children: [
        //         Expanded(
        //             flex: 4,
        //             child: Text(
        //               "${index + 1}.  " + instructions[index],
        //               style: TextStyle(fontSize: 15),
        //             )),
        //       ],
        //     );
        //   },
        // ),
        Text(instructions),
      ],
    );
  }

  Widget roomNameWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 10,
        ),
        SizedBox(
          width: 10,
        ),
        Text("Room name"),
      ],
    );
  }

  Widget timeServingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: Get.width * 0.5,
          padding: EdgeInsets.only(left: Get.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  timeDIcon,
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    putComma(widget.recipeModel!.cookingTimeInMinutes
                            .toString()) +
                        " Minutes",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  servingDIcon,
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    putComma(widget.recipeModel!.servingCount.toString()) +
                        " Servings",
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: Get.width * 0.025),
          child: GestureDetector(
            onTap: null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                  widget.recipeModel!.isDefaultImage ? 8 : 15),
              child: Container(
                height: Get.width * 0.45,
                width: Get.width * 0.45,
                child: Image.network(
                  widget.recipeModel!.recipeCoverURL!,
                  height: Get.width * 0.45,
                  width: Get.width * 0.45,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void onPressAction(AttachmentOptions option) async {
    var c = Get.put(RecipeController());
    if (option == AttachmentOptions.Edit) {
      if (widget.recipeModel!.ownerId == userModel.id) {
        await Get.to(() => EditRecipe(
              recipeModel: widget.recipeModel!,
            ));
      }
      var controller = Get.find<RecipeController>();
      widget.recipeModel =
          await controller.getRecipe(widget.recipeModel!.recipeId!);
      setState(() {});
    } else if (option == AttachmentOptions.Delete) {
      await sgDialog(
          message: "Are You Sure?",
          onConfirm: () async {
            Get.back();
            print(widget.recipeModel!.recipeId);
            await c.deleteRecipe(widget.recipeModel!.recipeId!);

            Get.back();
          });
      // await Get.defaultDialog(
      //   title: "Alert!",
      //   content: Text("Are You Sure?"),
      //   confirm: TextButton(
      //       onPressed: () async {
      //         await c.unsaveRecipe(widget.recipeModel.recipeId);
      //       },
      //       child: Text("Delete", style: TextStyle(color: Colors.red))),
      //   cancel: TextButton(
      //       onPressed: () => Get.back(),
      //       child: Text(
      //         "Cancel",
      //         style: TextStyle(
      //             color: !Get.isDarkMode ? Colors.black : Colors.white),
      //       )),
      // );
      // await Get.defaultDialog(
      //   content: Text("Are you sure you want to delete the Recipe?"),
      //   onConfirm: () async {
      //     await c.unsaveRecipe(widget.recipeModel.recipeId);

      //     Get.back();
      //   },
      // );
    }
  }

  File? imageFile;
  void changePicture() async {
    imageFile = await showImagePicker(context);
    if (imageFile != null) {
      setState(() {});
    }
  }

  void saveRecipe() {}
}
