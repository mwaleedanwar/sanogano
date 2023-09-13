import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/view/pages/chat/custom_chat_gif_widget.dart';
import 'package:sano_gano/view/pages/chat/custom_post_chat_widget.dart';
import 'package:sano_gano/view/pages/chat/direct_message_setting.dart';
import 'package:sano_gano/view/pages/chat/group_message_setting.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart' as userHeader;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:validated/validated.dart';

import '../../../controllers/theme_controller.dart';
import '../../../services/ImagePickerServices.dart';
import 'chat_home_page.dart';

class ChatPage extends StatefulWidget {
  final Channel channel;

  final String? initialMessageId;

  const ChatPage({Key? key, required this.channel, this.initialMessageId})
      : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late Channel channel;
  FocusNode? _focusNode;

  StreamMessageInputController _messageInputController =
      StreamMessageInputController();

  @override
  void initState() {
    channel = widget.channel;
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    super.dispose();
  }

  void _reply(Message message) {
    _messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _focusNode!.requestFocus();
    });
  }

  void _onClearReply() {
    _messageInputController.clear();
  }

  bool get isGroup => channel.extraData['isGroup'] as bool? ?? false;

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: channel,
      child: Scaffold(
        backgroundColor: StreamChatTheme.of(context).colorTheme.appBg,
        appBar: StreamChannelHeader(
          elevation: 0,
          leading: IconButton(onPressed: () => Get.back(), icon: backDIcon),
          showTypingIndicator: false,
          centerTitle: true,
          actions: [
            getLeadingWidget(
              channel,
              onTap: () async {
                if (!isGroup) {
                  final currentUser = StreamChat.of(context).currentUser;
                  final otherUser = channel.state!.members.firstWhereOrNull(
                    (element) => element.user!.id != currentUser!.id,
                  );
                  if (otherUser != null) {
                    Get.to(() => DirectMessageSettings(
                          channel: channel,
                        ));
                  }
                } else {
                  Get.to(() => GroupMessageSetting(
                        channel: channel,
                      ));
                }
              },
            ),
            SizedBox(
              width: 5,
            ),
          ],
        ),
        bottomSheet: Padding(
          padding: EdgeInsets.only(bottom: Platform.isIOS ? 15 : 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StreamTypingWidget(),
              StreamMessageInput(
                elevation: 0,
                // onQuotedMessageCleared: () {
                //   _onClearReply();
                // },
                attachmentButtonBuilder: (context, defaultActionButton) =>
                    defaultActionButton.copyWith(
                        color: Color(Get.find<ThemeController>().globalColor)),
                attachmentThumbnailBuilders: {
                  'gif': (_, attachment) => OptimizedCacheImage(
                      imageUrl: attachment.extraData['gif'] as String)
                },
                actions: [
                  // send gif
                  InkWell(
                    child: Icon(
                      Icons.gif,
                      size: 26,
                    ),
                    onTap: () async {
                      var _gif = await ImagePickerServices.getGif();

                      if (_gif == null) return;
                      String gifUrl = _gif.images!.previewWebp!.url;

                      _messageInputController.addAttachment(
                        Attachment(
                            uploadState: UploadState.success(),
                            type: 'gif',
                            extraData: {
                              'gif': gifUrl,
                            }),
                      );

                      setState(() {});
                    },
                  ),
                ],
                sendButtonLocation: SendButtonLocation.inside,
                enableMentionsOverlay: false,
                mentionAllAppUsers: false,
                // userMentionsTileBuilder: (context, user) => StreamUserMentionTile(
                //     user,
                //     title: Text(user.name,
                //         style: TextStyle(fontWeight: FontWeight.bold)),
                //     subtitle: SizedBox()),
                idleSendButton: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: sendMessageIcon.copyWith(opacity: 0.2, size: 24),
                ),
                activeSendButton: Padding(
                  padding: const EdgeInsets.only(
                    right: 8,
                  ),
                  child: sendMessageIcon.copyWith(opacity: 1, size: 24),
                ),
                onMessageSent: (message) {
                  if (channel.extraData['messageCount'] == null) {
                    channel.updatePartial(set: {'messageCount': 1});
                  }
                },
                preMessageSending: (message) {
                  if (message.text == "" || message.text == null) {
                    if (message.attachments.isNotEmpty) {
                      message = message.copyWith(
                          text: generateNotificationMessage(
                              message.attachments.first.type!));
                    }
                    return message;
                  } else {
                    message = message.copyWith(
                        text: message.text!
                            .removeWhiteSpacesBeforeAndAfterMessage());
                  }

                  return message;
                },
                focusNode: _focusNode,
                messageInputController: _messageInputController,
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(
                scrollToBottomBuilder:
                    (unreadCount, scrollToBottomDefaultTapAction) {
                  return Positioned(
                    bottom: 40,
                    right: 15,
                    width: 40,
                    height: 40,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        FloatingActionButton(
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              scrollToBottomDefaultTapAction(unreadCount);
                            },
                            child: StreamSvgIcon.down(
                              color: Color(0xff101418),
                            )),
                      ],
                    ),
                  );
                },
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                // onMessageSwiped: _reply,

                messageFilter: defaultFilter,
                emptyBuilder: (context) {
                  return SizedBox.shrink();
                },
                // footerBuilder: (context) {
                //add bottom of column element here instead

                messageBuilder: (context, details, messages, defaultMessage) {
                  return defaultMessage.copyWith(
                    textBuilder: (ctx, message) {
                      return handleMessageText(message, context);
                    },
                    onMessageTap: (message) {
                      print(message.text!.removeAllWhitespace);
                      print(message.text!.length);
                      for (var char in message.text!.split('')) {
                        print(char);
                      }
                    },
                    showReplyMessage: false,
                    textPadding: EdgeInsets.all(0),
                    showFlagButton: false,
                    attachmentBorderRadiusGeometry: BorderRadius.all(
                      Radius.circular(16),
                    ),
                    // onMentionTap: (user) =>
                    //     Get.to(() => ProfilePage(userID: user.id)),
                    customAttachmentBuilders: {
                      'post': (context, message, attachments) {
                        var post = PostModel.fromMap(jsonDecode(
                                attachments.first.extraData['post'].toString())
                            as Map<String, dynamic>);
                        return CustomChatPostWidget(
                          post: post,
                        );
                      },
                      'gif': (p0, p1, attachment) => CustomChatGifWidget(
                          url: attachment.first.extraData['gif'] as String),
                    },
                    onReplyTap: (message) {
                      _reply(message);
                    },

                    borderRadiusGeometry: BorderRadius.all(Radius.circular(16)),

                    // userAvatarBuilder: (p0, p1) {
                    //   return Padding(
                    //     padding: const EdgeInsets.symmetric(horizontal: 3),
                    //     child: userHeader.UserAvatar(
                    //       getChannelID(channel.client.state.currentUser!,
                    //           channel.state!.members),
                    //       radius: 12,
                    //     ),
                    //   );
                    // },
                  );
                },
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  Widget handleMessageText(Message message, BuildContext context) {
    // bool isMessageGif =
    //     message.attachments.any((element) => element.type == 'gif');
    // bool isMessageGifWithText = message.text != null &&
    //     message.attachments.any((element) => element.type == 'gif') &&
    //     message.text!.isNotEmpty;
    return message.attachments.isEmpty
        ? message.text == null
            ? SizedBox.shrink()
            : Container(
                decoration: BoxDecoration(
                    color:
                        isMyTextMessage(message) ? Colors.grey.shade300 : null,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.all(Radius.circular(16))),
                child: message.text!.isAllEmoji()
                    ? Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(
                          message.text ?? '',
                          style: TextStyle(fontSize: 38),
                        ),
                      )
                    : Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Text(message.text!
                                .removeWhiteSpacesBeforeAndAfterMessage() ??
                            ''),
                      ),
              )
        : Align(
            alignment:
                message.user!.id == StreamChat.of(context).currentUser!.id
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
            child: isAttachmentMessage(message.text!)
                ? SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                          color: null,
                          // color: (message.user!.id ==
                          //             StreamChat.of(context).currentUser!.id &&
                          //         !message.text!.isAllEmoji())
                          //     ? Colors.grey.shade300
                          //     : null,
                          border: null,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: message.text!.isAllEmoji()
                          ? Text(
                              message.text ?? '',
                              style: TextStyle(fontSize: 38),
                            )
                          : Text(
                              message.text!
                                      .removeWhiteSpacesBeforeAndAfterMessage() ??
                                  '',
                            ),
                    )),
          );
  }

  // bool isMyEmojiMessageWithoutTextHavingMoreThan3Characters(Message message) =>
  //     (message.user!.id == StreamChat.of(context).currentUser!.id &&
  //         message.text!.isAllEmoji() &&
  //         message.text!.removeAllWhitespace.length > 6);

  bool isMyTextMessage(Message message) =>
      (message.user!.id == StreamChat.of(context).currentUser!.id);
  bool isAwayTextMessage(Message message) =>
      (message.user!.id != StreamChat.of(context).currentUser!.id);
  // bool isAwayEmojiMessageWithoutTextHavingMoreThan3Characters(
  //         Message message) =>
  //     (message.user!.id != StreamChat.of(context).currentUser!.id &&
  //         message.text!.isAllEmoji() &&
  //         message.text!.removeAllWhitespace.length > 6);

  String generateNotificationMessage(String messageType) {
    // sb krky dekhchka print etc etc sb .. ye emoji and baqi b kch ni horhi recogi
    print("generating message type ");
    String type = messageType;
    switch (type) {
      case 'gif':
        type = "GIF";
        break;
      case 'image':
        type = "photo";
        break;
      case 'video':
        type = "video";
        break;
      case 'file':
        type = "file";
        break;
      case 'post':
        type = "post";
        break;
      default:
    }
    return 'Sent a $type';
  }

  List<String> _attachmentTypes = [
    'photo',
    'video',
    'file',
    'post',
    'GIF',
  ];

  bool isAttachmentMessage(String message) =>
      message.contains("Sent a ") &&
      _attachmentTypes.any((element) => message.contains(element));

  bool defaultFilter(Message m) {
    var _currentUser = StreamChat.of(context).currentUser;
    final isMyMessage = m.user?.id == _currentUser?.id;
    final isDeletedOrShadowed = m.isDeleted == true || m.shadowed == true;
    if (isDeletedOrShadowed && !isMyMessage) return false;
    return true;
  }
}

