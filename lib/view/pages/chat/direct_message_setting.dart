import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/chat_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/view/pages/chat/channel_file_display_screen.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../controllers/theme_controller.dart';
import '../profile/profile.dart';
import 'channel_media_display_screen.dart';
import 'chat_home_page.dart';
import 'pinned_messages_screen.dart';

class DirectMessageSettings extends StatefulWidget {
  final Channel channel;

  const DirectMessageSettings({Key? key, required this.channel})
      : super(key: key);

  @override
  State<DirectMessageSettings> createState() => _DirectMessageSettingsState();
}

class _DirectMessageSettingsState extends State<DirectMessageSettings> {
  bool isMuteMessage = false;
  Channel get channel => widget.channel;
  @override
  void initState() {
    super.initState();
    isMuteMessage = channel.isMuted;
  }

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: channel,
      child: Scaffold(
        appBar: StreamChannelHeader(
          centerTitle: true,
          actions: [
            getLeadingWidget(
              channel,
              onTap: () => Get.to(() => ProfilePage(
                    userID: channel.state!.members
                        .where((element) =>
                            element.user!.id !=
                            Get.find<ChatController>().user!.uid)
                        .first
                        .user!
                        .id,
                  )),
            ),
            SizedBox(
              width: 5,
            ),
          ],
          // onImageTap: () => Get.to(() => ProfilePage(
          //       userID: channel.state!.members
          //           .where((element) =>
          //               element.user!.id !=
          //               Get.find<ChatController>().user!.uid)
          //           .first
          //           .user!
          //           .id,
          //     )),
          leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: backDIcon),
        ),
        body: Column(
          children: [
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
                })
          ],
        ),
      ),
    );
  }
}

class ListTileSwitch extends StatelessWidget {
  final String heading;
  final bool value;
  final void Function(bool)? onChange;
  const ListTileSwitch(
      {Key? key, required this.heading, required this.value, this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Text(
        heading,
      ),
      trailing: Switch.adaptive(
        activeColor: Color(Get.find<ThemeController>().globalColor),
        value: value,
        onChanged: onChange,
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  final String heading;
  final VoidCallback? onTap;
  const CustomListTile({Key? key, required this.heading, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      leading: Text(
        heading,
      ),
      trailing: forwardDIcon,
    );
  }
}
