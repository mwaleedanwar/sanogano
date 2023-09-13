import 'package:flutter/material.dart';

import '../../../../utils/globalHelperMethods.dart';

class BioWidget extends StatelessWidget {
  String? bio;

  BioWidget({Key? key, this.bio}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isNullOrBlank(bio)) {
      return Container();
    }
    if (bio == null) {
      return Text(
        "bio",
        style: TextStyle(color: Colors.grey),
      );
    } else {
      if (bio!.length == 0) {
        return Text(
          "bio",
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return Text(
          bio!,
          softWrap: true,
          maxLines: 2,
          style: TextStyle(height: 1.5),
          textAlign: TextAlign.center,
        );
      }
    }
  }
}
