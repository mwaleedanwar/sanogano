import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/commentsController.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/models/notificationModel.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/view/pages/follow/widgets/follow_tile.dart';
import 'package:sano_gano/view/pages/notFoundPages/post_not_found.dart';
import 'package:sano_gano/view/pages/profile/editProfile/editprofile.dart';
import 'package:sano_gano/view/pages/profile/profile.dart';
import 'package:sano_gano/view/widgets/comment_widget.dart';
import 'package:sano_gano/view/widgets/replies_page.dart';
import 'package:sano_gano/view/widgets/show_post_widget.dart';
import 'package:sano_gano/view/widgets/time_manager_strings.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart';

class ActivityWidget extends StatefulWidget {
  final DetailedNotificationModel notification;

  ActivityWidget({Key? key, required this.notification}) : super(key: key);

  @override
  State<ActivityWidget> createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  final me = FirebaseAuth.instance.currentUser!.uid;

  bool followed = false;
  var db = UserDatabase();
  @override
  Widget build(BuildContext context) {
    var time = getTimeForNotificationsCustomizedUnder12Weeks(
      widget.notification.notificationModel.timestamp!,
    );
    UserModel user = widget.notification.sender;
    return time == ''
        ? Container()
        : Container(
            child: ListTile(
              leading: UserAvatar(
                widget.notification.notificationModel.senderUid!,
                radius: 13,
              ),
              horizontalTitleGap: 0,
              trailing: widget
                          .notification.notificationModel.notificationType !=
                      NotificationType.STARTED_FOLLOWING_YOU
                  ? null
                  : Container(
                      width: Get.width * 0.2,
                      child: FollowButton(
                        uid: widget.notification.notificationModel.senderUid!,
                        notificationMode: true,
                      ),
                    ),
              //  followed
              //     ? Container(
              //         width: 1,
              //       )
              //     : StreamBuilder<bool>(
              //         stream: FollowController()
              //             .isFollowed(me, widget.notificationModel.senderUid)
              //             .asStream()
              //             .asBroadcastStream(),
              //         builder: (context, snapshot) {
              //           if (!snapshot.hasData)
              //             return Container(
              //               width: 1,
              //             );
              //           if (snapshot.data)
              //             return Container(
              //               width: 1,
              //             );
              //           return Container(
              //             width: Get.width * 0.2,
              //             child: InkWell(
              //               onTap: () {
              //                 followed = true;
              //                 setState(() {});
              //                 FollowController().toggleFollow(
              //                     me, widget.notificationModel.senderUid);
              //               },
              //               child: AbsorbPointer(
              //                 absorbing: true,
              //                 child: StreamBuilder<UserModel>(
              //                     stream: UserDatabase()
              //                         .getUser(widget.notificationModel.senderUid)
              //                         .asStream()
              //                         .asBroadcastStream(),
              //                     builder: (context, snapshot) {
              //                       if (!snapshot.hasData) return Container();
              //                       return FollowButton(
              //                         userModel: snapshot.data,

              //                       );
              //                     }),
              //               ),
              //             ),
              //           );
              //         })

              title: Wrap(
                children: [
                  ParsedText(
                    selectable: true,
                    alignment: TextAlign.start,
                    parse: [
                      // if (widget.notifcation.sender != null)
                      MatchText(
                          type: ParsedType.CUSTOM,
                          pattern: user.username,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          onTap: (val) {
                            Get.to(ProfilePage(userID: user.id!));
                          }),
                      MatchText(
                          type: ParsedType.CUSTOM,
                          pattern:
                              widget.notification.notificationModel.senderName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          onTap: (val) {
                            Get.to(ProfilePage(
                                userID: widget.notification.notificationModel
                                    .senderUid!));
                          }),
                      MatchText(
                          type: ParsedType.CUSTOM,
                          pattern: "post",
                          style: TextStyle(fontWeight: FontWeight.bold),
                          onTap: (val) async {
                            PostModel? postModel = await PostController()
                                .getPost(widget
                                    .notification.notificationModel.postId!);
                            if (postModel != null) {
                              Get.to(
                                  () => ShowPostWidget(postModel: postModel));
                            } else {
                              Get.to(() => PostNotFound());
                            }
                          }),
                      MatchText(
                          type: ParsedType.CUSTOM,
                          pattern: r'comment\b',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          onTap: (val) async {
                            CommentModel? commentModel =
                                await CommentsController().getComment(
                                    widget.notification.notificationModel
                                        .originalCommentId!,
                                    widget.notification.notificationModel
                                        .postId!);
                            if (commentModel != null) {
                              Get.to(RepliesPage(
                                commentModel: commentModel,
                                isMyPost: commentModel.posterId == me,
                              ));
                            } else {
                              Fluttertoast.showToast(msg: "Comment not found");
                            }
                            // Get.to(Scaffold(
                            //   appBar: CustomAppBar(
                            //     back: true,
                            //   ),
                            //   body: PostWidget(
                            //     postModel: postModel!,
                            //     postId: postModel.postId,
                            //     // miniMode: true,
                            //   ),
                            // ));
                          }),
                      MatchText(
                          type: ParsedType.CUSTOM,
                          pattern: time,
                          style: TextStyle(
                              color: standardContrastColor.withOpacity(0.5)),
                          onTap: (val) async {}),
                    ],
                    style: blackText.copyWith(fontSize: 14),
                    text: widget
                            .notification.notificationModel.notificationBody! +
                        " " +
                        time,
                  ),
                  // Text(
                  //   getTimeForNotifications(
                  //     widget.notificationModel.timestamp!,
                  //   ),
                  //   style: TextStyle(
                  //       color: standardContrastColor.withOpacity(0.5)),
                  // ),
                ],
              ),
              //  Text(
              //   notificationModel.notificationBody,
              //   style: TextStyle(fontWeight: FontWeight.bold),
              // ),
              //  subtitle: Text(notificationModel.notificationBody),
            ),
          );
  }
}
