import 'package:flutter/material.dart';

class SingleChildScrollViewBuilder extends StatelessWidget {
  final Widget Function(int) generator;
  final int length;

  const SingleChildScrollViewBuilder(
      {Key? key, required this.generator, required this.length})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ...List.generate(length, generator),
        ],
      ),
    );
  }
}
