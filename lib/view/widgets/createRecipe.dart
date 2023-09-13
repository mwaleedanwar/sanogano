import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';

import 'recipe_controller.dart';

class CreateRecipe extends StatefulWidget {
  final File? recipeImage;
  final bool? skipMode;

  const CreateRecipe({Key? key, this.recipeImage, this.skipMode = false})
      : super(key: key);

  @override
  _CreateRecipeState createState() => _CreateRecipeState();
}

class _CreateRecipeState extends State<CreateRecipe> {
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
    // TODO: implement initState
    super.initState();
    recipeNameController.addListener(() {
      setState(() {});
    });
    timeTextController.addListener(() {
      setState(() {});
    });
    servingTextController.addListener(() {
      setState(() {});
    });
    descriptionTextController.addListener(() {
      setState(() {});
    });
    ingredientsTextController.addListener(() {
      setState(() {});
    });
    instructionTextController.addListener(() {
      setState(() {});
    });
  }

  bool get readyToPost {
    return recipeNameController.text.isNotEmpty &&
        timeTextController.text.isNotEmpty &&
        servingTextController.text.isNotEmpty &&
        ingredientsTextController.text.isNotEmpty &&
        instructionTextController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: "Create Recipe",
          iconButton: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Opacity(
                opacity: readyToPost ? 1 : 0.5,
                child: TextButton(
                    onPressed: () async => await onPressNext(),
                    child: Text(
                      "Create",
                      style: TextStyle(
                        color: standardContrastColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ))),
          ),
        ),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  // validator: (value) {
                  //   if (value.trim().isEmpty) return "Please add a name";
                  //   return null;
                  // },
                  maxLength: 52,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
                    disableTap: true,
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
                ),
              ],
            ),
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
          // validator: (value) {
          //   if (value.trim().isEmpty) {
          //     return "Please add a description";
          //   }
          //   return null;
          // },
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

  var ingredients = <String>[];

  Widget ingredientTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ingredients",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // SizedBox(
        //   height: 10,
        // ),
        // if (ingredients.isNotEmpty)
        //   ListView.builder(
        //     shrinkWrap: true,
        //     itemCount: ingredients.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       return Row(
        //         crossAxisAlignment: CrossAxisAlignment.baseline,
        //         textBaseline: TextBaseline.alphabetic,
        //         children: [
        //           Text("- " + ingredients[index]),
        //           Spacer(),
        //           GestureDetector(
        //             onTap: () {
        //               ingredients.removeAt(index);
        //               setState(() {});
        //             },
        //             child: xDIcon,
        //           ),
        //         ],
        //       );
        //     },
        //   ),
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
          // validator: (value) {
          //   if (value.isEmpty) {
          //     return "Please add ingredients";
          //   }
          //   return null;
          // },
          keyboardType: TextInputType.multiline,
          controller: ingredientsTextController,
          minLines: 4,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Ingredients",
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
        // if (instructions.isNotEmpty)
        //   ListView.builder(
        //     shrinkWrap: true,
        //     itemCount: instructions.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       return Row(
        //         children: [
        //           Text("${index + 1}. " + instructions[index]),
        //           Spacer(),
        //           GestureDetector(
        //             onTap: () {
        //               instructions.removeAt(index);
        //               setState(() {});
        //             },
        //             child: xDIcon,
        //           ),
        //         ],
        //       );
        //     },
        //   ),
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
          // validator: (value) {
          //   if (value.isEmpty) {
          //     return "Instructions can't be empty";
          //   }
          //   return null;
          // },
          controller: instructionTextController,
          maxLines: null,
          minLines: 4,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Instructions",
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  timeDIcon,
                  Container(
                    width: Get.width * 0.4,
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      // validator: (value) {
                      //   if (value.isEmpty) return "Please add cooking time";
                      //   return null;
                      // },
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
                      maxLength: 4,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      // validator: (value) {
                      //   if (value.isEmpty) return "Please add serving count";
                      //   if (int.tryParse(value) == null)
                      //     return "Only numbers allowed";
                      //   return null;
                      // },
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
        Container(
            height: Get.width * 0.35,
            width: Get.width * 0.35,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.skipMode!
                    ? Image.network(
                        defaultRecipeImage,
                        fit: BoxFit.contain,
                      )
                    : Image.file(
                        widget.recipeImage!,
                        height: Get.width * 0.35,
                        width: Get.width * 0.35,
                        fit: BoxFit.cover,
                      ))),
      ],
    );
  }

  Future<void> onPressNext() async {
    if (readyToPost) {
      showLoading(loadingText: 'Saving Recipe');
      var controller = Get.put(RecipeController());

      var recipeModel = RecipeModel(
        cookingTimeInMinutes: int.tryParse(timeTextController.text),
        createdOn: DateTime.now(),
        description: descriptionTextController.text,
        ingredients: ingredientsTextController.text,
        instructions: instructionTextController.text,
        ownerId: userModel.id,
        indexedInSearch: false,
        recipeId: controller.generateId(),
        recipeCoverURL: widget.skipMode!
            ? defaultRecipeImage
            : await FirebaseStorageServices.uploadToStorage(
                isVideo: false,
                file: widget.recipeImage!,
                folderName: "Recipes"),
        recipeName: recipeNameController.text,
        servingCount: int.tryParse(servingTextController.text),
      );

      bool isSuccess = await controller.submitRecipe(recipeModel);
      hideLoading();
      if (isSuccess) {
        Get.back();
      } else {
        Fluttertoast.showToast(
            msg: "Something went wrong", timeInSecForIosWeb: 3);
      }
    } else {
      Fluttertoast.showToast(
          msg: "Please fill all the fields", timeInSecForIosWeb: 3);
    }
  }
}
