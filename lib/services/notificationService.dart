import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/models/notificationModel.dart';
import 'package:sano_gano/models/notifications_settings.dart' as settings;
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class NotificationService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  var db = Database();
  var userController = Get.find<UserController>();
  var currentUser = Get.find<UserController>().userModel;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<bool> initializeNotificationsPermissions() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      return true;
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      return true;
    } else {
      print('User declined or has not accepted permission');
      return false;
    }
  }

  // Future<void> backgroundMessageHandler(RemoteMessage message) async {
  //   log('onBackgroundMessage');
  //   await userController.chatClient.connectUser(
  //     User(id: currentUser.id ?? auth.FirebaseAuth.instance.currentUser!.uid),
  //     currentUser.chatToken!,
  //     connectWebSocket: false,
  //   );

  //   handleNotification(message, userController.chatClient, isBackground: true);
  // }
  // * method use to show notifications
  Future<void> showNotification(
    RemoteMessage message,
    StreamChatClient? chatClient,
  ) async {
    final data = message.data;
    bool isNewMessage = data['type'] == 'message.new';
    String? messageId;
    GetMessageResponse? response;
    if (isNewMessage) {
      messageId = data['id'];
      if (messageId != null) {
        response = await chatClient?.getMessage(messageId);
      }
    }

    await flutterLocalNotificationsPlugin.show(
      1,
      isNewMessage
          ? '${response?.message.user?.name}'
          : message.notification?.title ?? "SanoGano",
      isNewMessage
          ? response?.message.text
          : message.notification?.body ?? "New Notification",
      NotificationDetails(
          android: isNewMessage
              ? AndroidNotificationDetails(
                  'new_message', 'New message notifications channel',
                  importance: Importance.high)
              : AndroidNotificationDetails(
                  'basic_channel', 'Basic notifications',
                  importance: Importance.high),
          iOS: DarwinNotificationDetails()),
    );
  }

  Future<void> init() async {
    try {
      // * initialization
      await initializeNotificationsPermissions();
      await initializeNotification();
      await db
          .notificationSettings(Get.find<AuthController>().user!.uid)
          .get()
          .then((value) {
        if (!value.exists) {
          var notificationsSettings = settings.NotificationSettings();
          value.reference.set(notificationsSettings.toMap());
        }
      });
      String? messagingToken = await getMessagingToken();
      if (messagingToken != null) {
        log("Handelling notification Activity");
        await userController.currentUserReference
            .update({'androidNotificationToken': messagingToken});
        RemoteMessage? initialMessage = await messaging.getInitialMessage();
        messaging.onTokenRefresh.listen((token) async {
          if (Platform.isIOS)
            await userController.chatClient
                .addDevice(messagingToken, PushProvider.apn);

          if (Platform.isAndroid)
            await userController.chatClient
                .addDevice(messagingToken, PushProvider.firebase);
        });
        // * handelling activity
        if (initialMessage?.data != null) {
          _handleMessage(initialMessage!);
        }
        if (Platform.isIOS)
          await userController.chatClient
              .addDevice(messagingToken, PushProvider.apn);

        if (Platform.isAndroid)
          await userController.chatClient
              .addDevice(messagingToken, PushProvider.firebase);
        // Also handle any interaction when the app is in the background via a
        // Stream listener
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print("tapped");
          showNotification(message, userController.chatClient);
          // _handleMessage(message);
          // Get.snackbar("tapped", message.data.toString());
          // if (message.data['type'] == 'message.new') {
          //   //TODO add logic here to navigate to chat screen
          // }
          // if (message.data['type'] == 'chat') {
          //   /// ADD conditional navigation
          // }
        });
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
          // await showFlutterNotification(message);
          showNotification(
            message,
            userController.chatClient,
          );
        });

        print("Notifications initialized");
        // FirebaseMessaging.onBackgroundMessage(
        //     (message) => backgroundMessageHandler(message));
      }
    } catch (e) {
      print("Error initializing notifications");
      print(e.toString());
    }
  }

  void _handleMessage(RemoteMessage message) {
    print("notification tapped");
  }

  Future<String?> getMessagingToken() async {
    print("generating token ");
    String? messagingToken = await messaging.getToken();
    log('messagingToken: $messagingToken');
    return messagingToken;
  }

  Future<void> initializeNotification() async {
    try {
      AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('app_icon');
      DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings();
      InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS);
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } catch (e) {
      print(e.toString());
    }
  }

  // sendNotificationForNewChat(
  //     String conversationId, String sendername, String userId) {}

  // sendNotificationForNewParticipantInInvitation(
  //     String newParticipantID, String activityId) {}

  subscribeToAnActivity(String activityId) async {
    messaging.subscribeToTopic('activity$activityId');
  }

  subscribeToAnActivityConversation(String conversationId) async {
    messaging.subscribeToTopic('conversation$conversationId');
  }

  unsubscribeFromAnActivityConversation(String conversationId) async {
    messaging.subscribeToTopic('conversation$conversationId');
  }

  unsubscribeFromAnActivity(String activityId) async {
    messaging.subscribeToTopic('activity$activityId');
  }

  Future<bool> sendNotificationToList(
      List<String> listOfUids, NotificationModel notification) async {
    var allTokens = <String>[];
    await Future.wait(List.generate(
        listOfUids.length,
        (index) => firestore
                .collection('/users')
                .doc(listOfUids[index])
                .get()
                .then((value) {
              if (value.exists)
                allTokens.add(value.data()!['androidNotificationToken']);
            })));
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('sanogano-sendNotificationToList');
      final results = await callable.call(<String, dynamic>{
        'uid': allTokens,
        'alertID': '0',
        'alertMessage': notification.notificationBody,
        'alertHeading': notification.notificationHeader,
      });
      for (var element in listOfUids) {
        print("notification sent to $element");
      }
      print("notification sent to a list of ${listOfUids.length}");
      return results.data;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> sendNotificationToIndividual(
      String uid, NotificationModel notificationModel) async {
    print("Sending $notificationModel to $uid");
    try {
      HttpsCallable callable = FirebaseFunctions.instance
          .httpsCallable('sanogano-sendNotificationToIndividual');
      final results = await callable.call(<String, dynamic>{
        'uid': uid,
        'alertID': uid,
        'alertMessage': notificationModel.notificationBody,
        'alertHeading': notificationModel.notificationHeader,
      });
      return results.data;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> sendNotificationForTopic(
      String topic, NotificationModel notificationModel) async {
    try {
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('sendNotificationForTopic');
      final results = await callable.call(<String, dynamic>{
        'uid': '',
        'alertID': Uuid().v4(),
        'alertMessage': notificationModel.notificationBody,
        'alertHeading': notificationModel.notificationHeader,
        'topic': topic,
      });
      return results.data;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> notificationTest() async {
    showLoading();
    await addedANewPostNotification();
    await addedAsAFriendNotification(userController.currentUid);
    await notifyOwnerAboutNewRequest(userController.currentUid);
    // await notifyAboutNewFollower(userController.currentUid);
    await notifyAcceptedFollowRequest(userController.currentUid);
    await notifyAboutBeingTagged(userController.currentUid, "testpost");
    await notifyNewComment(
        "testpost",
        CommentModel(
            id: "testcomment", commenterId: userController.currentUid));

    await likedYourPost(
        PostModel(postId: "testpost", ownerId: userController.currentUid));
    hideLoading();

    return;
  }

  // added you as a friend
  Future<bool> addedANewPostNotification() async {
    try {
      // var doc = db.appActivityHistory(receiverId).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " has a new post!",
        notificationId: DateTime.now().millisecondsSinceEpoch.toString(),
        receiverUids: [],
        senderName: currentUser.name,
        notificationType: NotificationType.Added_new_post,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
      );
      var receiverDocs = await db.subscribers(currentUser.id!).get();
      var listOfUids = receiverDocs.docs.map((e) => e.id).toList();
      // await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, 'none')) {
        await sendNotificationToList(listOfUids, notification);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // added you as a friend
  Future<bool> addedAsAFriendNotification(String receiverId) async {
    try {
      var doc = db.appActivityHistory(receiverId).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " added you as a friend",
        notificationId: doc.id,
        receiverUids: [receiverId],
        senderName: currentUser.name,
        notificationType: NotificationType.ADDED_YOU_AS_FRIEND,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverId)) {
        print("sending notification to $receiverId");
        await sendNotificationToIndividual(receiverId, notification);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // new message from individual
  // new message in group chat

  Future<bool> sendNotificationForNewMessage(List<String> receiverUIDs,
      String? sendername, String message, String senderUID, String chatId,
      {String? groupActivityName}) async {
    print("sending notification to $receiverUIDs");

    var result = await sendNotificationToList(
        receiverUIDs,
        NotificationModel(
          notificationBody: "$message",
          notificationType: NotificationType.Chat_message,
          notificationHeader: sendername ??
              currentUser.name! +
                  "${groupActivityName != null ? '@$groupActivityName' : ''}",
          notificationId: DateTime.now()
              .millisecondsSinceEpoch
              .toString(), //TODO change ID logic if needed
          receiverUids: receiverUIDs,
          senderName: sendername,
          senderUid: senderUID,
          timestamp: DateTime.now(),
        ));
    print(" response is $result");
    return result;
  }

  // someone has requested to follow you
  Future<bool> notifyOwnerAboutNewRequest(String receiverUid) async {
    try {
      var doc = db.appActivityHistory(receiverUid).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " requested to follow you.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.REQUEST_TO_FOLLOW,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  // someone has followed you
  Future<bool> notifyAboutNewFollower(
      String receiverUid, bool isFollowed) async {
    try {
      String msg = currentUser.username! + " followed you.";
      // bool isFollowed =
      //     await FollowController().isFollowed(currentUser.id!, receiverUid);
      if (isFollowed) {
        log("followed: " + isFollowed.toString());
        msg = currentUser.username! + " followed you back.";
      }
      log(msg);
      //TODO made the notification id as sender id
      var doc = db.appActivityHistory(receiverUid).doc(currentUser.id);
      var notification = NotificationModel(
        notificationHeader: currentUser.name,
        notificationBody: msg,
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: isFollowed
            ? NotificationType.FOLLOWED_YOU_BACK
            : NotificationType.STARTED_FOLLOWING_YOU,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
      );

      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  // your request to follow has been accepted,
  Future<bool> notifyAcceptedFollowRequest(String receiverUid) async {
    try {
      var doc = db.appActivityHistory(receiverUid).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody:
            currentUser.username! + " accepted your follow request.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.FOLLOW_REQUEST_ACCEPTED,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> notifyAboutBeingTagged(
      String receiverUid, String? postId) async {
    try {
      print(receiverUid);
      var doc = db.appActivityHistory(receiverUid).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " tagged you in their post.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.TAGGED_YOU_IN_THEIR_POST,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
        postId: postId ?? '',
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> notifyAboutBeingTaggedInComment(
      String receiverUid, String commentId, String postId,
      {bool isReply = false}) async {
    try {
      var doc = db.appActivityHistory(receiverUid).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! +
            " tagged you in their ${isReply ? 'reply' : 'comment'}.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.TAGGED_YOU_IN_THEIR_COMMENT,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
        postId: postId,
        originalCommentId: commentId,
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  NotificationModel? tagNotification(String receiverUid, String? postId) {
    try {
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " tagged you in their post.",
        notificationId: Uuid().v4(),
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.TAGGED_YOU_IN_THEIR_POST,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
        postId: postId ?? '',
      );

      return notification;
    } catch (e) {
      return null;
    }
  }

  Future<bool> notifyNewComment(String postId, CommentModel comment) async {
    try {
      var post = await PostController().getPost(postId);

      var receiverUid = post!.ownerId;
      if (comment.commenterId == receiverUid) return true;
      var doc = db.appActivityHistory(receiverUid!).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " commented on your post.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.Comment_On_Post,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
        postId: comment.postId ?? '',
      );
      await doc.set(notification.toMap());
      log("notification sent to activity history of $receiverUid");
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> notifyNewReply(
      String postId, CommentModel originalComment, CommentModel reply) async {
    try {
      var post = await PostController().getPost(postId);
      var receiverUid = originalComment.commenterId;

      if (reply.commenterId == receiverUid) return true;
      var doc = db.appActivityHistory(receiverUid!).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " replied to your comment.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.Comment_On_Post,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
        postId: postId,
        originalCommentId: originalComment.id,
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> likedYourPost(PostModel post) async {
    try {
      String receiverUid = post.ownerId!;
      if (receiverUid == currentUser.id) return true;

      var doc = db.appActivityHistory(receiverUid).doc();
      var notification = NotificationModel(
        notificationHeader: "SanoGano",
        notificationBody: currentUser.username! + " liked your post.",
        notificationId: doc.id,
        receiverUids: [receiverUid],
        senderName: currentUser.name,
        notificationType: NotificationType.NEW_Like,
        senderUid: currentUser.id,
        timestamp: DateTime.now(),
        postId: post.postId,
      );
      await doc.set(notification.toMap());
      if (await getSetting(notification.notificationType!, receiverUid))
        await sendNotificationToIndividual(receiverUid, notification);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> updateNotificationSettings(
    List<NotificationType> notificationTypes,
    bool value,
    settings.NotificationSettings notificationSettings,
  ) async {
    var uid = Get.find<AuthController>().user!.uid;
    WriteBatch batch = FirebaseFirestore.instance.batch();
    for (var element in notificationTypes) {
      notificationSettings.notificationSettings![element] = value;
      batch.set(Database().notificationSettings(uid),
          {element.toString(): value}, SetOptions(merge: true));
    }
    await batch.commit();
    return;
  }

  Future<bool> getSetting(
      NotificationType notificationType, String receiverId) async {
    try {
      if (notificationType == NotificationType.Added_new_post) return true;
      var doc = await db.notificationSettings(receiverId).get();
      var nSet = settings.NotificationSettings.fromMap(
          doc.data() as Map<String, dynamic>);
      // print(notificationType);
      // print(nSet.notificationSettings![notificationType]!);
      return nSet.notificationSettings![notificationType]!;
    } catch (e) {
      return false;
    }
  }
}

enum NotificationType {
  GENERIC,
  ADDED_YOU_AS_FRIEND,
  FOLLOW_REQUEST_ACCEPTED,
  Comment_On_Post,
  NEW_Like,
  REQUEST_TO_FOLLOW,
  STARTED_FOLLOWING_YOU,
  FOLLOWED_YOU_BACK,
  TAGGED_YOU_IN_THEIR_POST,
  TAGGED_YOU_IN_THEIR_COMMENT,
  TAGGED_YOU_IN_THEIR_REPLY,
  Pinned_your_comment,
  Chat_message,
  Replied_TO_Your_comment,
  Liked_your_post,
  Like_your_comment,
  Liked_your_reply,
  Added_new_post,
}
