import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils.dart';
import 'package:sano_gano/view/pages/chat/chat_page.dart';

import 'package:sano_gano/view/pages/follow/widgets/follow_tile.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class UserProfile extends GetWidget<FollowController> {
  final String userID;
  final UserModel userModel;

  UserProfile({required this.userID, required this.userModel});
  var currentUserID = Get.find<UserController>().userModel.id;

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    // var id = Get.find<AuthController>().user!.uid;

    Widget _buildFollowButton(String title, VoidCallback onPressed) {
      return InkWell(
        onTap: onPressed,
        child: Container(
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                  width: 1)),
          child: Center(child: Text(title)),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Get.width * 0.020, vertical: 5),
      child: Container(
        width: Get.width,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: Get.width * 0.45,
                child: FollowButton(
                  userModel: userModel,
                  uid: userModel.id,
                )),
            // GetX(
            //   init: Get.put(FollowController()),
            //   builder:(FollowController controller){
            //  //   controller.checkFollowed(myID, userID);
            //     return _buildFollowButton(
            //       controller.followed ? "Following" : "Follow", () {
            //     Get.find<FollowController>().setFollow(id, userID);
            //   });
            //   }),
            Container(
              width: Get.width * 0.45,
              child: _buildFollowButton("Message", () async {
                var client = StreamChat.of(context).client;
                final channel = client.channel(
                  "messaging",
                  id: createChatID(currentUserID!, userID),
                  extraData: {
                    "members": [currentUserID, userID],
                  },
                );

                await channel.watch();
                Get.to(() => ChatPage(
                      channel: channel,
                    ));
              }),
            ),
          ],
        ),
      ),
    );
  }
}
