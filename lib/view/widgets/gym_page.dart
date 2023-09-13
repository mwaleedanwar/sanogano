import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/components/paginated_widgets.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/create_workout.dart';
import 'package:sano_gano/view/widgets/popup_menu_builder.dart';
import 'package:sano_gano/view/widgets/view_workout.dart';

import '../../controllers/helpers/scroll_focus_controller_helper.dart';
import 'workout_controller.dart';

class GymPage extends StatefulWidget {
  final bool? selectionMode;
  final Function(WorkoutModel)? onWorkoutSelected;
  final String? uid;
  final String? username;
  final bool? healthMode;
  final bool? isRoot;
  final Function? onCookbookPressedCallback;
  final bool isFromCreatePost;
  GymPage(
      {Key? key,
      this.selectionMode = false,
      this.onWorkoutSelected,
      this.uid,
      this.username,
      this.healthMode = false,
      this.isRoot = false,
      this.onCookbookPressedCallback,
      this.isFromCreatePost = false})
      : super(key: key);

  @override
  State<GymPage> createState() => _GymPageState();
}

class _GymPageState extends State<GymPage> {
  bool get isCurrentUser => Get.find<UserController>().currentUid == widget.uid;
  ScrollAndFocusControllerHelper sfc =
      Get.find<ScrollAndFocusControllerHelper>();
  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorkoutController>(
      init: WorkoutController(),
      initState: (_) {},
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            onTapTitle: () {
              if (widget.selectionMode ?? false) return;
              sfc.healthPageScrollController.animateTo(0,
                  duration: Duration(milliseconds: 500), curve: Curves.ease);
            },
            back: !widget.healthMode!,
            leading: widget.healthMode!
                ? Container(
                    height: 5,
                    child: IconButton(
                        onPressed: () => widget.onCookbookPressedCallback!(),
                        icon: cookbookIcon),
                  )
                : null,
            multiline: true,
            title: widget.selectionMode!
                ? "Select Workout"
                : isCurrentUser
                    ? "Gym"
                    : "${widget.username}'s Gym",
            iconButton: !isCurrentUser
                ? buildPopupMenu([
                    PopupItem(
                        title: "Save All",
                        callback: () async {
                          var alldocs = await controller.db
                              .savedWorkouts(widget.uid!)
                              .get();
                          var recipes = alldocs.docs
                              .map((e) => WorkoutModel.fromMap(
                                  e.data() as Map<String, dynamic>))
                              .toList();
                          for (var item in recipes) {
                            await controller.saveWorkout(
                                item.workoutId!, item.workoutName!);
                            print("Saving ${item.workoutId}");
                          }
                        })
                  ])
                : !widget.isRoot!
                    ? Container()
                    : IconButton(
                        onPressed: () => createWorkout(
                            isFromCreatePost: widget.isFromCreatePost),
                        icon: addIcon),

            // isCurrentUser
            //     ? !isRoot
            //         ? Container()
            //         : IconButton(onPressed: createWorkout, icon: addIcon)
            //     : Container(),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8, 8, 12),
            child: StreamBuilder<Object>(
                stream: controller.db.savedWorkouts(widget.uid!).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData) {
                    return Center(
                      child: Text("No Workouts"),
                    );
                  }

                  return buildPaginatedGrid(
                      controller.db
                          .savedWorkouts(widget.uid!)
                          // .orderBy('workoutName')// Removed for now as told by client
                          .orderBy('timestamp', descending: true),
                      (_, docs, index) => buildMiniWorkout(docs[index].id),
                      emptyText: "",
                      fontSize: context.theme.textTheme.bodyMedium?.fontSize);
                }),
          ),
        );
      },
    );
  }

  void createWorkout({bool isFromCreatePost = false}) async {
    var result = await showImagePicker(Get.context,
        skipMode: true, squareMode: true, workoutMode: true, onSkip: () {
      if (!isFromCreatePost) {
        Get.back();
      }
      0.75.seconds.delay().then((value) async {
        await Get.to(CreateWorkout(
          workoutImage: null,
          skipMode: true,
        ));
        setState(() {});
      });
    });

    if (result != null) {
      Get.back();
      0.75.seconds.delay().then((value) async {
        await Get.to(CreateWorkout(
          workoutImage: result,
        ));
        setState(() {});
      });
    }
  }

  var c = Get.put(WorkoutController());

  Widget buildMiniWorkout(String id) {
    WorkoutModel? workoutModel;
    return StreamBuilder<WorkoutModel?>(
        stream: c.getWorkout(id).asStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          if (snapshot.hasData) {
            workoutModel = snapshot.data!;
          }
          return GestureDetector(
            onTap: widget.selectionMode!
                ? () => widget.onWorkoutSelected!(workoutModel!)
                : () async {
                    await Get.to(() => ViewWorkout(
                          workoutModel: workoutModel!,
                        ));
                    setState(() {});
                  },
            child: Column(
              // mainAxisSize: MainAxisSize.max,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      workoutModel!.isDefaultImage ? 8 : 8),
                  child: Image.network(
                    workoutModel!.workoutCoverURL!,
                    height: Get.width * 0.3,
                    width: Get.width * 0.3,
                    fit: workoutModel!.workoutCoverURL == defaultWorkoutImage
                        ? BoxFit.contain
                        : BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Expanded(
                    child: AutoSizeText(
                  workoutModel!.workoutName! + "\n",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 8),
                )),
                SizedBox(
                  height: 5,
                )
              ],
            ),
          );
        });
  }
}
