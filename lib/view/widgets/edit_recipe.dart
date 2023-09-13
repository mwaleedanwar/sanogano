import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/recipe_controller.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';

class EditRecipe extends StatefulWidget {
  final RecipeModel recipeModel;

  const EditRecipe({Key? key, required this.recipeModel}) : super(key: key);

  @override
  _EditRecipeState createState() => _EditRecipeState();
}

class _EditRecipeState extends State<EditRecipe> {
  var userModel = Get.find<UserController>().userModel;

  var recipeNameController = TextEditingController();

  var timeTextController = TextEditingController();

  var servingTextController = TextEditingController();

  var descriptionTextController = TextEditingController();

  var ingredientsTextController = TextEditingController();

  var instructionTextController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  String get bullet => "\u2022 ";
  @override
  void initState() {
    recipeNameController =
        TextEditingController(text: widget.recipeModel.recipeName);

    timeTextController = TextEditingController(
        text: widget.recipeModel.cookingTimeInMinutes.toString());

    servingTextController =
        TextEditingController(text: widget.recipeModel.servingCount.toString());

    descriptionTextController =
        TextEditingController(text: widget.recipeModel.description);

    ingredientsTextController.text = widget.recipeModel.ingredients!;

    instructionTextController.text = widget.recipeModel.instructions!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Edit Recipe",
        iconButton: TextButton(
            onPressed: onPressNext,
            child: Text(
              "Save",
              style: TextStyle(
                color: standardContrastColor,
              ),
            )),
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
              TextFormField(
                validator: (value) {
                  if (value!.trim().isEmpty) return "Please add a name";
                  return null;
                },
                controller: recipeNameController,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Recipe Name",
                  hintStyle: TextStyle(fontSize: 24),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: DenseUserTag(
                  user: userModel,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              timeServingHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    descriptionTile(),
                    ingredientTile(),
                    instructionTile(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget descriptionTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          validator: (value) {
            if (value!.trim().isEmpty) {
              return "Please add a description";
            }
            return null;
          },
          controller: descriptionTextController,
          minLines: 3,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Description",
          ),
        ),
      ],
    );
  }

  var ingredients = "";
  Widget ingredientTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        // ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: ingredients.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return Row(
        //       children: [
        //         Text("- " + ingredients[index]),
        //         Spacer(),
        //         GestureDetector(
        //           onTap: () {
        //             ingredients.removeAt(index);
        //             setState(() {});
        //           },
        //           child: xDIcon,
        //         ),
        //       ],
        //     );
        //   },
        // ),
        TextFormField(
          onChanged: (value) {
            // if (value.isNotEmpty) if (value[value.length - 1] == "\n") {
            //   if (value.length > 2) {
            //     ingredients.add(value);
            //     ingredientsTextController.clear();
            //   }
            // }
            setState(() {});
          },
          validator: (value) {
            if (value!.isEmpty) {
              return "Please add ingredients";
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          controller: ingredientsTextController,
          minLines: 1,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "-  Add Ingredients",
          ),
        ),
      ],
    );
  }

  var instructions = <String>[];
  Widget instructionTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Instructions",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        // ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: instructions.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return Row(
        //       children: [
        //         Text("${index + 1}. " + instructions[index]),
        //         Spacer(),
        //         GestureDetector(
        //           onTap: () {
        //             instructions.removeAt(index);
        //             setState(() {});
        //           },
        //           child: xDIcon,
        //         ),
        //       ],
        //     );
        //   },
        // ),
        TextFormField(
          onChanged: (value) {
            // if (value.isNotEmpty) if (value[value.length - 1] == "\n") {
            //   if (value.length > 2) {
            //     instructions.add(value);
            //     instructionTextController.clear();
            //   }
            // }
            setState(() {});
          },
          validator: (value) {
            if (value!.isEmpty) {
              return "Instructions can't be empty";
            }
            return null;
          },
          controller: instructionTextController,
          maxLines: null,
          minLines: 1,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "1. Add Instructions",
          ),
        ),
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

  String putComma(String str) {
    if (str.length > 3) {
      var s = str[0] + "," + str[1] + str[2] + str[3];
      return s;
    } else {
      return str;
    }
  }

  Widget timeServingHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: Get.width * 0.5,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    timeDIcon,
                    Container(
                      width: Get.width * 0.4,
                      child: TextFormField(
                        buildCounter: (context,
                                {required currentLength,
                                required isFocused,
                                maxLength}) =>
                            null,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) return "Please add cooking time";
                          return null;
                        },
                        controller: timeTextController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Time (Minutes)",
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    servingDIcon,
                    Container(
                      width: Get.width * 0.4,
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) return "Please add serving count";
                          if (int.tryParse(value) == null)
                            return "Only numbers allowed";
                          return null;
                        },
                        buildCounter: (context,
                                {required currentLength,
                                required isFocused,
                                maxLength}) =>
                            null,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        controller: servingTextController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: "Servings",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: changePicture,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageFile != null
                ? Image.file(
                    imageFile!,
                    height: Get.width * 0.45,
                    width: Get.width * 0.45,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    isDefault
                        ? defaultRecipeImage
                        : widget.recipeModel.recipeCoverURL!,
                    height: Get.width * 0.45,
                    width: Get.width * 0.45,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }

  var isDefault = false;

  void onPressNext() async {
    try {
      showLoading(
        loadingText: 'Updating Recipe',
      );
      Get.put(RecipeController());
      var controller = Get.find<RecipeController>();
      var model = RecipeModel(
        recipeId: widget.recipeModel.recipeId,
        cookingTimeInMinutes: int.tryParse(timeTextController.text),
        createdOn: DateTime.now(),
        description: descriptionTextController.text,
        ingredients: ingredientsTextController.text,
        instructions: instructionTextController.text,
        ownerId: userModel.id,
        recipeCoverURL: imageFile != null
            ? await FirebaseStorageServices.uploadToStorage(
                isVideo: false, file: imageFile!, folderName: "Recipes")
            : isDefault
                ? defaultRecipeImage
                : widget.recipeModel.recipeCoverURL,
        recipeName: recipeNameController.text,
        servingCount: int.tryParse(servingTextController.text),
      );
      await controller.updateRecipe(model);
      hideLoading();
      Get.back();
    } catch (e) {
      print(e);
    }
  }

  File? imageFile;
  void changePicture() async {
    imageFile = await showImagePicker(
      context,
      //  skipMode: true,
      removeCallback: () {
        imageFile = null;
        isDefault = true;
        setState(() {});
      },
    );
    if (imageFile != null) {
      setState(() {
        isDefault = false;
      });
    }
  }
}
