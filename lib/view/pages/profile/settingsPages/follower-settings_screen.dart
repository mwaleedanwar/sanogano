// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:sano_gano/controllers/auth_controller.dart';
// import 'package:sano_gano/controllers/user_controller.dart';
// import 'package:sano_gano/models/notifications_settings.dart';
// import 'package:sano_gano/services/notificationService.dart';
// import 'package:sano_gano/view/global/custom_appbar.dart';
// import 'package:sano_gano/view/global/custom_icon.dart';

// import '../../../../controllers/theme_controller.dart';

// class FollowerSettingsScreen extends StatefulWidget {
//   @override
//   _FollowerSettingsScreenState createState() => _FollowerSettingsScreenState();
// }

// class _FollowerSettingsScreenState extends State<FollowerSettingsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CustomAppBar(
//         back: true,
//         title: "Followers",
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
//                     title: Text("New"),
//                     value: settings![NotificationType.STARTED_FOLLOWING_YOU]!,
//                     onChanged: (val) {
//                       NotificationService.updateNotificationSettings(
//                           NotificationType.STARTED_FOLLOWING_YOU,
//                           val,
//                           snapshot.data!);
//                     }),
//               ],
//             );
//           }),
//     );
//   }
// }
