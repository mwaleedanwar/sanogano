import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/view/pages/activity/leaderboard/widgets/workout_leaderboard_tile.dart';

import '../../../../controllers/leaderboard_controller.dart';

class TrendingWorkouts extends StatelessWidget {
  TrendingWorkouts({super.key});
  LeaderBoardController controller = Get.find<LeaderBoardController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<WorkoutModel>? workoutList = controller.popularWorkouts;
      return controller.isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(),
            )
          : ListView.builder(
              shrinkWrap: false,
              itemCount: workoutList!.length,
              itemBuilder: (_, index) {
                WorkoutModel _workout = workoutList[index];
                return WorkoutLeaderBoardTile(
                    workout: _workout, index: index + 1);
              });
    });
  }
}
