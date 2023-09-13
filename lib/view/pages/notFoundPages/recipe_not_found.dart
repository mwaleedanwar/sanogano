import 'package:flutter/material.dart';

import '../../global/custom_appbar.dart';

class RecipeNotFound extends StatelessWidget {
  const RecipeNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(back: true),
      body: Center(
        child: Text(
          "Recipe Not Found",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