class StreamTypingWidget extends StatelessWidget {
  const StreamTypingWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      color: StreamChatTheme.of(context).colorTheme.appBg.withOpacity(.9),
      child: StreamTypingIndicator(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        style: StreamChatTheme.of(context).textTheme.footnote.copyWith(
            color: StreamChatTheme.of(context).colorTheme.textLowEmphasis),
      ),
    );
  }
}

String questionMarkEmoji = '❓';
String replaceIncompatibleEmojis(Message message) {
  String text = message.text ?? '';
  //all runes
  var runes = text.runes;
  for (var element in runes) {
    if (!isEmoji(String.fromCharCode(element))) {
      text = text.replaceAll(String.fromCharCode(element), questionMarkEmoji);
    }
  }
  return text;
}

extension StringExtension on String {
  bool isAllEmoji() {
    var runes = this.runes;
    for (var rune in runes) {
      var char = String.fromCharCode(rune);
      // regex for checking if char contains a . , or any other character
      if (char.contains(RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]')) ||
          char.contains(RegExp(r'[a-zA-Z0-9]'))) {
        return false;
      }
    }
    return true;
  }

  bool haveAtLeastOneEmoji() {
    var runes = this.runes;
    for (var rune in runes) {
      var char = String.fromCharCode(rune);
      if (char.contains(RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]')) ||
          char.contains(RegExp(r'[a-zA-Z0-9]'))) {
        return true;
      }
    }
    return false;
  }

