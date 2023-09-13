import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/chat_controller.dart';
import 'package:sano_gano/view/pages/chat/chat_confirmation_dialog.dart';
import 'package:sano_gano/view/pages/follow/followings.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart' as userHeader;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../../../controllers/theme_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../localizations.dart';
import '../../../utils.dart';
import '../../widgets/comment_widget.dart';
import 'chat_page.dart';
import 'custom_stream_subtitle.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  ScrollController _scrollController = ScrollController();

  late StreamMessageSearchListController _messageSearchListController =
      StreamMessageSearchListController(
    client: uc.chatClient,
    filter: Filter.in_('members', [StreamChat.of(context).currentUser!.id]),
    limit: 5,
    searchQuery: '',
    sort: [
      SortOption(
        'created_at',
        direction: SortOption.ASC,
      ),
    ],
  );

  TextEditingController? _controller;

  bool _isSearchActive = false;

  Timer? _debounce;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  void _channelQueryListener() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _messageSearchListController.searchQuery = _controller!.text;
        setState(() {
          _isSearchActive = _controller!.text.isNotEmpty;
        });
        if (_isSearchActive) _messageSearchListController.doInitialLoad();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_channelQueryListener);
  }

  @override
  void dispose() {
    _controller?.removeListener(_channelQueryListener);
    _controller?.dispose();
    _scrollController.dispose();
    // _channelListController.dispose();
    super.dispose();
  }

  var uc = Get.find<UserController>();
  @override
  Widget build(BuildContext context) {
    return GetX<ChatController>(
        init: ChatController(context: context),
        builder: (controller) {
          return SafeArea(
            bottom: false,
            top: false,
            child: Scaffold(
              appBar: AppBar(
                // bottom: TabBar(indicatorColor: globalColor, tabs: [
                //   Tab(
                //     text: "All",
                //   ),
                //   Tab(text: "Mentions"),
                // ]),
                leading:
                    IconButton(onPressed: () => Get.back(), icon: backDIcon),
                elevation: 0,
                title: Text(
                  "Messages",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Get.textTheme.bodyText1!.color),
                ),
                centerTitle: true,
                actions: [
                  IconButton(
                      onPressed: () {
                        Get.to(() => FollowingPage(
                              uc.userModel.id!,
                              onSelect: (user) async {
                                var client = StreamChat.of(context).client;
                                final channel = client.channel(
                                  "messaging",
                                  id: createChatID(uc.userModel.id!, user.id!),
                                  extraData: {
                                    "members": [uc.userModel.id!, user.id],
                                  },
                                );

                                await channel.watch();
                                Get.to(() => ChatPage(
                                      channel: channel,
                                    ));
                              },
                            ));
                      },
                      icon: newMessageDIcon),
                ],
              ),
              body: NotificationListener<ScrollUpdateNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (_scrollController.position.userScrollDirection ==
                        ScrollDirection.reverse) {
                      FocusScope.of(context).unfocus();
                    }
                    return true;
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: CupertinoSearchTextField(
                          key: Key("SearchField"),
                          suffixInsets: EdgeInsetsGeometry.lerp(
                              EdgeInsets.zero, EdgeInsets.only(right: 10), 1)!,
                          borderRadius: BorderRadius.circular(25),
                          controller: _controller,
                          style: blackText,
                          onSubmitted: (String _) {},
                          placeholder: AppLocalizations.of(context).search,
                        ),
                      ),
                      _isSearchActive
                          ? Expanded(
                              child: StreamMessageSearchListView(
                                scrollController: _scrollController,
                                physics: ClampingScrollPhysics(),
                                separatorBuilder: (context, values, index) =>
                                    Container(),
                                controller: _messageSearchListController,
                                errorBuilder: (p0, p1) => Container(),
                                emptyBuilder: (_) {
                                  return const SizedBox.shrink();
                                },
                                itemBuilder: (
                                  context,
                                  messageResponses,
                                  index,
                                  defaultWidget,
                                ) {
                                  final messageResponse =
                                      messageResponses[index];
                                  FocusScope.of(context)
                                      .requestFocus(FocusNode());
                                  final client = StreamChat.of(context).client;
                                  final message = messageResponse.message;
                                  final channel = client.channel(
                                    messageResponse.channel!.type,
                                    id: messageResponse.channel!.id,
                                  );
                                  return defaultWidget.copyWith(
                                    onTap: () async {
                                      if (channel.state == null) {
                                        await channel.watch();
                                      }
                                      Get.to(
                                        () => ChatPage(
                                          channel: channel,
                                          initialMessageId: message.id,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          : Expanded(
                              child: SlidableAutoCloseBehavior(
                                closeWhenOpened: true,
                                child: StreamChannelListView(
                                  scrollController: _scrollController,
                                  physics: ClampingScrollPhysics(),
                                  separatorBuilder: (context, values, index) =>
                                      Container(),
                                  controller: controller.channelListController!,
                                  itemBuilder: (context, channels, index,
                                      defaultWidget) {
                                    final channel = channels[index];
                                    return Slidable(
                                      groupTag: 'channels-actions',
                                      endActionPane: ActionPane(
                                        extentRatio: 0.4,
                                        motion: const BehindMotion(),
                                        children: [
                                          StreamBuilder<bool>(
                                              stream: channel.isMutedStream,
                                              builder: (context, snapshot) {
                                                var isMuted =
                                                    snapshot.data ?? false;
                                                // return SlidableAction(
                                                //   backgroundColor:
                                                //       StreamChatTheme.of(
                                                //               context)
                                                //           .colorTheme
                                                //           .barsBg,
                                                //   onPressed: (_) async {
                                                //     if (isMuted) {
                                                //       await channel.unmute();
                                                //     } else {
                                                //       await channel.mute();
                                                //     }
                                                //     await controller
                                                //         .channelListController!
                                                //         .refresh();

                                                //     // setState(() {});
                                                //   },
                                                //   autoClose: true,
                                                //   label: isMuted
                                                //       ? "Unmute"
                                                //       : "Mute",
                                                // );
                                                return CustomSlidableAction(
                                                    padding: EdgeInsets.zero,
                                                    flex: 1,
                                                    autoClose: true,
                                                    onPressed: (_) async {
                                                      if (isMuted) {
                                                        await channel.unmute();
                                                      } else {
                                                        await channel.mute();
                                                      }
                                                      await controller
                                                          .channelListController!
                                                          .refresh();

                                                      // setState(() {});
                                                    },
                                                    child: Container(
                                                      child: Center(
                                                        child: AutoSizeText(
                                                          isMuted
                                                              ? 'Unmute'
                                                              : 'Mute',
                                                        ),
                                                      ),
                                                    ));
                                              }),
                                          CustomSlidableAction(
                                              padding: EdgeInsets.zero,
                                              flex: 1,
                                              autoClose: true,
                                              onPressed: (_) async {
                                                if (isGroup(channel)) {
                                                  showGroupDeletionDialog(
                                                      channel);
                                                } else {
                                                  showDmDeletionDialog(channel);
                                                }
                                              },
                                              child: Container(
                                                color: Colors.red,
                                                child: Center(
                                                  child: AutoSizeText(
                                                    isGroup(channel)
                                                        ? 'Leave'
                                                        : 'Delete',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )),
                                          // SlidableAction(
                                          //   backgroundColor: Colors.red,
                                          //   onPressed: (_) async {
                                          //     if (isGroup(channel)) {
                                          //       showGroupDeletionDialog(
                                          //           channel);
                                          //     } else {
                                          //       showDmDeletionDialog(channel);
                                          //     }
                                          //   },
                                          //   autoClose: true,
                                          //   label: isGroup(channel)
                                          //       ? 'Leave'
                                          //       : 'Delete',
                                          // ),
                                        ],
                                      ),
                                      child: customStreamChatTile(channel),
                                    );
                                  },
                                  onChannelTap: (channel) {
                                    Get.to(
                                      () => ChatPage(
                                        channel: channel,
                                      ),
                                    );
                                  },
                                  emptyBuilder: (_) {
                                    return Container();
                                  },
                                ),
                              ),
                            )
                    ],
                  )),
            ),
          );
        });
  }

  bool isGroup(Channel channel) =>
      channel.extraData['isGroup'] as bool? ?? false;

  Widget customStreamChatTile(Channel channel) {
    final channelPreviewTheme = StreamChannelPreviewTheme.of(context);

    final title = StreamChannelName(
      channel: channel,
      textStyle: channelPreviewTheme.titleStyle,
    );

    final subtitle = CustomChannelListTileSubtitle(
      channel: channel,
      textStyle: channelPreviewTheme.subtitleStyle,
    );

    final trailing = ChannelLastMessageDate(
      channel: channel,
      textStyle: channelPreviewTheme.lastMessageAtStyle,
    );
    return StreamChannel(
      channel: channel,
      child: ListTile(
        onTap: () => Get.to(() => ChatPage(channel: channel)),
        title: title,
        subtitle: subtitle,
        leading: getLeadingWidget(channel),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 7.5,
            ),
            trailing,
            SizedBox(
              height: 3,
            ),
            StreamBuilder<int>(
              stream: channel.state!.unreadCountStream,
              initialData: 0,
              builder: (BuildContext context, snapshot) {
                if (snapshot.data == 0)
                  return Container(
                    height: 5,
                    width: 5,
                  );
                int messageCount = snapshot.data!;
                if (messageCount > 99) {
                  messageCount = 99;
                }
                return CircleAvatar(
                  // color: Colors.red,
                  backgroundColor:
                      Color(Get.find<ThemeController>().globalColor),
                  radius: 10,
                  child: Text(
                    messageCount.toString(),
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

String getChannelID(
  User currentUser,
  List<Member> members,
) {
  var channelID = "";
  final otherMembers = members.where(
    (member) => member.userId != currentUser.id,
  );

  if (otherMembers.isNotEmpty) {
    if (otherMembers.length == 1) {
      final user = otherMembers.first.user;
      if (user != null) {
        channelID = user.id;
      }
      return channelID;
    } else {
      return channelID;
    }
  }
  return channelID;
}

Widget getLeadingWidget(Channel channel, {VoidCallback? onTap}) {
  bool isGroup = channel.extraData['isGroup'] as bool? ?? false;
  final leading = isGroup
      ? userHeader.UserAvatar(
          '',
          autoFontSize: true,
          name: channel.name,
          image: channel.image,
          radius: 20,
          isdisabledTap: onTap != null,
        )
      : userHeader.UserAvatar(
          getChannelID(
              channel.client.state.currentUser!, channel.state!.members),
          autoFontSize: true,
          name: channel.name,
          image: channel.image,
          radius: 20,
          isdisabledTap: onTap != null,
        );
  if (onTap != null)
    return InkWell(
      onTap: onTap,
      child: leading,
    );

  return leading;
}

//* junk code
//NestedScrollView(
                  //   controller: _scrollController,
                  //   floatHeaderSlivers: false,
                  //   headerSliverBuilder: (_, __) => [
                  //     SliverToBoxAdapter(
                  //       child: Padding(
                  //         padding: const EdgeInsets.symmetric(
                  //             horizontal: 10, vertical: 10),
                  //         child: CupertinoSearchTextField(
                  //           key: Key("SearchField"),
                  //           borderRadius: BorderRadius.circular(25),
                  //           controller: _controller,
                  //           style: blackText,
                  //           onSubmitted: (String _) {},
                  //           placeholder: AppLocalizations.of(context).search,
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  //   body: _isSearchActive
                  //       ? StreamMessageSearchListView(
                  //           physics: ClampingScrollPhysics(),
                  //           separatorBuilder: (context, values, index) =>
                  //               Container(),
                  //           controller: _messageSearchListController,
                  //           errorBuilder: (p0, p1) => Container(),
                  //           emptyBuilder: (_) {
                  //             return Container();
                  //             // return LayoutBuilder(
                  //             //   builder: (context, viewportConstraints) {
                  //             //     return SingleChildScrollView(
                  //             //       physics: AlwaysScrollableScrollPhysics(),
                  //             //       child: ConstrainedBox(
                  //             //         constraints: BoxConstraints(
                  //             //           minHeight:
                  //             //               viewportConstraints.maxHeight,
                  //             //         ),
                  //             //         child: Center(
                  //             //           child: Column(
                  //             //             children: [
                  //             //               Padding(
                  //             //                 padding: const EdgeInsets.all(24),
                  //             //                 child: StreamSvgIcon.search(
                  //             //                   size: 96,
                  //             //                   color: Colors.grey,
                  //             //                 ),
                  //             //               ),
                  //             //               Text(
                  //             //                 AppLocalizations.of(context)
                  //             //                     .noResults,
                  //             //               ),
                  //             //             ],
                  //             //           ),
                  //             //         ),
                  //             //       ),
                  //             //     );
                  //             //   },
                  //             // );
                  //           },
                  //           itemBuilder: (
                  //             context,
                  //             messageResponses,
                  //             index,
                  //             defaultWidget,
                  //           ) {
                  //             return defaultWidget.copyWith(
                  //               onTap: () async {
                  //                 final messageResponse = messageResponses[index];
                  //                 FocusScope.of(context)
                  //                     .requestFocus(FocusNode());
                  //                 final client = StreamChat.of(context).client;
                  //                 final message = messageResponse.message;
                  //                 final channel = client.channel(
                  //                   messageResponse.channel!.type,
                  //                   id: messageResponse.channel!.id,
                  //                 );
                  //                 if (channel.state == null) {
                  //                   await channel.watch();
                  //                 }
                  //                 Get.to(
                  //                   () => ChatPage(
                  //                     channel: channel,
                  //                     initialMessageId: message.id,
                  //                   ),
                  //                 );
                  //               },
                  //             );
                  //           },
                  //         )
                  //       : SlidableAutoCloseBehavior(
                  //           closeWhenOpened: true,
                  //           child: RefreshWidget(
                  //             controller: _refreshController,
                  //             onRefresh: () async {
                  //               await controller.channelListController.refresh();
                  //               _refreshController.refreshCompleted();
                  //             },
                  //             child: StreamChannelListView(
                  //               physics: ClampingScrollPhysics(),
                  //               separatorBuilder: (context, values, index) =>
                  //                   Container(),
                  //               controller: controller.channelListController,
                  //               itemBuilder:
                  //                   (context, channels, index, defaultWidget) {
                  //                 final chatTheme = StreamChatTheme.of(context);
                  //                 final backgroundColor =
                  //                     chatTheme.colorTheme.inputBg;
                  //                 final channel = channels[index];
                  //                 final canDeleteChannel = channel.ownCapabilities
                  //                     .contains(PermissionType.deleteChannel);
                  //                 return Slidable(
                  //                   groupTag: 'channels-actions',
                  //                   endActionPane: ActionPane(
                  //                     extentRatio: 0.4,
                  //                     motion: const BehindMotion(),
                  //                     children: [
                  //                       StreamBuilder<bool>(
                  //                           stream: channel.isMutedStream,
                  //                           builder: (context, snapshot) {
                  //                             var isMuted =
                  //                                 snapshot.data ?? false;
                  //                             return SlidableAction(
                  //                               backgroundColor:
                  //                                   StreamChatTheme.of(context)
                  //                                       .colorTheme
                  //                                       .barsBg,
                  //                               onPressed: (_) async {
                  //                                 if (isMuted) {
                  //                                   await channel.unmute();
                  //                                 } else {
                  //                                   await channel.mute();
                  //                                 }
                  //                                 await controller
                  //                                     .channelListController
                  //                                     .refresh();

                  //                                 // setState(() {});
                  //                               },
                  //                               autoClose: true,
                  //                               label:
                  //                                   isMuted ? "Unmute" : "Mute",
                  //                             );
                  //                           }),
                  //                       SlidableAction(
                  //                         backgroundColor: Colors.red,
                  //                         onPressed: (_) async {
                  //                           if (isGroup(channel)) {
                  //                             showGroupDeletionDialog(channel);
                  //                           } else {
                  //                             showDmDeletionDialog(channel);
                  //                           }
                  //                         },
                  //                         autoClose: true,
                  //                         label: isGroup(channel)
                  //                             ? 'Leave'
                  //                             : 'Delete',
                  //                       ),
                  //                     ],
                  //                   ),
                  //                   child: customStreamChatTile(channel),
                  //                 );
                  //               },
                  //               onChannelTap: (channel) {
                  //                 Get.to(
                  //                   () => ChatPage(
                  //                     channel: channel,
                  //                   ),
                  //                 );
                  //               },
                  //               emptyBuilder: (_) {
                  //                 return Container();
                  //               },
                  //             ),
                  //           ),
                  //         ),
                  // )