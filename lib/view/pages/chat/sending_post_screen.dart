import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/send_post_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../controllers/user_controller.dart';
import '../../../localizations.dart';
import '../profile/editProfile/editprofile.dart';
import 'chat_page.dart';
import 'custom_stream_subtitle.dart';

class SendingPostScreen extends StatefulWidget {
  final PostModel postModel;

  const SendingPostScreen({Key? key, required this.postModel})
      : super(key: key);

  @override
  State<SendingPostScreen> createState() => _SendingPostScreenState();
}

class _SendingPostScreenState extends State<SendingPostScreen> {
  ScrollController _scrollController = ScrollController();

  var postCaptionTEC = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  var uc = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return GetX<SendPostController>(
        init: SendPostController(context),
        builder: (spc) {
          return spc.isLoading
              ? Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Scaffold(
                  appBar: AppBar(
                    leading: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: backIcon),
                    elevation: 0,
                    actions: [
                      if (spc.selectedChannels.isNotEmpty)
                        IconButton(
                            onPressed: () async {
                              for (var element in spc.selectedChannels) {
                                PostModel postModel = widget.postModel;
                                if (postModel.hasGif) {
                                  postModel.gif = null;
                                }
                                PostModel toBeSent =
                                    PostModel(postId: postModel.postId);

                                await element.sendMessage(Message(
                                  text: "Sent a post",
                                  attachments: [
                                    Attachment(
                                      uploadState: UploadState.success(),
                                      type: 'post',
                                      extraData: {
                                        'post': toBeSent.toJson(),
                                      },
                                    ),
                                  ],
                                ));
                                if (element.extraData['messageCount'] == null) {
                                  await element.updatePartial(set: {
                                    'messageCount': 1,
                                  });
                                }
                              }
                              Get.back();
                            },
                            icon: sendDIcon),
                    ],
                    title: Text(
                      spc.selectedChannels.length > 1
                          ? "Send Separately"
                          : "Send",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Get.textTheme.bodyLarge!.color),
                    ),
                    centerTitle: true,
                  ),
                  bottomSheet: Container(
                    color: standardThemeModeColor,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          bottom: 30, left: 8, right: 8, top: 0),
                      child: SizedBox(
                        // height: Get.height * 0.07,
                        child: StatefulBuilder(
                          builder: (context, miniSetState) => Container(
                            // width: Get.width * 0.6,
                            child: TextField(
                              onChanged: (value) {
                                miniSetState(() {});
                              },
                              controller: postCaptionTEC,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              minLines: 1,
                              maxLines: 3,
                              decoration: InputDecoration(
                                isCollapsed: false,
                                isDense: true,
                                hintText: 'Message',

                                hintStyle: GoogleFonts.roboto(
                                    color: Color(0xFF787878)),
                                // contentPadding: EdgeInsets.symmetric(
                                //     vertical: 5.0, horizontal: 20.0),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFE8E9EB), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFE8E9EB), width: 1.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFFE8E9EB), width: 2.0),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                ),
                                suffixIconConstraints: BoxConstraints(
                                    maxHeight: 200,
                                    maxWidth: 200,
                                    minHeight: 20,
                                    minWidth: 20),
                                suffixIcon: GestureDetector(
                                    onTap: () async {
                                      PostModel postModel = widget.postModel;
                                      if (postModel.hasGif) {
                                        postModel.gif = null;
                                      }
                                      for (var element
                                          in spc.selectedChannels) {
                                        element.sendMessage(Message(
                                          text: postCaptionTEC.text,
                                          attachments: [
                                            Attachment(
                                              uploadState:
                                                  UploadState.success(),
                                              type: 'post',
                                              extraData: {
                                                'post': postModel.toJson(),
                                              },
                                            ),
                                          ],
                                        ));
                                        if (element.extraData['messageCount'] ==
                                            null) {
                                          element.updatePartial(set: {
                                            'messageCount': 1,
                                          });
                                        }
                                      }
                                      Get.back();
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 5, 10, 5),
                                        child: sendMessageIcon.copyWith(
                                            size: 24))),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: spc.isSearchActive
                      ? StreamMessageSearchListView(
                          separatorBuilder: (context, values, index) =>
                              Container(),
                          controller: spc.messageSearchListController!,
                          emptyBuilder: (_) {
                            return LayoutBuilder(
                              builder: (context, viewportConstraints) {
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: viewportConstraints.maxHeight,
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: StreamSvgIcon.search(
                                            size: 96,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .noResults,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          itemBuilder: messageBuilder,
                        )
                      : RefreshIndicator(
                          onRefresh: spc.channelListController!.refresh,
                          child: StreamChannelListView(
                            separatorBuilder: (context, values, index) =>
                                Container(),
                            controller: spc.channelListController!,
                            padding: EdgeInsets.only(bottom: 80),
                            shrinkWrap: true,
                            itemBuilder:
                                (context, channels, index, defaultWidget) {
                              // final chatTheme =
                              //     StreamChatTheme.of(context);
                              // final backgroundColor =
                              //     chatTheme.colorTheme.inputBg;
                              final channel = channels[index];
                              // final canDeleteChannel = channel
                              //     .ownCapabilities
                              //     .contains(PermissionType.deleteChannel);
                              // return channelTile(channel);
                              return ListTile(
                                  title: StreamChannelName(
                                      channel: channel,
                                      textStyle: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle: CustomChannelListTileSubtitle(
                                      channel: channel),
                                  trailing:
                                      spc.selectedChannels.contains(channel)
                                          ? selectedIcon
                                          : selectIcon,
                                  onTap: () {
                                    spc.selectedChannels.contains(channel)
                                        ? spc.removeChannelFromSelectedChannels(
                                            channel)
                                        : spc.addChannelToSelectedChannels(
                                            channel);
                                    setState(() {});
                                  });
                            },
                            onChannelTap: (channel) {
                              Get.to(
                                () => ChatPage(
                                  channel: channel,
                                ),
                              );
                            },
                            emptyBuilder: (_) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: StreamScrollViewEmptyWidget(
                                    emptyIcon: StreamSvgIcon.message(
                                      size: 148,
                                      color: StreamChatTheme.of(context)
                                          .colorTheme
                                          .disabled,
                                    ),
                                    emptyTitle: TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Start a chat',
                                        style: StreamChatTheme.of(context)
                                            .textTheme
                                            .bodyBold
                                            .copyWith(
                                              color: StreamChatTheme.of(context)
                                                  .colorTheme
                                                  .accentPrimary,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                );
        });
  }

  Widget channelTile(Channel channel) {
    SendPostController spc = Get.find<SendPostController>();
    return Obx(() => ListTile(
        title: StreamChannelName(
            channel: channel,
            textStyle: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: ChannelListTileSubtitle(channel: channel),
        trailing:
            spc.selectedChannels.contains(channel) ? selectedIcon : selectIcon,
        onTap: () {
          spc.selectedChannels.contains(channel)
              ? spc.selectedChannels.remove(channel)
              : spc.selectedChannels.add(channel);
        }));
  }

  // Widget channelTile(Channel channel) {
  //   return ;
  // }

  Widget messageBuilder(
    BuildContext context,
    List<GetMessageResponse> messageResponses,
    int index,
    StreamMessageSearchListTile defaultWidget,
  ) {
    final messageResponse = messageResponses[index];
    FocusScope.of(context).requestFocus(FocusNode());
    final client = StreamChat.of(context).client;
    final message = messageResponse.message;
    final channel = client.channel(
      messageResponse.channel!.type,
      id: messageResponse.channel!.id,
    );
    return channelTile(channel);
  }
}
