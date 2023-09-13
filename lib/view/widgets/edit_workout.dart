import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';

import 'workout_controller.dart';

class EditWorkout extends StatefulWidget {
  final WorkoutModel workoutModel;

  const EditWorkout({Key? key, required this.workoutModel}) : super(key: key);

  @override
  _EditWorkoutState createState() => _EditWorkoutState();
}

class _EditWorkoutState extends State<EditWorkout> {
  var userModel = Get.find<UserController>().userModel;

  var workoutNameController = TextEditingController();

  var descriptionTextController = TextEditingController();

  var excercisesTextController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  String get bullet => "\u2022 ";
  @override
  void initState() {
    workoutNameController =
        TextEditingController(text: widget.workoutModel.workoutName);

    descriptionTextController =
        TextEditingController(text: widget.workoutModel.notes);

    excercisesTextController.text = widget.workoutModel.exercises!;

    super.initState();
  }

  var isDefault = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Edit Workout",
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
      //   child: Text("Created ${DateFormat.MMMd().format(widget.recipeModel.createdOn)}"),
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
                controller: workoutNameController,
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Workout Name",
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
              noteAndHeader(),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 10, top: 20),
                child: Column(
                  children: [
                    exercisesTile(),
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
            // if (value.trim().isEmpty) {
            //   return "Please add a description";
            // }
            return null;
          },
          controller: descriptionTextController,
          minLines: 3,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Notes",
          ),
        ),
      ],
    );
  }

  var exercises = "";
  Widget exercisesTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Exercises",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 10,
        ),
        // ListView.builder(
        //   shrinkWrap: true,
        //   itemCount: exercises.length,
        //   itemBuilder: (BuildContext context, int index) {
        //     return Row(
        //       children: [
        //         Text(exercises[index]),
        //         Spacer(),
        //         GestureDetector(
        //           onTap: () {
        //             exercises.removeAt(index);
        //             setState(() {});
        //           },
        //           child: Text(
        //             "X",
        //             style: TextStyle(
        //               color: Colors.red,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // ),
        TextFormField(
          onChanged: (value) {
            // if (value.isNotEmpty) if (value[value.length - 1] == "\n") {
            //   if (value.length > 2) {
            //     exercises.add(value);
            //     excercisesTextController.clear();
            //   }
            // }
            setState(() {});
          },
          validator: (value) {
            if (value!.isEmpty) {
              return "Please add exercises";
            }
            return null;
          },
          keyboardType: TextInputType.multiline,
          controller: excercisesTextController,
          minLines: 1,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Exercise",
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

  Widget noteAndHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: Get.width * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextFormField(
                validator: (value) {
                  // if (value.trim().isEmpty) {
                  //   return "Please add a description";
                  // }
                  return null;
                },
                controller: descriptionTextController,
                minLines: 3,
                maxLines: 7,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Add Notes",
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: changePicture,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: imageFile != null
                ? Image.file(
                    imageFile!,
                    height: Get.width * 0.45,
                    width: Get.width * 0.45,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    isDefault
                        ? defaultWorkoutImage
                        : widget.workoutModel.workoutCoverURL!,
                    height: Get.width * 0.45,
                    width: Get.width * 0.45,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }

  void onPressNext() async {
    showLoading(loadingText: 'Updating Workout');
    Get.put(WorkoutController());
    var controller = Get.find<WorkoutController>();
    var model = WorkoutModel(
        exercises: excercisesTextController.text,
        ownerId: userModel.id,
        workoutCoverURL: imageFile != null
            ? await FirebaseStorageServices.uploadToStorage(
                isVideo: false, file: imageFile!, folderName: "Workout")
            : isDefault
                ? defaultWorkoutImage
                : widget.workoutModel.workoutCoverURL,
        workoutName: workoutNameController.text,
        notes: descriptionTextController.text,
        workoutId: widget.workoutModel.workoutId);
    await controller.updateWorkout(model);
    hideLoading();
    Get.back();
  }

  File? imageFile;
  void changePicture() async {
    imageFile = await showImagePicker(
      context,
      // skipMode: true,
      // skipText: "Trash",
      removeCallback: () {
        isDefault = true;
        imageFile = null;

        setState(() {});
      },
    );
    if (imageFile != null) {
      setState(() {});
    }
  }
}
