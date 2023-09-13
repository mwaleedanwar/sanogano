import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/edit_workout.dart';
import 'package:sano_gano/view/widgets/user_tile_dense.dart';
import 'package:sano_gano/view/widgets/view_recipe.dart';
import 'package:sano_gano/view/widgets/workout_controller.dart';

class ViewWorkout extends StatefulWidget {
  WorkoutModel workoutModel;
  ViewWorkout({
    required this.workoutModel,
  });

  @override
  _ViewWorkoutState createState() => _ViewWorkoutState();
}

class _ViewWorkoutState extends State<ViewWorkout> {
  var userModel = Get.find<UserController>().userModel;

  var formKey = GlobalKey<FormState>();
  String get bullet => "\u2022 ";
  @override
  void initState() {
    super.initState();
  }

  Widget buildWorkoutOptions() {
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkoutController>(
      init: WorkoutController(),
      initState: (_) {},
      builder: (wController) {
        return Scaffold(
          appBar: CustomAppBar(
            multiline: true,
            back: true,
            title: widget.workoutModel.workoutName,
            iconButton: widget.workoutModel.ownerId != userModel.id
                ? StreamBuilder<bool>(
                    stream: wController
                        .isSavedStream(widget.workoutModel.workoutId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false)
                        return Container(
                          width: 10,
                        );
                      return IconButton(
                        onPressed: () async {
                          await wController.toggleSave(widget.workoutModel);
                          setState(() {});
                        },
                        icon: (snapshot.data!) ? savedDIcon : saveDIcon,
                      );
                    })
                : buildWorkoutOptions(),
          ),
          // bottomSheet: Container(
          //   height: Get.height * 0.05,
          //   color: Colors.transparent,
          //   alignment: Alignment.bottomCenter,
          //   child: Text(
          //       "Created ${DateFormat.MMMd().format(widget.workoutModel.)}"),
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
                            .getUser(widget.workoutModel.ownerId!),
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
                  workoutHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        exerciseTile(),
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
            "Notes",
            textAlign: TextAlign.start,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          widget.workoutModel.notes!,
          overflow: TextOverflow.ellipsis,
          maxLines: 9,
        )
      ],
    );
  }

  // String get exerciseString {
  //   String s = '';
  //   exercises.forEach((element) {
  //     s = s + element + "\n";
  //   });
  //   return s;
  // }

  var exercises = "";
  Widget exerciseTile() {
    exercises = widget.workoutModel.exercises!;
    return Container(
      width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Exercises",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(exercises),

          // ListView.builder(
          //   shrinkWrap: true,
          //   itemCount: exercises.length,
          //   itemBuilder: (BuildContext context, int index) {
          //     return Text(exercises[index]);
          //     // return Row(
          //     //   textBaseline: TextBaseline.ideographic,
          //     //   crossAxisAlignment: CrossAxisAlignment.baseline,
          //     //   children: [
          //     //     Expanded(flex: 1, child: Text("-")),
          //     //     Expanded(flex: 4, child: Text(exercises[index])),
          //     //   ],
          //     // );
          //   },
          // ),
        ],
      ),
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

  Widget workoutHeader() {
    return Padding(
      padding: EdgeInsets.only(left: Get.width * 0.05),
      child: Container(
        height: Get.width * 0.5,
        child: Stack(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: Get.width * 0.4,
                child: descriptionTile(),
              ),
            ),
            Positioned(
              right: Get.width * 0.04,
              top: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                    widget.workoutModel.isDefaultImage ? 8 : 15),
                child: Image.network(
                  widget.workoutModel.workoutCoverURL!,
                  height: Get.width * 0.45,
                  width: Get.width * 0.45,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onPressAction(AttachmentOptions option) async {
    var c = Get.put(WorkoutController());
    if (option == AttachmentOptions.Edit) {
      if (widget.workoutModel.ownerId == userModel.id) {
        await Get.to(() => EditWorkout(
              workoutModel: widget.workoutModel,
            ));
      }
      var controller = Get.find<WorkoutController>();
      widget.workoutModel =
          (await controller.getWorkout(widget.workoutModel.workoutId!))!;
      print(widget.workoutModel.toMap());
      setState(() {});
    } else if (option == AttachmentOptions.Delete) {
      await Get.defaultDialog(
        title: "Alert!",
        content: Text("Are You Sure?"),
        confirm: TextButton(
            onPressed: () async {
              Get.back();
              print(widget.workoutModel.workoutId!);
              await c.deleteWorkout(widget.workoutModel.workoutId!);
              Get.back();
            },
            child: Text("Delete", style: TextStyle(color: Colors.red))),
        cancel: TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(
                  color: !Get.isDarkMode ? Colors.black : Colors.white),
            )),
      );
      // await Get.defaultDialog(
      //   content: Text("Are you sure you want to delete the Recipe?"),
      //   onConfirm: () async {
      //     await c.unsaveWorkout(widget.workoutModel.workoutId);

      //     Get.back();
      //   },
      // );
    }
  }
}
