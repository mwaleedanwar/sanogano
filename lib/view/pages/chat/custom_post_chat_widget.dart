import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/view/widgets/show_post_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../widgets/post_widget.dart';

class CustomChatPostWidget extends StatelessWidget {
  final PostModel post;
  // final Message message;
  const CustomChatPostWidget({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => ShowPostWidget(postModel: post));
      },
      child: Container(
        margin: EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0),
        decoration: BoxDecoration(
            color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 5)
            ],
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            PostWidget(
              disableOnLongPress: true,
              postId: post.postId,
              miniMode: true,
            ),
            SizedBox(
              height: 15,
            ),
            // Text(message.text.toString()),
            // SizedBox(
            //   height: 10,
            // ),
          ],
        ),
      ),
    );
  }
}
