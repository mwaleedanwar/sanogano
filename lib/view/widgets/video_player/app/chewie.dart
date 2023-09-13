import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sano_gano/view/widgets/video_player/app/theme.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';

class ChewieDemo extends StatefulWidget {
  final String videoUrl;
  final File? video;
  const ChewieDemo({
    Key? key,
    required this.videoUrl,
    this.video,
    this.title = 'Chewie Demo',
  }) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ChewieDemoState();
  }
}

class _ChewieDemoState extends State<ChewieDemo> {
  late TargetPlatform _platform;
  late VideoPlayerController _videoPlayerController1;

  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController1.dispose();

    _chewieController?.dispose();
    super.dispose();
  }

  List<String> get srcs => [
        widget.videoUrl,
      ];
  double aspectRatio = 16 / 9;
  Future<void> initializePlayer() async {
    if (widget.video != null) {
      _videoPlayerController1 = VideoPlayerController.file(widget.video!);
    } else {
      _videoPlayerController1 = VideoPlayerController.network(widget.videoUrl);
    }

    await _videoPlayerController1.initialize();
    _videoPlayerController1.addListener(() {
      if (aspectRatio != _videoPlayerController1.value.size.aspectRatio) {
        setState(() {
          aspectRatio = _videoPlayerController1.value.size.aspectRatio;
        });
      }
    });
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    // final subtitles = [
    //     Subtitle(
    //       index: 0,
    //       start: Duration.zero,
    //       end: const Duration(seconds: 10),
    //       text: 'Hello from subtitles',
    //     ),
    //     Subtitle(
    //       index: 0,
    //       start: const Duration(seconds: 10),
    //       end: const Duration(seconds: 20),
    //       text: 'Whats up? :)',
    //     ),
    //   ];

    _chewieController = ChewieController(
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      videoPlayerController: _videoPlayerController1,
      autoPlay: true,
      looping: true,
      showControls: widget.video == null,
      fullScreenByDefault: widget.video != null ? false : true,

      // additionalOptions: (context) {
      //   return <OptionItem>[
      //     OptionItem(
      //       onTap: toggleVideo,
      //       iconData: Icons.live_tv_sharp,
      //       title: 'Toggle Video Src',
      //     ),
      //   ];
      // },

      subtitleBuilder: (context, dynamic subtitle) => Container(
        padding: const EdgeInsets.all(10.0),
        child: subtitle is InlineSpan
            ? RichText(
                text: subtitle,
              )
            : Text(
                subtitle.toString(),
                style: const TextStyle(color: Colors.black),
              ),
      ),

      // Try playing around with some of these other options:

      // showControls: false,
      // materialProgressColors: ChewieProgressColors(
      //   playedColor: Colors.red,
      //   handleColor: Colors.blue,
      //   backgroundColor: Colors.grey,
      //   bufferedColor: Colors.lightGreen,
      // ),
      // placeholder: Container(
      //   color: Colors.grey,
      // ),
      // autoInitialize: true,
    );
  }

  int currPlayIndex = 0;

  Future<void> toggleVideo() async {
    await _videoPlayerController1.pause();
    currPlayIndex = currPlayIndex == 0 ? 1 : 0;
    await initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Text(widget.title),
      // ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Chewie(
                      controller: _chewieController!,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Loading'),
                      ],
                    ),
            ),
          ),
          // TextButton(
          //   onPressed: () {
          //     _chewieController?.enterFullScreen();
          //   },
          //   child: const Text('Fullscreen'),
          // ),
          // Row(
          //   children: <Widget>[
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {
          //           setState(() {
          //             _videoPlayerController1.pause();
          //             _videoPlayerController1.seekTo(Duration.zero);
          //             _createChewieController();
          //           });
          //         },
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(vertical: 16.0),
          //           child: Text("Landscape Video"),
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {
          //           // setState(() {
          //           //   _videoPlayerController2.pause();
          //           //   _videoPlayerController2.seekTo(Duration.zero);
          //           //   _chewieController = ChewieController(
          //           //     videoPlayerController: _videoPlayerController2,
          //           //     autoPlay: true,
          //           //     looping: true,

          //           //     additionalOptions: (context) {
          //           //       return <OptionItem>[
          //           //         OptionItem(
          //           //           onTap: toggleVideo,
          //           //           iconData: Icons.live_tv_sharp,
          //           //           title: 'Toggle Video Src',
          //           //         ),
          //           //       ];
          //           //     },

          //           //     subtitleBuilder: (context, dynamic subtitle) =>
          //           //         Container(
          //           //       padding: const EdgeInsets.all(10.0),
          //           //       child: subtitle is InlineSpan
          //           //           ? RichText(
          //           //               text: subtitle,
          //           //             )
          //           //           : Text(
          //           //               subtitle.toString(),
          //           //               style: const TextStyle(color: Colors.black),
          //           //             ),
          //           //     ),

          //           //     // Try playing around with some of these other options:

          //           //     // showControls: false,
          //           //     // materialProgressColors: ChewieProgressColors(
          //           //     //   playedColor: Colors.red,
          //           //     //   handleColor: Colors.blue,
          //           //     //   backgroundColor: Colors.grey,
          //           //     //   bufferedColor: Colors.lightGreen,
          //           //     // ),
          //           //     // placeholder: Container(
          //           //     //   color: Colors.grey,
          //           //     // ),
          //           //     // autoInitialize: true,

          //           //     /* subtitle: Subtitles([
          //           //       Subtitle(
          //           //         index: 0,
          //           //         start: Duration.zero,
          //           //         end: const Duration(seconds: 10),
          //           //         text: 'Hello from subtitles',
          //           //       ),
          //           //       Subtitle(
          //           //         index: 0,
          //           //         start: const Duration(seconds: 10),
          //           //         end: const Duration(seconds: 20),
          //           //         text: 'Whats up? :)',
          //           //       ),
          //           //     ]),
          //           //     subtitleBuilder: (context, subtitle) => Container(
          //           //       padding: const EdgeInsets.all(10.0),
          //           //       child: Text(
          //           //         subtitle,
          //           //         style: const TextStyle(color: Colors.white),
          //           //       ),
          //           //     ), */
          //           //   );
          //           // });
          //         },
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(vertical: 16.0),
          //           child: Text("Portrait Video"),
          //         ),
          //       ),
          //     )
          //   ],
          // ),
          // Row(
          //   children: <Widget>[
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {
          //           setState(() {
          //             _platform = TargetPlatform.android;
          //           });
          //         },
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(vertical: 16.0),
          //           child: Text("Android controls"),
          //         ),
          //       ),
          //     ),
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {
          //           setState(() {
          //             _platform = TargetPlatform.iOS;
          //           });
          //         },
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(vertical: 16.0),
          //           child: Text("iOS controls"),
          //         ),
          //       ),
          //     )
          //   ],
          // ),
          // Row(
          //   children: <Widget>[
          //     Expanded(
          //       child: TextButton(
          //         onPressed: () {
          //           setState(() {
          //             _platform = TargetPlatform.windows;
          //           });
          //         },
          //         child: const Padding(
          //           padding: EdgeInsets.symmetric(vertical: 16.0),
          //           child: Text("Desktop controls"),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }
}
