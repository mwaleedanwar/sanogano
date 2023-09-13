// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/services/FirebaseStorageServices.dart';
import 'package:sano_gano/view/pages/follow/following_selection.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/create_post.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart' as userHeader;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../controllers/chat_controller.dart';
import '../../widgets/user_header_tile.dart';
import 'channel_file_display_screen.dart';
import 'channel_media_display_screen.dart';
import 'direct_message_setting.dart';
import 'pinned_messages_screen.dart';

class GroupMessageSetting extends StatefulWidget {
  final Channel channel;

  const GroupMessageSetting({Key? key, required this.channel})
      : super(key: key);

  @override
  State<GroupMessageSetting> createState() => _GroupMessageSettingState();
}

class _GroupMessageSettingState extends State<GroupMessageSetting> {
  bool isMuteMessage = false;
  Channel get channel => widget.channel;
  var uc = Get.find<UserController>();
  var tec = TextEditingController();
  bool imageUploading = false;
  var allowedMembers = 32;
  @override
  void initState() {
    super.initState();
    isMuteMessage = channel.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    bool isGroup = channel.extraData['isGroup'] as bool? ?? false;
    List<Member> members = channel.state!.members;
    members.sort((a, b) => a.user!.createdAt.compareTo(b.user!.createdAt));
    members.sort((a, b) => channel.createdBy!.id == a.user!.id ? -1 : 1);
    tec = TextEditingController(text: channel.name);

    return StreamChannel(
      channel: channel,
      child: Scaffold(
        appBar: StreamChannelHeader(
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: backDIcon.copyWith(size: 20)),
          centerTitle: true,
          actions: !isGroup
              ? null
              : [
                  userHeader.UserAvatar(
                    '',
                    name: channel.name,
                    image: channel.image,
                    radius: 18,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // ignore: prefer_const_constructors
            Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                StatefulBuilder(builder: (context, refresh) {
                  return InkWell(
                    onTap: () async {
                      var newImage = await showImagePicker(
                        context,
                      );

                      if (newImage != null) {
                        imageUploading = true;
                        refresh(() {});
                        var url = await FirebaseStorageServices.uploadToStorage(
                            isVideo: false,
                            file: newImage,
                            folderName: "GroupChat");
                        await channel.updateImage(url);
                      }
                      imageUploading = false;
                      refresh(() {});
                      setState(() {});
                    },
                    child: Stack(
                      children: [
                        userHeader.UserAvatar(
                          '',
                          name: channel.name,
                          image: channel.image,
                          radius: 40,
                        ),
                        if (imageUploading)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StatefulBuilder(builder: (context, refresh) {
                      return TextFormField(
                        onChanged: (value) => refresh(() {}),
                        controller: tec,

                        decoration: InputDecoration(
                            label: Text('Group Name'),
                            suffixIcon: tec.text != channel.name
                                ? IconButton(
                                    onPressed: () async {
                                      await channel.updateName(tec.text);
                                      setState(() {});
                                    },
                                    icon: checkmarkDIcon)
                                : null),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      );
                    }),
                  ),
                ),
              ],
            ),
            StreamBuilder<bool>(
                stream: channel.isMutedStream,
                builder: (context, snapshot) {
                  isMuteMessage = snapshot.data ?? false;
                  return ListTileSwitch(
                    heading: 'Mute Messages',
                    value: isMuteMessage,
                    onChange: (value) async {
                      // setState(() {
                      //   isMuteMessage = !isMuteMessage;
                      // });
                      try {
                        showLoading();
                        if (value) {
                          await channel.mute();
                        } else {
                          await channel.unmute();
                        }
                        await Get.find<ChatController>().refreshChannelList();

                        hideLoading();
                      } on Exception catch (_) {
                        hideLoading();
                        // TODO
                      }
                    },
                  );
                }),
            CustomListTile(
                heading: 'Pinned Messages',
                onTap: () {
                  Get.to(() => StreamChannel(
                      channel: channel, child: PinnedMessagesScreen()));
                }),
            CustomListTile(
                heading: 'Photos & Videos',
                onTap: () {
                  Get.to(() => StreamChannel(
                      channel: channel,
                      child: ChannelMediaDisplayScreen(
                        messageTheme:
                            StreamChatTheme.of(context).ownMessageTheme,
                      )));
                }),
            CustomListTile(
                heading: 'Files',
                onTap: () {
                  Get.to(() => StreamChannel(
                      channel: channel,
                      child: ChannelFileDisplayScreen(
                        messageTheme:
                            StreamChatTheme.of(context).ownMessageTheme,
                      )));
                }),
            const SizedBox(height: 10),
            if (channel.memberCount! < allowedMembers)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      handlePlurals(channel.memberCount ?? 0, "Member"),
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () async {
                          var results = await pickUsersFromFollowers();
                          await channel.addMembers(results);
                          setState(() {});
                        },
                        icon: addIcon)
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                  itemCount: members.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var member = members[index].user!;

                    return Row(
                      children: [
                        Expanded(
                          child: StreamUserListTile(
                            onTap: () {
                              Get.to(() => ProfilePage(
                                    userID: member.id,
                                  ));
                            },
                            user: member,
                            leading:
                                member.image == null || member.image!.isEmpty
                                    ? userHeader.UserAvatar(
                                        "",
                                        name: member.name,
                                        radius: 18,
                                        showOnlineIndicator: member.online,
                                      )
                                    : null,
                          ),
                        ),
                        // if (member.id == channel.createdBy!.id)
                        //   Text("Commissioner"),
                        // if (member.id != channel.createdBy!.id)
                        //   TextButton(
                        //       onPressed: () async {
                        //         await channel.removeMembers([member.id]);
                        //         setState(() {});
                        //       },
                        //       child: Text("Remove"))
                      ],
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 5),
              child: TextButton(
                  onPressed: () async {
                    await channel.removeMembers([uc.userModel.id!]);
                    Get.back();
                    Get.back();
                  },
                  child: Text(
                    'Leave Group',
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  )),
            ),
            ListTile(),
          ],
        ),
      ),
    );
  }
}

class GroupMembers {
  String image;
  String name;
  String username;
  String lastActive;
  bool isAdmin;
  GroupMembers({
    required this.image,
    required this.name,
    this.isAdmin = false,
    required this.username,
    required this.lastActive,
  });
}

Future<List<String>> pickUsersFromFollowers() async {
  var user = Get.find<UserController>().userModel;
  var result = await Get.to<List<String>?>(() => FollowingSelectionScreen(
        selectedIds: (selection) {
          Get.back();
          return selection;
        },
      ));
  return result ?? [];
}
