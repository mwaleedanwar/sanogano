import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/activity_controller.dart';
import 'package:sano_gano/controllers/follow_controller.dart';
import 'package:sano_gano/controllers/recent_search_controller.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/models/cacheManager.dart';
import 'package:sano_gano/models/notifications_settings.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/reportModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/global/constants.dart';
import 'package:sano_gano/view/pages/home/ad_controller.dart';
import 'package:sano_gano/view/pages/profile/editProfile/edit_theme.dart';
import 'package:sano_gano/view/widgets/user_menu_options.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as streamChat;
import 'package:stream_feed/stream_feed.dart' as sf;
import 'package:stream_feed/stream_feed.dart';
import '../services/notificationService.dart';
import 'auth_controller.dart';

class UserController extends GetxController {
  Rx<UserModel?> _userModel = UserModel().obs;
  UserModel get userModel => currentUser.value;
  String get currentUid => userModel.id!;
  var _loading = false.obs;
  bool get loading => _loading.value;
  Database fb = Database();
  var cacheManager = CacheManager();

  final feedClient = sf.StreamFeedClient(
    kDefaultStreamApiKey,
    logLevel: Level.OFF,
  );

  List<UserModel> userSearchCache = [];

  DocumentReference get currentUserReference {
    return FirebaseFirestore.instance.collection('/users').doc(auth.user!.uid);
  }

  set userModel(UserModel user) => this._userModel.value = user;
  Rx<UserModel> currentUser = Rx<UserModel>(UserModel());
  var auth = Get.find<AuthController>();
  @override
  void onInit() {
    clear();
    currentUser.bindStream(currentUserStream.map((event) {
      var _currentUser = UserModel.fromFirestore(event);
      update();

      return _currentUser;
    }));
    once<UserModel>(
      currentUser,
      (user) {
        initializeStreamChat();
        initializeFriendData();
        var sfc = Get.put(StreamFeedController());
      },
    );

    // debounce<UserModel?>(_userModel, (user) {
    //   log("Calling debounce");
    //   if (user!.id != null) initializeStreamChat();
    // }, time: 2.seconds);

    super.onInit();
  }

  String initializedUser = '';
  streamChat.StreamChatClient get chatClient =>
      streamChat.StreamChat.of(Get.context!).client;
  bool get chatInitialized => initializedUser == auth.user!.uid;
  var initializingChat = false;

  Future<void> initializeStreamChat() async {
    await chatClient.connectUser(
        streamChat.User(
          id: userModel.id!,
          name: userModel.name,
          image: userModel.profileURL,
        ),
        userModel.chatToken!);

    return;
  }

  List<String> friendList = [];
  var followingList = <String>[].obs;
  var followerList = <String>[].obs;
  var followerDatabase = FollowDatabase();
  var initComplete = false;
  Future<void> initializeFriendData() async {
    if (userModel.id == null) return;

    print("initialized friendship data");
    var res = await followerDatabase.getFriendList(userModel.id!);
    friendList = res.friends;
    followingList.value = res.following;
    followerList.value = res.followers;
    initComplete = true;
    log("initialization complete");
    return;
  }

