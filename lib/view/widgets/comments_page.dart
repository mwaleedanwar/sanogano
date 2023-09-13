import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/commentsController.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/globalHelperMethods.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/global/custom_icon.dart';
import 'package:sano_gano/view/global/space.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/widgets/comment_widget.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';
import 'package:collection/collection.dart';
import '../../controllers/theme_controller.dart';
import '../../models/user.dart';
import '../../utils.dart';

class CommentPage extends StatefulWidget {
  final String postId;
  final PostModel postModel;
  final bool showKeyboard;
  final Function(int) onCommentCountChanged;

  const CommentPage(
      {Key? key,
      required this.postId,
      required this.postModel,
      required this.onCommentCountChanged,
      required this.showKeyboard})
      : super(key: key);
  @override
  _CommentPageState createState() => _CommentPageState();
}

enum SortMode { most_liked, new_to_old, old_to_new }

class _CommentPageState extends State<CommentPage> {
  var db = Database();
  var currentUser = Get.find<UserController>();
  var sortMode = SortMode.most_liked;
  var commentTEC = TextEditingController();
  UserController userController = Get.find<UserController>();
  sort(SortMode _sortMode) {
    sortMode = _sortMode;
    setState(() {});
  }

  Query get query {
    switch (sortMode) {
      case SortMode.most_liked:
        log(sortMode.toString());

        return db
            .commentsCollection(widget.postId)
            .orderBy('commentLikes', descending: true);

      case SortMode.new_to_old:
        return db
            .commentsCollection(widget.postId)
            .orderBy('timestamp', descending: true);

      case SortMode.old_to_new:
        return db
            .commentsCollection(widget.postId)
            .orderBy('timestamp', descending: false);

      default:
        return db
            .commentsCollection(widget.postId)
            .orderBy('timestamp', descending: true);
    }
  }

  var lastSearchTerm = '';
  @override
  void initState() {
    super.initState();
    var c = Get.put(CommentsController());
    c.userCommentStream(widget.postId).listen((event) {
      if (event.docs.length > 0) {
        userHasComments = true;
      } else {
        userHasComments = false;
      }
      if (mounted) setState(() {});
    });

    c.commentCountStream(widget.postId).listen((event) {
      print("comment count $event");
    });

    commentTEC.addListener(() {
      var atsInLastTerm =
          lastSearchTerm.characters.where((p0) => p0 == "@").length;

      var atsInLatestTerm =
          commentTEC.text.characters.where((p0) => p0 == "@").length;

      if (commentTEC.text.isNotEmpty && lastSearchTerm != commentTEC.text) {
        lastSearchTerm = commentTEC.text;

        if (commentTEC.text[commentTEC.text.length - 1] == "@" &&
            atsInLatestTerm > atsInLastTerm) {
          triggerMentions(
            onSelect: (user) {
              taggedUsers.add(user);
              commentTEC.text = commentTEC.text
                      .substring(0, commentTEC.selection.baseOffset) +
                  "${user.username}" +
                  commentTEC.text.substring(commentTEC.selection.extentOffset);
              // add a space
              commentTEC.text = commentTEC.text + " ";
              // move cursor to end
              commentTEC.selection = TextSelection.fromPosition(
                  TextPosition(offset: commentTEC.text.length));
              Get.back();
            },
            onlyShow: [
              ...userController.followerList,
              ...userController.followingList
            ].toSet().toList(),
            onSelectUserWhenEmpty: (user) {
              taggedUsers.add(user);
              commentTEC.text = commentTEC.text
                      .substring(0, commentTEC.selection.baseOffset) +
                  "${user.username}" +
                  commentTEC.text.substring(commentTEC.selection.extentOffset);
              // add a space
              commentTEC.text = commentTEC.text + " ";
              // move cursor to end
              commentTEC.selection = TextSelection.fromPosition(
                  TextPosition(offset: commentTEC.text.length));
              Get.back();
            },
          );
        }
      }
    });
  }

