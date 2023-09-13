import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/story_model.dart';
import 'package:sano_gano/utils/database.dart';
import "package:story_view/story_view.dart";

class UserStoryView extends StatefulWidget {
  final String uid;

  const UserStoryView({Key? key, required this.uid}) : super(key: key);

  @override
  _UserStoryViewState createState() => _UserStoryViewState();
}

class _UserStoryViewState extends State<UserStoryView> {
  var db = Database();

  final controller = StoryController();
  List<StoryItem> storyItems = [];
  var loaded = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  void getData() async {
    var docs = await db
        .storyCollection(widget.uid)
        .where('timestamp',
            isGreaterThanOrEqualTo: DateTime.now()
                .subtract(Duration(hours: 24))
                .millisecondsSinceEpoch)
        .get();
    var models = docs.docs
        .map((e) => StoryModel.fromMap(e.data() as Map<String, dynamic>))
        .toList();
    storyItems = List.generate(
        models.length, (index) => models[index].storyItem(controller));
    setState(() {
      loaded = true;
    });
  }

  var paused = false;
  @override
  Widget build(BuildContext context) {
    return !loaded
        ? Center(
            child: CircularProgressIndicator(),
          )
        : StoryView(
            onVerticalSwipeComplete: (direction) {
              if (direction == Direction.up) {
                if (paused) {
                  paused = false;
                  controller.play();
                } else {
                  controller.pause();
                  paused = true;
                }
              }
            },
            controller: controller,
            storyItems: storyItems,
            onStoryShow: (s) {
              print("Showing a story");
            },
            onComplete: () {
              Get.back();
            },
            progressPosition: ProgressPosition.bottom,
            repeat: false,
            inline: true,
          );
  }
}
