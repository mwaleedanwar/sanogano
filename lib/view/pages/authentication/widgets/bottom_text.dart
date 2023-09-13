import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomText extends StatelessWidget {
  String text;
  VoidCallback onPressed;

  BottomText(this.text, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Text(
        text,
        style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}
