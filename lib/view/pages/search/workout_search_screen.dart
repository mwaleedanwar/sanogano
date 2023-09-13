import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/view/pages/search/search_item_widget.dart';
import 'package:sano_gano/view/pages/search/single_child_scrollview_builder.dart';
import 'package:sano_gano/view/pages/search/workout_search_tile.dart';

import '../../../models/workoutModel.dart';
import '../../widgets/view_workout.dart';
import 'build_initial.dart';

class WorkoutSearchScreen extends StatelessWidget {
  WorkoutSearchScreen({super.key});
  SearchController sc = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(children: <Widget>[
        Expanded(
            child: sc.isHitListEmpty && sc.textFieldController.text.isEmpty
                ? BuildInitial(index: 3)
                : SingleChildScrollViewBuilder(
                    length: sc.searchCount,
                    generator: (index) {
                      var snapshot = sc.hitsList![index];

                      var workout = WorkoutModel.fromMap(snapshot.data);
                      print(workout.workoutName);
                      if (workout.workoutId == null) return Container();
                      return SearchItemWidget(
                        id: workout.workoutId!,
                        onTap: () => Get.to(() => ViewWorkout(
                              workoutModel: workout,
                            )),
                        map: workout.toMap(),
                        child: WorkoutSearchTile(workout: workout),
                      );
                    })),
      ]);
    });
  }
}
