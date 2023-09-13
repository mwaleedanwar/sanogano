import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/view/widgets/view_workout.dart';

import '../helpers/leaderboard_type.dart';
import 'leaderboard_tile.dart';

class WorkoutLeaderBoardTile extends StatelessWidget {
  final int index;
  final WorkoutModel workout;
  const WorkoutLeaderBoardTile(
      {super.key, required this.index, required this.workout});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()=>Get.to(()=> ViewWorkout(workoutModel: workout),transition: Transition.rightToLeft),
      child: LeaderBoardTile(
        data: workout.toMap(),
        dataType: LeaderboardType.workouts,
        index: index,
      ),
    );
  }
}
