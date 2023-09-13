import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/commentsController.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/global/custom_icon.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/comment_widget.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

import '../../controllers/theme_controller.dart';
import '../../utils.dart';
import '../../utils/globalHelperMethods.dart';
import 'comments_page.dart';

class RepliesPage extends StatefulWidget {
  final CommentModel commentModel;
  final bool isMyPost;

  const RepliesPage(
      {Key? key, required this.commentModel, required this.isMyPost})
      : super(key: key);

  @override
  _RepliesPageState createState() => _RepliesPageState();
}

class _RepliesPageState extends State<RepliesPage> {
  var db = Database();
  var currentUser = Get.find<UserController>();
  var sortMode = SortMode.old_to_new;
  var replyNode = FocusNode();
  var replyTEC = TextEditingController();
  UserController userController = Get.find<UserController>();
  String lastSearchTerm = '';

  List<UserModel> taggedUsers = [];

  sort(SortMode _sortMode) {
    sortMode = _sortMode;
    setState(() {});
  }

  Query get query {
    switch (sortMode) {
      case SortMode.most_liked:
        return widget.commentModel.repliesRef
            .orderBy('commentLikes', descending: true);

      case SortMode.new_to_old:
        return widget.commentModel.repliesRef
            .orderBy('timestamp', descending: true);

      case SortMode.old_to_new:
        return widget.commentModel.repliesRef
            .orderBy('timestamp', descending: false);

      default:
        return widget.commentModel.repliesRef
            .orderBy('timestamp', descending: true);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.commentModel.replyCount == 0) {
      replyNode.requestFocus();
    }

    replyTEC.addListener(() {
      var atsInLastTerm =
          lastSearchTerm.characters.where((p0) => p0 == "@").length;

      var atsInLatestTerm =
          replyTEC.text.characters.where((p0) => p0 == "@").length;

      if (replyTEC.text.isNotEmpty && lastSearchTerm != replyTEC.text) {
        lastSearchTerm = replyTEC.text;

        if (replyTEC.text[replyTEC.text.length - 1] == "@" &&
            atsInLatestTerm > atsInLastTerm) {
          triggerMentions(
            onSelect: (user) {
              taggedUsers.add(user);
              replyTEC.text =
                  replyTEC.text.substring(0, replyTEC.selection.baseOffset) +
                      "${user.username}" +
                      replyTEC.text.substring(replyTEC.selection.extentOffset);
              // add space after username
              replyTEC.text = replyTEC.text + " ";
              // move cursor to end
              replyTEC.selection = TextSelection.fromPosition(
                  TextPosition(offset: replyTEC.text.length));
              Get.back();
            },
            onlyShow: [
              ...userController.followerList,
              ...userController.followingList
            ].toSet().toList(),
            onSelectUserWhenEmpty: (user) {
              taggedUsers.add(user);
              replyTEC.text =
                  replyTEC.text.substring(0, replyTEC.selection.baseOffset) +
                      "${user.username}" +
                      replyTEC.text.substring(replyTEC.selection.extentOffset);
              // add space after username
              replyTEC.text = replyTEC.text + " ";
              // move cursor to end
              replyTEC.selection = TextSelection.fromPosition(
                  TextPosition(offset: replyTEC.text.length));
              Get.back();
            },
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentsController>(
      init: CommentsController(),
      initState: (_) {},
      builder: (controller) {
        return Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: StreamBuilder<int>(
                stream: controller.repliesCount(
                    widget.commentModel.postId!, widget.commentModel.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox();
                  }
                  return CustomAppBar(
                    back: true,
                    iconButton: PopupMenuButton<SortMode>(
                      icon: sortDIcon,
                      onSelected: (value) => sort(value),
                      itemBuilder: (context) => [
                        PopupMenuItem<SortMode>(
                          value: SortMode.most_liked,
                          child: Text(
                            "Most Liked",
                            style: TextStyle(
                                fontWeight: sortMode == SortMode.most_liked
                                    ? FontWeight.bold
                                    : null),
                          ),
                        ),
                        PopupMenuItem<SortMode>(
                          value: SortMode.new_to_old,
                          child: Text(
                            "New to Old",
                            style: TextStyle(
                                fontWeight: sortMode == SortMode.new_to_old
                                    ? FontWeight.bold
                                    : null),
                          ),
                        ),
                        PopupMenuItem<SortMode>(
                          value: SortMode.old_to_new,
                          child: Text(
                            "Old to New",
                            style: TextStyle(
                                fontWeight: sortMode == SortMode.old_to_new
                                    ? FontWeight.bold
                                    : null),
                          ),
                        ),
                      ],
                    ),
                    title: snapshot.data == 1
                        ? "${squeezeNumbers(snapshot.data) ?? 'No'} Reply"
                        : "${squeezeNumbers(snapshot.data) ?? 'No'} Replies",
                  );
                }),
          ),
          bottomSheet: Container(
            color: standardThemeModeColor,
            child: Padding(
              padding:
                  const EdgeInsets.only(bottom: 30, left: 8, right: 14, top: 0),
              child: SizedBox(
                height: Get.height * 0.07,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: UserAvatar(
                        currentUser.userModel.id!,
                        radius: 24,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    StatefulBuilder(
                      builder: (context, miniSetState) => Expanded(
                        child: Container(
                          width: Get.width * 0.835,
                          child: TextFormField(
                            onChanged: (value) {
                              miniSetState(() {});
                            },
                            controller: replyTEC,
                            focusNode: replyNode,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            minLines: 1,
                            maxLines: 3,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              isCollapsed: false,

                              hintText: 'Reply to Comment',
                              hintStyle: TextStyle(color: Color(0xFF787878)),
                              alignLabelWithHint: true,
                              isDense: true,
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
                                    if (replyTEC.text.isNotEmpty) {
                                      await controller.postAReplyComment(
                                          widget.commentModel, replyTEC.text,
                                          taggedUsersIdandUsersName:
                                              Map<String, dynamic>.fromEntries(
                                                  taggedUsers.map((e) =>
                                                      MapEntry(
                                                          e.id!, e.username))),
                                          taggedIds: taggedUsers
                                              .map((user) => user.id!)
                                              .toList());
                                      widget.commentModel.replyCount =
                                          widget.commentModel.replyCount! + 1;
                                      replyTEC.clear();
                                      setState(() {});
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 15, 5),
                                    child: sendMessageIcon.copyWith(
                                        size: 23,
                                        color: replyTEC.text.isNotEmpty
                                            ? Color(Get.find<ThemeController>()
                                                .globalColor)
                                            : Colors.grey),
                                  )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                StreamBuilder<SortMode>(
                    stream: Stream.value(sortMode),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return Center(
                          child: CircularProgressIndicator.adaptive(),
                        );
                      }
                      return Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(
                                  top: 5,
                                ),
                                margin: EdgeInsets.fromLTRB(3, 0, 3, 3),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Get.isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                ),
                                child: AbsorbPointer(
                                  absorbing: true,
                                  child: CommentWidget(
                                    avatarGap: 10,
                                    footerPaddingLeft: 5,
                                    postId: widget.commentModel.postId,
                                    commentModel: widget.commentModel,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              RefreshIndicator(
                                onRefresh: () => 2.seconds.delay(),
                                child: PaginateFirestore(
                                  physics: ClampingScrollPhysics(),
                                  onEmpty: Center(),
                                  shrinkWrap: true,
                                  //item builder type is compulsory.
                                  itemBuilder: (_, docs, index) {
                                    var comment = CommentModel.fromFirestore(
                                        docs[index] as DocumentSnapshot<
                                            Map<String, dynamic>>);
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 4,
                                        left: 10,
                                      ),
                                      child: CommentWidget(
                                        isReply: true,
                                        postId: comment.postId,
                                        userAvatarSize: 9,
                                        isMyPost: widget.isMyPost,
                                        commentModel: comment,
                                        tagPersonCallback: (val) {
                                          replyTEC.text =
                                              replyTEC.text + val + " ";
                                          replyNode.requestFocus();
                                          // move cursor to end
                                          replyTEC.selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: replyTEC
                                                          .text.length));
                                        },
                                        onDelete: () async {
                                          // widget.commentModel.ref!.update({
                                          //   'replyCount':
                                          //       FieldValue.increment(-1)
                                          // });
                                          widget.commentModel.replyCount =
                                              widget.commentModel.replyCount! -
                                                  1;
                                          setState(() {
                                            print(
                                                widget.commentModel.replyCount);
                                          });
                                        },
                                      ),
                                    );
                                  },
                                  // orderBy is compulsory to enable pagination
                                  query: query,
                                  //Change types accordingly
                                  itemBuilderType: PaginateBuilderType.listView,
                                  // to fetch real-time data
                                  isLive: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