  @override
  void onReady() async {
    // TODO: implement onReady
    //initChatConnection();
    if (auth.user != null) {
      db.usersCollection
          .orderBy('followers', descending: true)
          .limit(25)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          var user = UserModel.fromFirestore(element);
          if (user.id != userModel.id) {
            userSearchCache.add(user);
          }
        });
        update();
      });
    }

    Get.put(SearchController());
    Get.put(RecentSearchController());
    Get.put(ActivityController());
    2.seconds.delay().then((value) async {
      await NotificationService().init();
    });
    Get.put(AdController());
    super.onReady();
  }

  @override
  void onClose() {
    print("removing usercontroller");
    userModel = UserModel();
    _userModel.value = UserModel();

    super.onClose();
  }

  var db = Database();
  Stream<DocumentSnapshot> get currentUserStream {
    return db.usersCollection
        // .doc(Get.find<AuthController>().user.uid)
        .doc(auth.user!.uid)
        .snapshots();
  }

  void clear() {
    userModel = UserModel();
    _userModel.value = UserModel();
  }

  getCurrentUser(String id) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    _userModel.value = await UserDatabase().getUser(id);
  }

  void updateUserController(
      String name, String userName, String bio, String website) {
    _userModel.update((val) {
      val!.username = userName;
      val.name = name;
      val.bio = bio;
      val.website = website;
    });
    update();
  }

  Future<void> updateProfileImage(String profileURL) async {
    await currentUserReference.update({'profileURL': profileURL});
    return;
  }

  Future<void> blockUser(String uid) async {
    try {
      await fb
          .blockedUsersCollection(userModel.id!)
          .doc(uid)
          .set({'blocked': true, 'timestamp': DateTime.now()});
      // await currentUserReference.update({
      //   'blockedUsers': FieldValue.arrayUnion([uid])
      // });
      await FollowController().unFollowUser(uid, userModel.id!);
      await FollowController().unFollowUser(userModel.id!, uid);
    } on FirebaseException catch (e) {
      Get.snackbar("Error", e.message!, backgroundColor: Colors.white);
      return;
    }
  }

  Future<void> unblockUser(String uid) async {
    try {
      await fb.blockedUsersCollection(userModel.id!).doc(uid).delete();
      // await removeFriend(uid);
    } on FirebaseException catch (e) {
      Get.snackbar("Error", e.message!, backgroundColor: Colors.white);
      return;
    }
  }

  Future<bool> reportUser(String uid) async {
    await fb.reportsCollection.add(ReportModel(
      flaggedBy: userModel.id,
      reportID: fb.reportsCollection.doc().id,
      reportedFor:
          "Flagged Activity", //TODO add relevant report types for admin
      userID: uid,
    ).toMap());
    return true;
  }

  removeFollower(String uid) async {
    await FollowController().unFollowUser(uid, userModel.id!);
    await FollowController().removeFollower(uid, userModel.id!);
  }

  userMenuAction(UserMenuOptions userMenuOptions, UserModel user,
      {required Function postActionCallback}) async {
    switch (userMenuOptions) {
      case UserMenuOptions.Block:
        {
          await blockUser(user.id!);
        }
        break;
      case UserMenuOptions.Report:
        {}
        break;
      default:
        {}
    }
    postActionCallback();
    return;
  }

  Future<BlockResponse?> isUserBlocked(String uid) async {
    try {
      String blockedBy = '';
      var doc =
          await fb.blockedUsersCollection(this.userModel.id!).doc(uid).get();
      if (doc.exists) blockedBy = this.userModel.id!;
      var doc2 =
          await fb.blockedUsersCollection(uid).doc(this.userModel.id).get();
      if (doc2.exists) blockedBy = uid;
      return BlockResponse(
        isBlocked: doc.exists || doc2.exists,
        blockedBy: blockedBy,
      );
    } on Exception catch (e) {
      print(e);
      return null;
      // TODO
    }
  }

  Future<bool> areFriends(String uid, String followedUid) async {
    var res1 = await FollowController().isFollowed(uid, followedUid);
    var res2 = await FollowController().isFollowed(followedUid, uid);
    return res1 && res2;
  }

  Future<NotificationSettings> notificationSettings(String id) async {
    // print(id);
    var doc = await db.notificationSettings(id).get();
    // print(doc.data());
    var not = NotificationSettings.fromMap(doc.data() as Map<String, dynamic>);
    // print(not == null);
    print(not.toMap());
    return not;
  }

  Future<bool> subscribeToUserPosts(String userId) async {
    try {
      await db.usersCollection
          .doc(userId)
          .collection(USERS_SUBSCRIBERS_COLLECTION)
          .doc(userModel.id)
          .set({
        'subscribed': 'true',
        'timestamp': FieldValue.serverTimestamp()
      });
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  Future<bool> unsubscribeToUserPosts(String userId) async {
    try {
      await db.usersCollection
          .doc(userId)
          .collection(USERS_SUBSCRIBERS_COLLECTION)
          .doc(userModel.id)
          .delete();
      return true;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  Future<bool> isSubscribedToUserPosts(String userId) async {
    try {
      var doc = await db.usersCollection
          .doc(userId)
          .collection(USERS_SUBSCRIBERS_COLLECTION)
          .doc(userModel.id)
          .get();
      return doc.exists;
    } catch (e) {
      //  Get.snackbar("Error", e.toString());
      return false;
    }
  }

  Stream<bool> isSubscribedToUserPostsAsStream(String userId) {
    try {
      return db.usersCollection
          .doc(userId)
          .collection(USERS_SUBSCRIBERS_COLLECTION)
          .doc(userModel.id)
          .snapshots()
          .map((event) => event.exists);
    } catch (e) {
      //  Get.snackbar("Error", e.toString());
      return Stream.value(false);
    }
  }

  Future<bool> toggleSubscribeToUserPosts(String userId) async {
    try {
      if (await isSubscribedToUserPosts(userId)) {
        await unsubscribeToUserPosts(userId);
        return true;
      } else {
        await subscribeToUserPosts(userId);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return false;
    }
  }

  Future<int> messageRequestCount() async {
    try {
      return 0;
    } catch (e) {
      Get.snackbar("Error", e.toString());
      return 0;
    }
  }

  Map<String, int> postCommulativeCommentsCount = {};
  void addComment(String postId) {
    if (postCommulativeCommentsCount.containsKey(postId)) {
      postCommulativeCommentsCount[postId] =
          postCommulativeCommentsCount[postId]! + 1;
    } else {
      postCommulativeCommentsCount[postId] = 1;
    }
  }

  void removeComment(String postId) {
    if (postCommulativeCommentsCount.containsKey(postId)) {
      postCommulativeCommentsCount[postId] =
          postCommulativeCommentsCount[postId]! - 1;
    } else {
      postCommulativeCommentsCount[postId] = 0;
    }
  }

  void resetCount(String postId) {
    postCommulativeCommentsCount[postId] = 0;
  }
}

class BlockResponse {
  bool isBlocked;
  String blockedBy;
  BlockResponse({
    required this.isBlocked,
    required this.blockedBy,
  });
}