  removeWhiteSpacesBeforeMessageStarts() {
    return this.replaceAll(RegExp(r"^\s+"), "");
  }

  removeWhiteSpacesAfterMessage() {
    return this.replaceAll(RegExp(r"\s+$"), "");
  }

  removeWhiteSpacesBeforeAndAfterMessage() {
    return this.replaceAll(RegExp(r"^\s+|\s+$"), "");
  }
}


//junk

// onShowMessage: (m, c) async {
//   print("on show message");
//   final client = StreamChat.of(context).client;
//   final message = m;
//   final channel = client.channel(
//     c.type,
//     id: c.id,
//   );
//   if (channel.state == null) {
//     await channel.watch();
//   }
//   Get.to(
//     () => ChatPage(
//       channel: channel,
//       initialMessageId: message.id,
//     ),
//   );
// },
//old body code
// Column(
//   children: <Widget>[
//     Expanded(
//       child: Stack(
//         children: <Widget>[
//           StreamMessageListView(
//             keyboardDismissBehavior:
//                 ScrollViewKeyboardDismissBehavior.manual,
//             onMessageSwiped: _reply,
//             messageFilter: defaultFilter,
//             emptyBuilder: (context) {
//               return SizedBox.shrink();
//             },
//             messageBuilder:
//                 (context, details, messages, defaultMessage) {
//               return defaultMessage.copyWith(
//                 textBuilder: (ctx, message) {
//                   return handleMessageText(message, context);
//                 },
//                 textPadding: EdgeInsets.all(0),
//                 onMentionTap: (user) =>
//                     Get.to(() => ProfilePage(userID: user.id)),
//                 customAttachmentBuilders: {
//                   'post': (context, message, attachments) {
//                     var post = PostModel.fromMap(jsonDecode(attachments
//                         .first.extraData['post']
//                         .toString()) as Map<String, dynamic>);
//                     return CustomChatPostWidget(
//                       post: post,
//                     );
//                   },
//                   'gif': (p0, p1, attachment) => CustomChatGifWidget(
//                       url: attachment.first.extraData['gif'] as String),
//                 },
//                 onReplyTap: (message) {
//                   _reply(message);
//                 },
//                 borderRadiusGeometry:
//                     BorderRadius.all(Radius.circular(16)),
//                 userAvatarBuilder: (p0, p1) {
//                   return userHeader.UserAvatar(
//                     getChannelID(channel.client.state.currentUser!,
//                         channel.state!.members),
//                     radius: 12,
//                   );
//                 },
//               );
//             },
//           ),
//           StreamTypingWidget(),
//         ],
//       ),
//     ),
//     StreamMessageInput(
//       elevation: 0,
//       onQuotedMessageCleared: () {
//         _onClearReply();
//       },
//       attachmentButtonBuilder: (context, defaultActionButton) =>
//           defaultActionButton.copyWith(
//               color: Color(Get.find<ThemeController>().globalColor)),
//       attachmentThumbnailBuilders: {
//         'gif': (_, attachment) => OptimizedCacheImage(
//             imageUrl: attachment.extraData['gif'] as String)
//       },
//       actions: [
//         // send gif
//         InkWell(
//           child: Icon(
//             Icons.gif,
//             size: 26,
//           ),
//           onTap: () async {
//             var _gif = await ImagePickerServices.getGif();

