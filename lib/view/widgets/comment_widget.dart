// ignore_for_file: unused_local_variable

import 'dart:developer' as dev;

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/iconAssetStrings.dart';
import 'package:sano_gano/controllers/commentsController.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/commentLikes.dart';
import 'package:sano_gano/view/widgets/replies_page.dart';
import 'package:sano_gano/view/widgets/time_manager_strings.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

TextStyle get blackText =>
    TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black);

class CommentWidget extends StatelessWidget {
  final CommentModel? commentModel;
  final Function()? pinCommentCallback;
  final Function(String)? tagPersonCallback;
  final double? userAvatarSize;
  final bool? isMyPost;
  final String? postId;
  final bool? isReply;
  final String? isPinned;
  final VoidCallback? onDelete;
  final double? avatarGap;
  final double? footerPaddingLeft;

  CommentWidget({
    Key? key,
    this.commentModel,
    this.pinCommentCallback,
    this.tagPersonCallback,
    this.userAvatarSize,
    this.isReply = false,
    required this.postId,
    this.onDelete,
    this.isPinned,
    this.isMyPost = false,
    this.avatarGap,
    this.footerPaddingLeft,
  }) : super(key: key);
  RxBool temp = false.obs;
  RxInt likeCount = 0.obs;
  @override
  Widget build(BuildContext context) {
    String username = '';
    return GetBuilder<CommentsController>(
      init: CommentsController(),
      initState: (_) {},
      builder: (controller) {
        return Container(
          child: ListTile(
            onTap: null,
            minVerticalPadding: 0,
            dense: true,
            //  subtitle: commentBody(username, controller),
            title: commentBody(username, controller, context),
          ),
        );
      },
    );
  }

