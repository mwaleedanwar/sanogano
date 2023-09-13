import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sano_gano/const/theme.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/bindings/auth_binding.dart';
import 'package:sano_gano/controllers/theme_controller.dart';
import 'package:sano_gano/firebase_options.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/ads_service.dart';
import 'package:sano_gano/utils/auth_wrapper.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/widgets/changing_theme.dart';
import 'package:sano_gano/view/widgets/user_header_tile.dart' as userHeader;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:stream_chat_localizations/stream_chat_localizations.dart';

import 'localizations.dart';

// bool isDM = false;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final data = message.data;
  bool isNewMessage = data['type'] == 'message.new';
  print(isNewMessage);
  if (!isNewMessage) {
    await showNotification(
      message,
    );
  } else {
    Get.put(AuthController());
    final chatClient = StreamChatClient(
      'g7auprpewf5u',
      logLevel: Level.SEVERE,
    );
    String? uid = auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }
    UserModel? userModel = await Database().getUser(uid);
    if (userModel == null) {
      return;
    }
    await chatClient.connectUser(
        User(
          id: userModel.id!,
          name: userModel.name,
          image: userModel.profileURL,
        ),
        userModel.chatToken!);
    String messageId = data['id'];
    GetMessageResponse? response = await chatClient.getMessage(messageId);

    await showNotification(null,
        messageBody: response.message.text,
        messageHeader: response.message.user?.name);
  }
}

Future<void> main() async {
  await GetStorage.init();
  WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await AdService.init();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  var appDirectory = await getApplicationDocumentsDirectory();
  Hive..init(appDirectory.path);
  Get.put(ThemeController());

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  FlutterNativeSplash.remove();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final client = StreamChatClient(
    'g7auprpewf5u',
    logLevel: Level.SEVERE,
  );

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(builder: (controller) {
      return controller.refreshApp.value
          ? ChangingTheme()
          : Portal(
              child: GetMaterialApp(
                builder: (context, child) => StreamChat(
                  client: client,
                  child: child,
                  streamChatThemeData: (controller.isDarkMode
                          ? StreamChatThemeData.dark()
                          : StreamChatThemeData.light())
                      .copyWith(
                    placeholderUserImage: (p0, p1) {
                      return userHeader.UserAvatar(
                        p1.id,
                        isdisabledTap: true,
                        autoFontSize: true,
                      );
                    },
                    defaultUserImage: (p0, user) => userHeader.UserAvatar(
                        user.id,
                        isdisabledTap: true,
                        autoFontSize: true),
                  ),
                ),
                title: "SanoGano",
                supportedLocales: const [
                  Locale('en'),
                  Locale('it'),
                ],
                localizationsDelegates: const [
                  AppLocalizationsDelegate(),
                  GlobalStreamChatLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                themeMode:
                    controller.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                initialBinding: AuthBinding(),
                debugShowCheckedModeBanner: false,
                darkTheme: AppThemes().darkTheme(),
                theme: AppThemes().finalLightTheme(),
                home: AuthWrapper(),
              ),
            );
    });
  }
}

Future<void> showNotification(
  RemoteMessage? message, {
  String? messageHeader,
  String? messageBody,
}) async {
  String header = messageHeader ?? message?.notification?.title ?? "SanoGano";
  String body =
      messageBody ?? message?.notification?.body ?? "New Notification";

  await FlutterLocalNotificationsPlugin().show(
    1,
    header,
    body,
    NotificationDetails(
        android: AndroidNotificationDetails(
            'basic_channel', 'Basic notifications',
            importance: Importance.high),
        iOS: DarwinNotificationDetails()),
  );
}

// junk code

// Future<void> _streamChatBackgroundHandler(Event event) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("handeling stream background message");
//   // check if notification already displayed
//   if (event.createdAt.isBefore(DateTime.now().subtract(Duration(seconds: 2)))) {
//     return;
//   }

//   await showNotification(null,
//       messageBody: event.message?.text, messageHeader: event.user?.name);
// }
