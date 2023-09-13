import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/story_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/pages/home/camera_page.dart';
import 'package:sano_gano/view/pages/home/story_view.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';
import 'package:video_player/video_player.dart';

class SendStoryPage extends StatefulWidget {
  final CameraResponse attachment;
  const SendStoryPage(this.attachment);

  @override
  _SendStoryPageState createState() => _SendStoryPageState();
}

class _SendStoryPageState extends State<SendStoryPage> {
  var _textFieldController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: Get.height * 0.2,
                child: Hero(
                    tag: widget.attachment.file!.path,
                    child: _thumbnailWidget())),
            Container(
              height: Get.height * 0.7,
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: CupertinoSearchTextField(
                      controller: _textFieldController,
                      onSubmitted: (String _) {},
                    ),
                  ),
                  ListTile(
                    onTap: () async {
                      Get.put(StoryController());
                      var controller = Get.find<StoryController>();
                      await controller.addStory(
                          widget.attachment.file!, widget.attachment.isVideo!);
                      Get.to(() => UserStoryView(
                            uid: Get.find<UserController>().currentUid,
                          ));
                    },
                    leading: UserAvatar(Get.find<UserController>().currentUid),
                    title: Text("Add post to your story"),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _thumbnailWidget() {
    VideoPlayerController? localVideoController = widget.attachment.isVideo!
        ? VideoPlayerController.file(widget.attachment.file!)
        : null;

    return Container(
      child: (!widget.attachment.isVideo!)
          ? Image.file(
              File(
                widget.attachment.file!.path,
              ),
              fit: BoxFit.cover,
              width: Get.width * 0.3,
            )
          : Container(
              child: Center(
                child: AspectRatio(
                    aspectRatio: localVideoController!.value.size != null
                        ? localVideoController.value.aspectRatio
                        : 1.0,
                    child: VideoPlayer(localVideoController)),
              ),
              decoration: BoxDecoration(border: Border.all(color: Colors.pink)),
            ),
      width: Get.width * 0.3,
    );
  }
}