  Widget commentBody(
      String username, CommentsController controller, BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        extentRatio: 0.175,
        motion: ScrollMotion(),
        children: [
          // if (!controller.isMyComment(commentModel!))
          //   SlidableAction(
          //     backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,
          //     icon: FontAwesomeIcons.exclamation,
          //     onPressed: (_) async {
          //       CommentsController().reportComment(commentModel!);
          //     },
          //   ),

          // if (isMyPost && !isReply)
          //   IconSlideAction(
          //     // color: Get.isDarkMode?Colors.white:Colors.black,
          //     iconWidget: isPinned != null ? pinDIcon : pinnedDIcon,
          //     onTap: () async {
          //       pinCommentCallback();
          //     },
          //   ),
          if (isMyPost! || controller.isMyComment(commentModel!))
            SlidableAction(
              autoClose: true,
              backgroundColor: Get.isDarkMode ? Colors.black : Colors.white,

              // color:Get.isDarkMode?Colors.white:Colors.black,
              icon: FontAwesomeIcons.trash,
              onPressed: (_) {
                if (isMyPost! || controller.isMyComment(commentModel!)) {
                  Get.defaultDialog(
                    title: "Alert!",
                    content: Text("Are You Sure?"),
                    confirm: TextButton(
                        onPressed: () async {
                          await controller
                              .deleteComment(postId!, commentModel!,
                                  commentModel!.replyCount!)
                              .whenComplete(() {
                            // FocusScope.of(context).unfocus();
                            if (onDelete != null) {
                              onDelete!();
                            }
                            Get.back();
                          });
                        },
                        child: Text("Delete",
                            style: TextStyle(color: Colors.red))),
                    cancel: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: !Get.isDarkMode
                                  ? Colors.black
                                  : Colors.white),
                        )),
                  );
                }
              },
            ),
        ],
      ),
      enabled: (isMyPost! || controller.isMyComment(commentModel!)),
      child: InkWell(
        onTap: null,
        onDoubleTap: () async {
          var result = await controller.toggleLike(commentModel!);
          if (result)
            commentModel!.commentLikes = commentModel!.commentLikes! + 1;
          if (!result)
            commentModel!.commentLikes = commentModel!.commentLikes! - 1;
          controller.update();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    // SizedBox(
                    //   height: 5,
                    // ),
                    UserAvatar(
                      commentModel!.commenterId!,
                      radius: userAvatarSize ?? 12,
                      usernameCallback: (val) => username = val,
                    ),
                  ],
                ),
                SizedBox(
                  width: avatarGap ?? 10,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SelectableText.rich(
                      //   TextSpan(
                      //     children: [
                      //       TextSpan(
                      //         text: commentModel!.commentorName! + " ",
                      //         recognizer: TapGestureRecognizer()
                      //           ..onTap = () {
                      //             print('should go to user profile');
                      //             Get.to(() => ProfilePage(
                      //                 userID: commentModel!.commenterId!));
                      //           },
                      //         style: TextStyle(
                      //             fontWeight: FontWeight.bold, fontSize: 14),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Flexible(
                        child: CommentFormattedText(
                          commentModel!,
                          taggedUsersIdandUsername:
                              commentModel!.taggedUsersIdandUsername,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(left: Get.width * 0.090),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<bool>(
                      future: controller.isLiked(commentModel!.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Row(
                            children: [
                              SizedBox(
                                width: footerPaddingLeft,
                              ),
                              likeDIcon,
                              SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                width: 30,
                                child: Center(
                                  child: likeCount.value > 0
                                      ? Text(
                                          likeCount.value.toString(),
                                          style: blackText,
                                        )
                                      : Text('    '),
                                ),
                              ),
                            ],
                          );
                        }
                        temp.value = snapshot.data!;
                        likeCount.value = commentModel!.commentLikes!;
                        return Obx(() => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: footerPaddingLeft,
                                ),
                                InkWell(
                                    onTap: () async {
                                      temp.value = !temp.value;
                                      if (temp.value == true) {
                                        likeCount.value++;
                                      } else if (temp.value == false) {
                                        likeCount.value--;
                                      }

                                      EasyDebounce.debounce(
                                          'like-debouncer', // <-- An ID for this particular debouncer
                                          Duration(
                                              seconds:
                                                  3), // <-- The debounce duration
                                          () async {
                                        if (temp.value == true)
                                          commentModel!.commentLikes =
                                              commentModel!.commentLikes! + 1;
                                        if (temp.value == false)
                                          commentModel!.commentLikes =
                                              commentModel!.commentLikes! - 1;
                                        print('updating controller');
                                        await controller
                                            .toggleLike(commentModel!);
                                        controller.update();
                                      } // <-- The target method
                                          );

                                      // var result = await controller
                                      //     .toggleLike(commentModel);
                                    },
                                    child: temp.value ? likedDIcon : likeDIcon),
                                SizedBox(
                                  width: 5,
                                ),
                                InkWell(
                                  onTap: () {
                                    likeCount.value > 0
                                        ? Get.to(() => CommentLikesPage(
                                              commentModel: commentModel!,
                                            ))
                                        : null;
                                  },
                                  child: SizedBox(
                                    width: 30,
                                    child: Center(
                                      child: likeCount.value > 0
                                          ? Text(
                                              likeCount.value.toString(),
                                              style: blackText,
                                            )
                                          : Text('    '),
                                    ),
                                  ),
                                ),
                              ],
                            ));

                        // TextButton.icon(
                        //   onPressed: () async {
                        //     var result =
                        //         await controller.toggleLike(commentModel);
                        //     if (result) commentModel.commentLikes++;
                        //     if (!result) commentModel.commentLikes--;
                        //     controller.update();
                        //   },
                        //   icon: snapshot?.data ?? false
                        //       ? Icon(
                        //           Icons.favorite,
                        //           color: Colors.red,
                        //         )
                        //       : likeDIcon,
                        //   label: Text(
                        //     commentModel.commentLikes.toString(),
                        //     style: blackText,
                        //   ),
                        // );
                      }),

                  Text(
                    getTime(commentModel!.timestamp!),
                    style: TextStyle(color: Color(0xFF787878)),
                  ),
                  InkWell(
                    onTap: () {
                      if (commentModel!.isReply!) {
                        this.tagPersonCallback!("@$username");
                      } else {
                        Get.to(() => RepliesPage(
                              commentModel: commentModel!,
                              isMyPost: isMyPost!,
                            ));
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      width: Get.width * 0.175,
                      child: Text(
                        commentModel!.replyCount! > 1
                            ? "${commentModel!.replyCount} Replies"
                            : commentModel!.replyCount == 1
                                ? "1 Reply"
                                : "Reply",
                        textAlign: TextAlign.right,
                        style: blackText,
                      ),
                    ),
                  ),
                  // PopupMenuButton<int>(
                  //   icon: optionsSIcon,
                  //   onSelected: (value) => pinCommentCallback(),
                  //   itemBuilder: (context) =>
                  //       [PopupMenuItem<int>(value: 1, child: Text("Pin Comment"))],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentLikeButton extends StatelessWidget {
  final CommentModel commentModel;
  final CommentsController controller;
  CommentLikeButton(
      {Key? key, required this.commentModel, required this.controller})
      : super(key: key);
  RxBool temp = false.obs;
  RxInt likeCount = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FutureBuilder<bool>(
          initialData: false,
          future: controller.isLiked(commentModel.id!),
          builder: (context, snapshot) {
            temp.value = snapshot.data!;
            likeCount.value = commentModel.commentLikes!;

            return Obx(() => InkWell(
                  onTap: () {
                    temp.value = !temp.value;
                    if (temp.value == true) {
                      likeCount.value++;
                    } else if (temp.value == false) {
                      likeCount.value--;
                    }
                    EasyDebounce.debounce(
                        'like-debouncer', // <-- An ID for this particular debouncer
                        Duration(seconds: 3), // <-- The debounce duration
                        () => togglelikePost(
                            temp.value,
                            commentModel.commentLikes!,
                            likeCount.value) // <-- The target method
                        );
                  },
                  child: getLikeIcon(temp.value),
                ));
          },
        ),
        SizedBox(
          width: Get.width * 0.035,
        ),
        Obx(() => InkWell(
              onTap: () {
                Get.to(() => CommentLikesPage(
                      commentModel: commentModel,
                    ));
              },
              child: likeCount.value > 0
                  ? Text(likeCount.value.toString())
                  : Text(
                      '1',
                      style: TextStyle(color: Colors.transparent),
                    ),
            )),
      ],
    );
  }

  Future<void> togglelikePost(
      bool liked, int previousLikes, int currentlikes) async {
    bool result = liked;
    if (previousLikes != currentlikes) {
      if (result) {
        liked = true;
        commentModel.commentLikes = commentModel.commentLikes! + 1;
      } else {
        liked = false;
        commentModel.commentLikes = commentModel.commentLikes! - 1;
      }

      result = await controller.toggleLike(commentModel);
    }

    print(result);
    print(commentModel.commentLikes);
  }

  Widget getLikeIcon(bool likeStatus) {
    if (likeStatus) {
      return likedDIcon;
    } else {
      return likeDIcon;
    }
  }
}

