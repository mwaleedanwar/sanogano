import 'package:flutter/material.dart';

class AuthText extends StatelessWidget {
  String text;
  double size;

  AuthText(this.text, this.size);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: size,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.25),
    );
  }
}