  List<UserModel> taggedUsers = [];
  var commentcount = 0;

  var userHasComments = false;
  @override
  Widget build(BuildContext context) {
    widget.showKeyboard
        ? SystemChannels.textInput.invokeMethod('TextInput.show')
        : SystemChannels.textInput.invokeMethod('TextInput.hide');

    return GetBuilder<CommentsController>(
      init: CommentsController(),
      initState: (_) {},
      builder: (controller) {
        return KeyboardDismisser(
          child: Scaffold(
            // backgroundColor: Colors.white, TODO fixed dark theme
            appBar: PreferredSize(
                child: StreamBuilder<int>(
                    stream: controller.commentCountStream(widget.postId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        widget.onCommentCountChanged(snapshot.data!);
                      }
                      commentcount = snapshot.data ?? commentcount;
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
                            ? "${squeezeNumbers(snapshot.data) ?? 'No'} Comment"
                            : "${squeezeNumbers(snapshot.data) ?? 'No'} Comments",
                      );
                    }),
                preferredSize: Size.fromHeight(kToolbarHeight)),
            bottomSheet: Container(
              color: standardThemeModeColor,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 30, left: 8, right: 14, top: 0),
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
                              scrollPadding: EdgeInsets.zero,
                              onChanged: (value) {
                                miniSetState(() {});
                              },
                              autofocus: widget.showKeyboard,
                              controller: commentTEC,
                              textAlignVertical: TextAlignVertical.center,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.done,
                              minLines: 1,
                              maxLines: 3,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 9),
                                isCollapsed: false,
                                isDense: true,
                                hintText: 'Leave a Comment',

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
                                      if (commentTEC.text.isNotEmpty) {
                                        var str = commentTEC.text;
                                        final tags = taggedUsers;
                                        commentTEC.clear();
                                        taggedUsers = [];
                                        if (sortMode != SortMode.new_to_old)
                                          sort(SortMode.new_to_old);
                                        await controller.postComment(
                                            widget.postId, str,
                                            taggedUsersIdandUsersName: Map<
                                                    String,
                                                    dynamic>.fromEntries(
                                                tags.map((e) {
                                              if (str.contains(e.username!)) {
                                                return MapEntry(
                                                    e.id!, e.username);
                                              }
                                              return null;
                                            }).whereNotNull()),
                                            taggedIds: tags
                                                .map((user) =>
                                                    str.contains(user.username!)
                                                        ? user.id!
                                                        : null)
                                                .whereNotNull()
                                                .toList());
                                        userHasComments = true;
                                        setState(() {});
                                      }
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 10, 10, 10),
                                        child: CustomIcon(
                                            image:
                                                'assets/icons/Send_Message.ai.svg',
                                            size: 23,
                                            color: commentTEC.text.isNotEmpty
                                                ? Color(
                                                    Get.find<ThemeController>()
                                                        .globalColor)
                                                : Colors.grey))),
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
                  FutureBuilder(
                    future: controller.getPinnedComment(
                      widget.postId,
                    ),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data == null) return Container();
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [pinDIcon, Text("Pinned Comment")],
                          ),
                          CommentWidget(
                            postId: widget.postId,
                            pinCommentCallback: () async {
                              await controller.db.postsCollection
                                  .doc(widget.postId)
                                  .update({'pinnedCommentID': ""});
                              setState(() {});
                            },
                            isMyPost: widget.postModel.ownerId ==
                                currentUser.userModel.id,
                            commentModel: snapshot.data,
                          ),
                        ],
                      );
                    },
                  ),
                  // if (userHasComments)
                  // Container(
                  //   child: StreamBuilder(
                  //     stream: controller.userCommentStream(
                  //       widget.postId,
                  //     ),
                  //     builder: (BuildContext context,
                  //         AsyncSnapshot<QuerySnapshot<Object>> snapshot) {
                  //       print("inside users comments");

                  //       if (snapshot.data == null)
                  //         return Container(
                  //           height: 0,
                  //         );
                  //       print(snapshot.data!.docs.length);
                  //       return Column(
                  //         children: [
                  //           ...List.generate(
                  //             snapshot.data!.docs.length,
                  //             (index) {
                  //               return Container(
                  //                 child: CommentWidget(
                  //                   postId: widget.postId,
                  //                   pinCommentCallback: () async {
                  //                     print("making pin");
                  //                     await controller.db.postsCollection
                  //                         .doc(widget.postId)
                  //                         .update({'pinnedCommentID': ""});
                  //                     setState(() {});
                  //                   },
                  //                   isMyPost: widget.postModel.ownerId ==
                  //                       currentUser.userModel.id,
                  //                   commentModel: CommentModel.fromFirestore(
                  //                       null,
                  //                       querydocumentSnapshot: snapshot
                  //                               .data!.docs[index]
                  //                           as QueryDocumentSnapshot<
                  //                               Map<String, dynamic>>),
                  //                 ),
                  //               );
                  //             },
                  //           )
                  //         ],
                  //       );
                  //       // return ListView.builder(
                  //       //   reverse: true,
                  //       //   physics: ClampingScrollPhysics(),
                  //       //   shrinkWrap: true,
                  //       //   itemCount: snapshot.data.docs.length,
                  //       //   itemBuilder: (BuildContext context, int index) {
                  //       //     return Container(

                  //       //       child: CommentWidget(
                  //       //         postId: widget.postId,
                  //       //         pinCommentCallback: () async {
                  //       //           print("making pin");
                  //       //           await controller.db.postsCollection
                  //       //               .doc(widget.postId)
                  //       //               .update({'pinnedCommentID': ""});
                  //       //           setState(() {});
                  //       //         },
                  //       //         isMyPost: widget.postModel.ownerId ==
                  //       //             currentUser.userModel.id,
                  //       //         commentModel: CommentModel.fromFirestore(null,
                  //       //             querydocumentSnapshot:
                  //       //                 snapshot.data.docs[index]),
                  //       //       ),
                  //       //     );
                  //       //   },
                  //       // );
                  //     },
                  //   ),
                  // ),
                  StreamBuilder<SortMode>(
                      stream: Stream.value(sortMode),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        }
                        return Container(
                          width: Get.width,
                          child: PaginateFirestore(
                            onEmpty: Container(
                                // alignment: Alignment.topCenter,
                                // child: Padding(
                                //   padding: EdgeInsets.only(top: Get.height * 0.4),
                                //   child: Text("No Comments"),
                                // ),
                                ),
                            shrinkWrap: true,
                            //item builder type is compulsory.
                            itemBuilder: (_, docs, index) {
                              CommentModel comment = CommentModel.fromFirestore(
                                  docs[index] as DocumentSnapshot<
                                      Map<String, dynamic>>);
                              // if ((comment.commenterId ==
                              //     Get.find<AuthController>().user!.uid))
                              //   return Container();
                              // log(comment.timestamp.toString());
                              // log(comment.commentText!);
                              return Container(
                                child: CommentWidget(
                                  postId: widget.postId,
                                  isMyPost: widget.postModel.ownerId ==
                                      currentUser.userModel.id,
                                  commentModel: comment,
                                  tagPersonCallback: (val) {},
                                  isPinned: widget.postModel.pinnedCommentID,
                                  pinCommentCallback: () async {
                                    await controller.db.postsCollection
                                        .doc(widget.postId)
                                        .update({
                                      'pinnedCommentID': docs[index].id
                                    });
                                    setState(() {});
                                  },
                                ),
                              );
                            },
                            // orderBy is compulsory to enable paginationF
                            query: query,
                            //Change types accordingly
                            itemBuilderType: PaginateBuilderType.listView,
                            // to fetch real-time data
                            isLive: true,
                            physics: ClampingScrollPhysics(),
                          ),
                        );
                      }),
                  addHeight(100)
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