//             if (_gif == null) return;
//             String gifUrl = _gif.images!.previewWebp!.url;

//             _messageInputController.addAttachment(
//               Attachment(
//                   uploadState: UploadState.success(),
//                   type: 'gif',
//                   extraData: {
//                     'gif': gifUrl,
//                   }),
//             );

//             setState(() {});
//           },
//         ),
//       ],
//       sendButtonLocation: SendButtonLocation.inside,
//       enableMentionsOverlay: isGroup,
//       mentionAllAppUsers: false,
//       userMentionsTileBuilder: (context, user) => StreamUserMentionTile(
//           user,
//           title: Text(user.name,
//               style: TextStyle(fontWeight: FontWeight.bold)),
//           subtitle: SizedBox()),
//       idleSendButton: Padding(
//         padding: const EdgeInsets.only(
//           right: 8,
//         ),
//         child: sendMessageIcon.copyWith(opacity: 0.2, size: 24),
//       ),
//       activeSendButton: Padding(
//         padding: const EdgeInsets.only(
//           right: 8,
//         ),
//         child: sendMessageIcon.copyWith(opacity: 1, size: 24),
//       ),
//       onMessageSent: (message) {
//         print(message.id);

//         if (channel.extraData['messageCount'] == null) {
//           channel.updatePartial(set: {'messageCount': 1});
//         }
//       },
//       preMessageSending: (message) {
//         if ((message.text == "" || message.text == null) &&
//             message.attachments.isNotEmpty) {
//           print("pre message sending");
//           message = message.copyWith(
//               text: generateNotificationMessage(
//                   message.attachments.first.type!));
//           print(message.text);
//           return message;
//         }
//         print("pre message sending else condition");
//         return message;
//       },
//       focusNode: _focusNode,
//       messageInputController: _messageInputController,
//     ),
//   ],
// )

// message builder
// Row(
//     mainAxisAlignment:
//         message.user!.id == StreamChat.of(context).currentUser!.id
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//     // mainAxisSize: message.user!.id ==
//     //             StreamChat.of(context).currentUser!.id &&
//     //         !isMessageGifWithText &&
//     //         isMessageGif
//     //     ? MainAxisSize.min
//     //     : message.user!.id == StreamChat.of(context).currentUser!.id &&
//     //             isMessageGifWithText &&
//     //             isMessageGif
//     //         ? MainAxisSize.max
//     //         : message.user!.id == StreamChat.of(context).currentUser!.id
//     //             ? MainAxisSize.max
//     //             : MainAxisSize.min,
//     children: [
//       if (isAttachmentMessage(message.text!)) SizedBox.shrink(),
//       if (!isAttachmentMessage(message.text!))
//         Flexible(
//           flex: 1,
//           child: Padding(
//               padding:
//                   EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//               child: Text(
//                 message.text ?? '',
//               )),
//         ),
//     ],
//   )
