// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sano_gano/controllers/auth_controller.dart';
// import 'package:sano_gano/controllers/user_controller.dart';
// import 'package:sano_gano/models/notifications_settings.dart';
// import 'package:sano_gano/services/notificationService.dart';
// import 'package:sano_gano/view/global/custom_appbar.dart';
// import 'package:sano_gano/view/global/custom_icon.dart';

// import '../../../../controllers/theme_controller.dart';

// class TaggedSettingsScreen extends StatefulWidget {
//   @override
//   _TaggedSettingsScreenState createState() => _TaggedSettingsScreenState();
// }

// class _TaggedSettingsScreenState extends State<TaggedSettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         back: true,
//         title: "Tagged",
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
//                     value:
//                         settings![NotificationType.TAGGED_YOU_IN_THEIR_POST]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.TAGGED_YOU_IN_THEIR_POST,
//                           val,
//                           snapshot.data!);
//                     }),
//                 SwitchListTile.adaptive(
//                     activeColor: Color(Get.find<ThemeController>().globalColor),
//                     title: Text("Comments"),
//                     value:
//                         settings[NotificationType.TAGGED_YOU_IN_THEIR_COMMENT]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.TAGGED_YOU_IN_THEIR_COMMENT,
//                           val,
//                           snapshot.data!);
//                     }),
//                 SwitchListTile.adaptive(
//                     activeColor: Color(Get.find<ThemeController>().globalColor),
//                     title: Text("Replies"),
//                     value:
//                         settings[NotificationType.TAGGED_YOU_IN_THEIR_REPLY]!,
//                     onChanged: (val) async {
//                       await NotificationService.updateNotificationSettings(
//                           NotificationType.TAGGED_YOU_IN_THEIR_REPLY,
//                           val,
//                           snapshot.data!);
//                       setState(() {});
//                     }),
//               ],
//             );
//           }),
//     );
//   }
// }
