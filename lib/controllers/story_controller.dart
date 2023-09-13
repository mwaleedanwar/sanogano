import 'dart:io';

import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/story_model.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:story_view/widgets/story_view.dart';

class StoryController extends GetxController {
  var db = Database();
  var currentUid = Get.find<UserController>().currentUid;

  Future<void> addStory(File attachment, bool isVideo) async {
    var doc = db.storyCollection(currentUid).doc();
    var model = StoryModel(
      attachmentUrl: await FirebaseStorageServices.uploadToStorage(
          isVideo: false, file: attachment, folderName: "Stories"),
      isVideo: isVideo,
      ownerId: currentUid,
      storyId: doc.id,
      timestamp: DateTime.now(),
    );
    await doc.set(model.toMap());
    return;
  }

  Future<void> addStoryView(StoryItem story) async {
    return;
  }
}
