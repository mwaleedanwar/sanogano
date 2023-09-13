import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/notifications_settings.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  @override
  _NotificationSettingsScreenState createState() =>
      _NotificationSettingsScreenState();
}

final TextStyle ts = TextStyle(fontWeight: FontWeight.bold);

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          back: true,
          title: "Notifications",
          iconButton: Container(),
        ),
        body: StreamBuilder<NotificationSettings>(
            stream: Get.find<UserController>()
                .notificationSettings(Get.find<AuthController>().user!.uid)
                .asStream(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(
                  child: CircularProgressIndicator(),
                );
              var settings = snapshot.data!.notificationSettings;
              return ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: [
                  SwitchListTile.adaptive(
                      activeColor: messageColor,
                      title: Text(
                        "Comments",
                        style: ts,
                      ),
                      value:
                          settings![NotificationType.Comment_On_Post] ?? false,
                      onChanged: (val) {
                        setState(() {});
                        NotificationService.updateNotificationSettings(
                            [NotificationType.Comment_On_Post],
                            val,
                            snapshot.data!);
                      }),
                  SwitchListTile.adaptive(
                      activeColor: messageColor,
                      title: Text(
                        "Likes",
                        style: ts,
                      ),
                      value: settings[NotificationType.Liked_your_post]!,
                      onChanged: (val) {
                        setState(() {});
                        NotificationService.updateNotificationSettings([
                          NotificationType.Liked_your_post,
                          NotificationType.Like_your_comment,
                          NotificationType.Liked_your_reply,
                          NotificationType.NEW_Like
                        ], val, snapshot.data!);
                      }),
                  SwitchListTile.adaptive(
                      activeColor: messageColor,
                      title: Text(
                        "New Followers",
                        style: ts,
                      ),
                      value: settings[NotificationType.STARTED_FOLLOWING_YOU]!,
                      onChanged: (val) {
                        setState(() {});
                        NotificationService.updateNotificationSettings([
                          NotificationType.STARTED_FOLLOWING_YOU,
                          NotificationType.FOLLOWED_YOU_BACK,
                          NotificationType.FOLLOW_REQUEST_ACCEPTED,
                          NotificationType.REQUEST_TO_FOLLOW
                        ], val, snapshot.data!);
                      }),
                  SwitchListTile.adaptive(
                      activeColor: messageColor,
                      title: Text(
                        "Tagged Comments",
                        style: ts,
                      ),
                      value: settings[
                          NotificationType.TAGGED_YOU_IN_THEIR_COMMENT]!,
                      onChanged: (val) {
                        setState(() {});
                        NotificationService.updateNotificationSettings(
                            [NotificationType.TAGGED_YOU_IN_THEIR_COMMENT],
                            val,
                            snapshot.data!);
                      }),
                  SwitchListTile.adaptive(
                      activeColor: messageColor,
                      title: Text(
                        "Tagged Posts",
                        style: ts,
                      ),
                      value:
                          settings[NotificationType.TAGGED_YOU_IN_THEIR_POST]!,
                      onChanged: (val) {
                        setState(() {});
                        NotificationService.updateNotificationSettings(
                            [NotificationType.TAGGED_YOU_IN_THEIR_POST],
                            val,
                            snapshot.data!);
                      })
                ],
              );
            })
        // body: ListView(
        //   physics: NeverScrollableScrollPhysics(),
        //   children: [
        //     // ListTile(
        //     //   onTap: () => Get.to(CommentSettingsScreen()),
        //     //   trailing: forwardDIcon,
        //     //   title: Text("Comments",style: ts,),
        //     // ),
        //     StreamBuilder<NotificationSettings>(
        //         stream: Get.find<UserController>()
        //             .notificationSettings(Get.find<AuthController>().user!.uid)
        //             .asStream(),
        //         builder: (context, snapshot) {
        //           if (!snapshot.hasData)
        //             return Center(
        //               child: CircularProgressIndicator(),
        //             );
        //           var settings = snapshot.data!.notificationSettings;
        //           return ListView(
        //             shrinkWrap: true,
        //             children: [
        //               SwitchListTile.adaptive(
        //                   activeColor: messageColor,
        //                   title: Text(
        //                     "Comments",
        //                     style: ts,
        //                   ),
        //                   value: settings![NotificationType.Comment_On_Post] ??
        //                       false,
        //                   onChanged: (val) {
        //                     setState(() {});
        //                     NotificationService.updateNotificationSettings(
        //                         NotificationType.Comment_On_Post,
        //                         val,
        //                         snapshot.data!);
        //                   }),
        //               SwitchListTile.adaptive(
        //                   activeColor: messageColor,
        //                   title: Text(
        //                     "Likes",
        //                     style: ts,
        //                   ),
        //                   value: settings[NotificationType.Liked_your_post]!,
        //                   onChanged: (val) {
        //                     setState(() {});
        //                     NotificationService.updateNotificationSettings(
        //                         NotificationType.Liked_your_post,
        //                         val,
        //                         snapshot.data!);
        //                   }),
        //               SwitchListTile.adaptive(
        //                   activeColor: messageColor,
        //                   title: Text(
        //                     "New Followers",
        //                     style: ts,
        //                   ),
        //                   value:
        //                       settings[NotificationType.STARTED_FOLLOWING_YOU]!,
        //                   onChanged: (val) {
        //                     setState(() {});
        //                     NotificationService.updateNotificationSettings(
        //                         NotificationType.STARTED_FOLLOWING_YOU,
        //                         val,
        //                         snapshot.data!);
        //                   }),
        //               SwitchListTile.adaptive(
        //                   activeColor: messageColor,
        //                   title: Text(
        //                     "Tagged Comments",
        //                     style: ts,
        //                   ),
        //                   value: settings[
        //                       NotificationType.TAGGED_YOU_IN_THEIR_COMMENT]!,
        //                   onChanged: (val) {
        //                     setState(() {});
        //                     NotificationService.updateNotificationSettings(
        //                         NotificationType.TAGGED_YOU_IN_THEIR_COMMENT,
        //                         val,
        //                         snapshot.data!);
        //                   }),
        //               SwitchListTile.adaptive(
        //                   // inactiveTrackColor:
        //                   //     Get.isDarkMode ? Colors.red : Colors.white,
        //                   // inactiveThumbColor:
        //                   //     Get.isDarkMode ? Colors.red : Colors.white,
        //                   activeColor: messageColor,
        //                   title: Text(
        //                     "Tagged Posts",
        //                     style: ts,
        //                   ),
        //                   value: settings[
        //                       NotificationType.TAGGED_YOU_IN_THEIR_POST]!,
        //                   onChanged: (val) {
        //                     setState(() {});
        //                     NotificationService.updateNotificationSettings(
        //                         NotificationType.TAGGED_YOU_IN_THEIR_POST,
        //                         val,
        //                         snapshot.data!);
        //                   })
        //             ],
        //           );
        //         }),
        //     // ListTile(
        //     //   onTap: () => Get.to(FollowerSettingsScreen()),
        //     //   trailing: forwardDIcon,
        //     //   title: Text(
        //     //     "Followers",
        //     //     style: ts,
        //     //   ),
        //     // ),
        //     // ListTile(
        //     //   onTap: () => Get.to(LikedSettingsScreen()),
        //     //   trailing: forwardDIcon,
        //     //   title: Text(
        //     //     "Likes",
        //     //     style: ts,
        //     //   ),
        //     // ),
        //     // ListTile(
        //     //   onTap: () => Get.to(TaggedSettingsScreen()),
        //     //   trailing: forwardDIcon,
        //     //   title: Text(
        //     //     "Tagged",
        //     //     style: ts,
        //     //   ),
        //     // ),
        //   ],
        // ),
        );
  }
}
