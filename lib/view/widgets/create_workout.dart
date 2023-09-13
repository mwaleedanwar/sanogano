import 'dart:io';
import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/services/algolia_search.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';
import 'workout_controller.dart';

class CreateWorkout extends StatefulWidget {
  final File? workoutImage;
  final bool? skipMode;

  const CreateWorkout({Key? key, this.workoutImage, this.skipMode = false})
      : super(key: key);

  @override
  _CreateWorkoutState createState() => _CreateWorkoutState();
}

class _CreateWorkoutState extends State<CreateWorkout> {
  var userModel = Get.find<UserController>().userModel;

  var workoutNameController = TextEditingController();

  var notesTextController = TextEditingController();

  var exercisesTextController = TextEditingController();

  var formKey = GlobalKey<FormState>();
  String get bullet => "\u2022 ";
  @override
  void initState() {
    workoutNameController.addListener(() {
      setState(() {});
    });
    notesTextController.addListener(() {
      setState(() {});
    });
    exercisesTextController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  bool get readyToPost {
    return workoutNameController.text.isNotEmpty &&
        exercisesTextController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
        title: "Create Workout",
        iconButton: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Opacity(
              opacity: readyToPost ? 1 : 0.5,
              child: TextButton(
                  onPressed: onPressNext,
                  child: Text("Create",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: standardContrastColor)))),
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
                  disableTap: true,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              workoutHeader(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          //  autovalidateMode: AutovalidateMode.always,
          // validator: (value) {
          //   if (value.contains('\n')) {
          //     print("testing");
          //     var arr = value.allMatches('\n').toList();
          //     print(arr.length);
          //     if (arr.length > 7) return "Please add valid notes";
          //   }
          //   return null;
          // },
          buildCounter: (context,
                  {required currentLength, required isFocused, maxLength}) =>
              null,
          maxLength: 130,

          controller: notesTextController,
          minLines: 3,
          maxLines: 7,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Notes",
          ),
        ),
      ],
    );
  }

  var exercises = <String>[];
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
            //     exercisesTextController.clear();
            //   }
            // }
            setState(() {});
          },
          // validator: (value) {
          //   if (value.isEmpty) {
          //     return "Please add exercises";
          //   }
          //   return null;
          // },
          keyboardType: TextInputType.multiline,
          controller: exercisesTextController,
          minLines: 1,
          maxLines: null,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Add Exercises",
          ),
        ),
      ],
    );
  }

  Widget workoutHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: Get.width * 0.5,
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Positioned(
              left: 12,
              top: 0,
              child: Container(
                width: Get.width * 0.45,
                child: descriptionTile(),
              ),
            ),
            Positioned(
              right: 10,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: widget.skipMode!
                    ? SizedBox(
                        height: Get.width * 0.35,
                        width: Get.width * 0.35,
                        child: Image.network(
                          defaultWorkoutImage,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Image.file(
                        widget.workoutImage!,
                        height: Get.width * 0.35,
                        width: Get.width * 0.35,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPressNext() async {
    if (readyToPost) {
      showLoading(loadingText: 'Saving Workout');
      notesTextController.text.replaceAll("\n\n", "\n");
      exercisesTextController.text.replaceAll("\n\n", "\n");
      Get.put(WorkoutController());
      var controller = Get.find<WorkoutController>();
      var workoutModel = WorkoutModel(
        exercises: exercisesTextController.text,
        workoutId: controller.generateId(),
        notes: notesTextController.text,
        ownerId: userModel.id,
        workoutCoverURL: widget.skipMode!
            ? defaultWorkoutImage
            : await FirebaseStorageServices.uploadToStorage(
                isVideo: false,
                file: widget.workoutImage!,
                folderName: "Workouts",
              ),
        workoutName: workoutNameController.text,
      );

      await controller.submitWorkout(workoutModel);

      hideLoading();
      Get.back();
    }
  }
}
