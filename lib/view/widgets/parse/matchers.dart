// You can create a custom matcher easily by extending TextMatcher.
import 'package:custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/comments_page.dart';
import 'package:url_launcher/url_launcher.dart';

import '../hashtag_screen.dart';

class HashTagMatcher extends TextMatcher {
  const HashTagMatcher() : super(r'(?<=\s|^)\#[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)');
  // const HashTagMatcher() : super(r'(?<=\s|^)\#[a-zA-Z][a-z0-9]{1,}(?=\s|$)');
}

class UsernameMatcher extends TextMatcher {
  const UsernameMatcher()
      : super(r'(?<=\s|^)\@[a-zA-Z][a-zA-Z0-9]{1,}(?=\s|$)');
  // const UsernameMatcher()
  //     : super(r"(?=.{8,20}$)(?![_.])(?!.*[_.]{2})\@[a-zA-Z0-9._]+(?<![_.])");
}

class TextParser extends StatelessWidget {
  final String string;
  final bool isTextPost;

  TextParser(
    this.string, {
    this.isTextPost = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomText(
      string,
      definitions: [
        TextDefinition(
          matcher: UrlMatcher(),
          onTap: (value) {
            if (value.contains("https")) {
              launch(value);
            } else {
              launch('https://$value');
            }
          },
          matchStyle: TextStyle(
            color: Get.isDarkMode ? Colors.blue[400] : Colors.blue[900],
          ),
        ),
        TextDefinition(
          matcher: HashTagMatcher(),
          onTap: (value) {
            print("pressing $value");
            // Navigator.of(context).push(MaterialPageRoute(
            //   builder: (context) => HashtagsScreen(value),
            // ));
            Get.to(
                HashtagsScreen(
                    hashtag: value.toLowerCase(),
                    sortMode: SortMode.new_to_old),
                preventDuplicates: false);
          },
          matchStyle: TextStyle(
            color: Get.isDarkMode ? Colors.blue[400] : Colors.blue[900],
          ),
        ),
        TextDefinition(
            matcher: UsernameMatcher(),
            matchStyle: TextStyle(
              color: Get.isDarkMode ? Colors.blue[400] : Colors.blue[900],
            ),
            onTap: (value) async {
              // print(value);
              // print(value.substring(1, value.length));
              String? id;
              id = await UserDatabase()
                  .getUserIDFromUsernameWithNoCaseSensitivity(
                      value.substring(1));
              // if (id == null) {
              //   print('id is null');
              //   id = await UserDatabase()
              //       .getUserIDFromUsername(value.substring(1));
              // }
              print(id);

              if (id != null) {
                Get.to(() => ProfilePage(userID: id!));
              }
            }),
      ],
      style: getTextStyle(),
      matchStyle: const TextStyle(
        color: Colors.lightBlue,
        decoration: TextDecoration.underline,
      ),
      tapStyle: const TextStyle(color: Colors.indigo),
      onTap: (type, text) => print(text),
      onLongPress: (type, text) => print('[Long press] $text'),
    );
  }

  TextStyle getTextStyle() {
    var color = Get.isDarkMode ? Colors.white : Colors.black;
    if (isTextPost) return TextStyle(color: color, fontSize: 16);
    return TextStyle(color: color, fontSize: 16);
  }
}
