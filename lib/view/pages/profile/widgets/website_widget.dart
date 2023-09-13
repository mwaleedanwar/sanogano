import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/globalHelperMethods.dart';

class WebsiteWidget extends StatelessWidget {
  String? website;
  WebsiteWidget({
    Key? key,
    this.website,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (isNullOrBlank(website)) {
      return Container();
    }
    if (website == null) {
      return Text(
        "website",
        style: TextStyle(color: Colors.grey),
      );
    } else {
      if (website!.length == 0) {
        return Text(
          "website",
          style: TextStyle(color: Colors.grey),
        );
      } else {
        return InkWell(
          onTap: () {
            if (website!.contains("https")) {
              launch(website!);
            } else {
              launch('https://$website');
            }
          },
          child: Text(
            website!,
            style: TextStyle(
              color: Color(0xFF5879EE),
            ),
          ),
        );
      }
    }
  }
}
