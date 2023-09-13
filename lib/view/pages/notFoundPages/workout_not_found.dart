import 'package:flutter/material.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';

class WorkoutNotFound extends StatelessWidget {
  const WorkoutNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(back: true),
      body: Center(
        child: Text(
          "Workout Not Found",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
