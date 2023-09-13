import 'dart:io';

import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:video_player/video_player.dart';

class VideoManager extends StatefulWidget {
  final File? videoFile;
  final String? videoUrl;

  const VideoManager({Key? key, this.videoFile, this.videoUrl})
      : super(key: key);

  @override
  _VideoManagerState createState() => _VideoManagerState();
}

class _VideoManagerState extends State<VideoManager> {
  late VideoPlayerController videoPlayerController;

  late ChewieController chewieController;

  late Chewie playerWidget;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    videoPlayerController = VideoPlayerController.network(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4');
    if (widget.videoFile != null) {
      videoPlayerController = VideoPlayerController.file(widget.videoFile!);
    }

    if (widget.videoUrl != null) {
      videoPlayerController = VideoPlayerController.network(
        widget.videoUrl!,
      );
    }

    chewieController = ChewieController(
      showControls: false,
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
      allowMuting: true,
      fullScreenByDefault: false,
    );
    playerWidget = Chewie(
      controller: chewieController,
    );
    chewieController.setVolume(0);
  }

  var muted = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (muted) {
          chewieController.setVolume(1);
          muted = false;
        } else {
          chewieController.setVolume(0);
          muted = true;
        }

        setState(() {});
      },
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(17)),
        child: Container(
          height: Get.height * 0.5,
          child: Stack(
            children: [
              SizedBox(
                width: Get.width,
                height: Get.width,
                child: playerWidget,
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: muted ? Icon(Icons.volume_mute_outlined) : soundDIcon,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();

    super.dispose();
  }
}