class CommentFormattedText extends StatelessWidget {
  final CommentModel commentModel;
  final Map<String, dynamic>? taggedUsersIdandUsername;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final int? maxLines;

  CommentFormattedText(
    this.commentModel, {
    Key? key,
    this.style,
    this.taggedUsersIdandUsername,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.maxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    return ParsedText(
      text: commentModel.commentorName! + " " + commentModel.commentText!,
      style: style ?? defaultTextStyle.style,
      alignment: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      textDirection: textDirection ?? Directionality.of(context),
      overflow: TextOverflow.clip,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      parse: <MatchText>[
        MatchText(
          pattern: commentModel.commentorName!,
          renderWidget: ({required pattern, required text}) => Text(
            text,
            maxLines: 1,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: (String username) {
            Get.to(() => ProfilePage(userID: commentModel.commenterId!));
          },
        ),
        MatchText(
          pattern: r"@([a-z][a-z0-9_]{4,31})",
          renderWidget: ({required pattern, required text}) => Text(
            text,
            maxLines: 10,
            textDirection: TextDirection.ltr,
            style: TextStyle(
                decoration: TextDecoration.none,
                color: Color.fromARGB(255, 7, 66, 155)),
          ),
          onTap: (String username) {
            taggedUsersIdandUsername!.forEach((key, value) {
              dev.log(value);
              if ((value as String).toLowerCase() ==
                  username.replaceAll("@", "").toLowerCase()) {
                Get.to(ProfilePage(userID: key));
              }
            });
          },
        ),
      ],
      regexOptions: RegexOptions(caseSensitive: false),
    );
  }
}
