import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/database.dart';
import '../../widgets/hashtag_screen.dart';

class HashtagSearchResults extends StatelessWidget {
  final bool daily;
  final String id;
  final int hitCount;

  DateTime get today => DateTime.now().subtract(1.days);
  final db = Database();
  HashtagSearchResults(
      {Key? key, required this.daily, required this.id, required this.hitCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Get.to(() => HashtagsScreen(hashtag: id)),
      title: Text(
        id,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: daily
          ? FutureBuilder(
              future:
                  db.postsCollection.where('hashtags', arrayContains: id).get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return Text(snapshot.data?.docs?.length);
              },
            )
          : Text(hitCount.toString() + " Post${hitCount == 1 ? '' : 's'}"),
    );
  }
}
