import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/user.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../controllers/user_controller.dart';
import '../../../utils.dart';

class StreamChatController {
  var uc = Get.find<UserController>();
  Future<Channel> createAndWatchChannel(BuildContext context,
      {UserModel? user, List<String>? uids, bool skipWatch = false}) async {
    var client = StreamChat.of(context).client;
    if (user != null) {
      final channel = client.channel(
        "messaging",
        id: createChatID(uc.userModel.id!, user.id!),
        extraData: {
          "members": [uc.userModel.id!, user.id!],
        },
      );
      if (!skipWatch) {
        await channel.watch();
      } else {
        await channel.create();
      }
      return channel;
    } else if (uids != null) {
      final channel = client.channel(
        "messaging",
        id: Uuid().v4(),
        extraData: {
          'isGroup': true,
          "name": "Group Chat",
          "members": [uc.userModel.id!, ...uids],
        },
      );

      await channel.watch();
      return channel;
    } else {
      throw Exception("No user or uids provided");
    }
  }

  Future<void> followUser(UserModel user) async {
    await createAndWatchChannel(Get.context!, skipWatch: true, user: user);
    return;
  }

  Future<void> unfollowUser(UserModel user) async {
    var channel =
        await createAndWatchChannel(Get.context!, skipWatch: true, user: user);
    await channel.delete();
    return;
  }
}
