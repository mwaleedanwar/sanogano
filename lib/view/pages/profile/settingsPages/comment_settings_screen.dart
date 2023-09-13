// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sano_gano/controllers/auth_controller.dart';
// import 'package:sano_gano/controllers/user_controller.dart';
// import 'package:sano_gano/models/notifications_settings.dart';
// import 'package:sano_gano/services/notificationService.dart';
// import 'package:sano_gano/view/global/custom_appbar.dart';
// import 'package:sano_gano/view/global/custom_icon.dart';

// import '../../../../controllers/theme_controller.dart';

// class CommentSettingsScreen extends StatefulWidget {
//   @override
//   _CommentSettingsScreenState createState() => _CommentSettingsScreenState();
// }

// class _CommentSettingsScreenState extends State<CommentSettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         back: true,
//         title: "Comments",
//         iconButton: Container(),
//       ),
//       body: StreamBuilder<NotificationSettings>(
//           stream: Get.find<UserController>()
//               .notificationSettings(Get.find<AuthController>().user!.uid)
//               .asStream(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData)
//               return Center(
//                 child: CircularProgressIndicator(),
//               );
//             var settings = snapshot.data!.notificationSettings;
//             return ListView(
//               children: [
//                 SwitchListTile.adaptive(
//                     activeColor: Color(Get.find<ThemeController>().globalColor),
//                     title: Text("Posts"),
//                     value: settings![NotificationType.Comment_On_Post]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.Comment_On_Post,
//                           val,
//                           snapshot.data!);
//                     }),
//                 SwitchListTile.adaptive(
//                     activeColor: Color(Get.find<ThemeController>().globalColor),
//                     title: Text("Replies"),
//                     value: settings[NotificationType.Replied_TO_Your_comment]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.Replied_TO_Your_comment,
//                           val,
//                           snapshot.data!);
//                     }),
//               ],
//             );
//           }),
//     );
//   }
// }
