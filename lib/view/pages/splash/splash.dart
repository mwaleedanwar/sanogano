import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onCompletionCallback;

  const SplashPage({Key? key, required this.onCompletionCallback})
      : super(key: key);
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    print("dark mode:::::::: ${Get.isDarkMode}");
    _timer();

    // _controller = VideoPlayerController.asset(
    //     Get.isDarkMode
    //         ? "assets/splash/splash.mp4"
    //         : "assets/splash/splash-white.mp4",
    //     videoPlayerOptions: VideoPlayerOptions(
    //       mixWithOthers: true,
    //     ))
    //   // ..setVolume(0)
    //   ..initialize().then((_) {
    //     _controller.play();
    //     // _controller.setVolume(0.0);
    //     _controller.play();
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });
  }

  _timer() async {
    return Timer(Duration(milliseconds: 3200), onCompletionCallback);
  }

  void onCompletionCallback() {
    widget.onCompletionCallback();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   // _controller.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    Get.isDarkMode
        ? SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light)
        : SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    var size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
        body: Center(
          child: SizedBox(
            width: size.width,
            height: 100,
            child:
                Image.asset('assets/images/appLogo.png', fit: BoxFit.contain),
            // child: VideoPlayer(_controller),
            // child: Hero(tag: 'logo-main', child: VideoPlayer(_controller)),
          ),
        ));
  }
}
