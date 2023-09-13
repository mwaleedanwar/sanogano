// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sano_gano/controllers/auth_controller.dart';
// import 'package:sano_gano/controllers/user_controller.dart';
// import 'package:sano_gano/models/notifications_settings.dart';
// import 'package:sano_gano/services/notificationService.dart';
// import 'package:sano_gano/view/global/custom_appbar.dart';
// import 'package:sano_gano/view/global/custom_icon.dart';

// import '../../../../controllers/theme_controller.dart';

// class LikedSettingsScreen extends StatefulWidget {
//   @override
//   _LikedSettingsScreenState createState() => _LikedSettingsScreenState();
// }

// class _LikedSettingsScreenState extends State<LikedSettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         back: true,
//         title: "Likes",
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
//                     value: settings![NotificationType.Liked_your_post]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.Liked_your_post,
//                           val,
//                           snapshot.data!);
//                     }),
//                 SwitchListTile.adaptive(
//                     activeColor: Color(Get.find<ThemeController>().globalColor),
//                     title: Text("Comments"),
//                     value: settings[NotificationType.Like_your_comment]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.Like_your_comment,
//                           val,
//                           snapshot.data!);
//                     }),
//                 SwitchListTile.adaptive(
//                     activeColor: Color(Get.find<ThemeController>().globalColor),
//                     title: Text("Replies"),
//                     value: settings[NotificationType.Liked_your_reply]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.Liked_your_reply,
//                           val,
//                           snapshot.data!);
//                     }),
//               ],
//             );
//           }),
//     );
//   }
// }
