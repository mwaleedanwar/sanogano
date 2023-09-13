import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/models/workoutModel.dart';

import '../../widgets/user_header_tile.dart';
import '../../widgets/view_workout.dart';

class WorkoutSearchTile extends StatelessWidget {
  final WorkoutModel workout;
  const WorkoutSearchTile({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // onTap: () => Get.to(ViewWorkout(
      //   workoutModel: workout,
      // )),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Image.network(
          workout.workoutCoverURL!,
          fit: BoxFit.cover,
          height: Get.width * 0.1,
          width: Get.width * 0.1,
        ),
      ),
      title: Text(
        workout.workoutName!,
        maxLines: 2,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UsernameWidget(
            uid: workout.ownerId!,
          ),
          Text(
            workout.saveCount.toString() +
                " Save${workout.saveCount == 1 ? '' : 's'}",
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
