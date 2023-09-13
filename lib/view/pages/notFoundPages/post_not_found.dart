import 'package:flutter/material.dart';

import '../../global/custom_appbar.dart';

class PostNotFound extends StatelessWidget {
  const PostNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(back: true),
      body: Center(
        child: Text(
          "Post Not Found",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
