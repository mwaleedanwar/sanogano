import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/followRequestModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/pages/chat/stream_chat_controller.dart';

class FollowController extends GetxController {
  var _firestore = FirebaseFirestore.instance;
  var currentUserUid = Get.find<AuthController>().user!.uid;
  var _followed = false.obs;
  bool get followed => _followed.value;
  var db = Database();

  var _followers = <UserModel>[].obs;
  List<UserModel> get followers => _followers;

  var _following = <UserModel>[].obs;
  List<UserModel>? get following => _following.value;

  Future<bool> checkFollowed(String myID, String userID) async {
    var followRef = _firestore.collection("followers").doc(userID);
    var docSnapshot = await followRef.collection("u_followers").doc(myID).get();
    if (docSnapshot.exists) {
      _followed.value = docSnapshot["follow"];
      return true;
    } else {
      _followed.value = false;
      return false;
    }
  }

  Future<String> toggleFollow(String followerID, String followedID,
      {bool? isFollowing}) async {
    if (followerID == followedID) return "";
    var sc = Get.find<StreamFeedController>();
    if (isFollowing ?? await isFollowed(followerID, followedID)) {
      await unFollowUser(followerID, followedID);
      await sc.unFollowSomeone(followedID);
      if (userController.followingList.contains(followedID)) {
        userController.followingList.remove(followedID);
      }
      return "Follow";
    } else {
      await followUser(followerID, followedID);
      await sc.followSomeone(followedID);
      if (!userController.followingList.contains(followedID)) {
        userController.followingList.add(followedID);
      }
      return "Unfollow";
    }
  }

  String initialStringValue(String followerID, String followedID) {
    var initiallyFriends = userController.friendList.contains(followedID);
    var initiallyFollowing = userController.followingList.contains(followedID);
    var initiallyFollowedByOther =
        userController.followerList.contains(followedID);

    if (initiallyFriends) return "Friends";
    if (initiallyFollowing) return "Unfollow";
    return "Follow";
  }

  Stream<String> buttonStatus(String followerID, String followedID,
      {bool initiallyFriends = false,
      bool initiallyFollowing = false,
      bool initiallyFollowedByOther = false}) async* {
    initiallyFriends = userController.friendList.contains(followedID);
    initiallyFollowing = userController.followingList.contains(followedID);
    initiallyFollowedByOther = userController.followerList.contains(followedID);
    if (await isFollowed(followerID, followedID)) {
      if (await isFollowed(followedID, followerID)) {
        yield "Friends";
      } else {
        yield "Unfollow";
      }
    } else {
      // if (await isRequestSent(followedID)) {
      //   yield "Requested";
      //   print("stream Requested");
      // } else {
      yield "Follow";
      // }
    }
  }

  Future<bool> checkIfBothUserFollowEachOther(
      String currentUid, String otherUserId) async {
    return (await isFollowed(currentUid, otherUserId)) &&
        (await isFollowed(otherUserId, currentUid)); //ty
  }

  Future<bool> isFollowed(String followerID, String followedID) async {
    log("followerId $followerID \n followedId $followedID");
    var followRef = _firestore.collection("followers").doc(followerID);
    var docSnapshot =
        await followRef.collection("u_followers").doc(followedID).get();
    return docSnapshot.exists;
  }

  Future<void> setFollow(String myID, String userID) async {
    bool followed = await checkFollowed(myID, userID);
    if (followed) {
      _firestore
          .collection("followers")
          .doc(userID)
          .collection("u_followers")
          .doc(myID)
          .delete();
      _firestore
          .collection("following")
          .doc(myID)
          .collection("u_following")
          .doc(userID)
          .delete();

      _firestore
          .collection("users")
          .doc(userID)
          .update({"followers": FieldValue.increment(-1)});
      _firestore
          .collection("users")
          .doc(myID)
          .update({"following": FieldValue.increment(-1)});
      _followed.value = false;
    } else {
      _firestore
          .collection("followers")
          .doc(userID)
          .collection("u_followers")
          .doc(myID)
          .set({"follow": true});
      _firestore
          .collection("following")
          .doc(myID)
          .collection("u_following")
          .doc(userID)
          .set({"follow": true});

      _firestore
          .collection("users")
          .doc(userID)
          .update({"followers": FieldValue.increment(1)});
      _firestore
          .collection("users")
          .doc(myID)
          .update({"following": FieldValue.increment(1)});
      //broadcastAsSuggestionToMyFriends(myID, userID);
      NotificationService().notifyAboutNewFollower(userID, _followed.value);
      _followed.value = true;
    }
  }

  Future<void> sendFollowRequest(String receiverId) async {
    var doc = db.followRequests(receiverId).doc(userController.currentUid);
    var request = FollowRequestModel(
      receiverId: receiverId,
      requestID: doc.id,
      requestStatus: RequestStatus.IGNORED,
      senderId: userController.currentUid,
    );
    await doc.set(request.toMap());
    await NotificationService().notifyOwnerAboutNewRequest(receiverId);
    return;
  }

  Future<bool> isRequestSent(String receiverId) async {
    var doc = await db
        .followRequests(receiverId)
        .doc(userController.currentUid)
        .get();
    return doc.exists;
  }

  Future<void> acceptFollowRequest(
      FollowRequestModel followRequestModel) async {
    await followRequestModel.reference!
        .update({'requestStatus': RequestStatus.ACCEPTED.index});
    await followUser(
        followRequestModel.receiverId!, followRequestModel.senderId!);
    return;
  }

  Future<void> rejectFollowRequest(
      FollowRequestModel followRequestModel) async {
    // await followRequestModel.reference
    //     .update({'requestStatus': RequestStatus.REJECTED.index});
    await followRequestModel.reference!.delete();
    return;
  }

  getFollowersUserStream(String id) async {
    var list = await FollowDatabase().getFollowerList(id);
    _followers.bindStream(FollowDatabase().getFollowerUsersdata(list));
  }

  getFollowingUserStream(String id) async {
    var list = await FollowDatabase().getFollowingList(id);
    _following.bindStream(FollowDatabase().getFollowingUsersdata(list));
  }

  @override
  void onClose() {
    _following.value = [];
    _followers.value = [];
    super.onClose();
  }

  Future<void> followUser(String followerID, String followedID) async {
    var batch = FirebaseFirestore.instance.batch();
    bool isFollowed =
        await FollowController().isFollowed(followerID, followedID);
    log("isFollowed $isFollowed");
    batch.set(
        _firestore
            .collection("followers")
            .doc(followedID)
            .collection("u_followers")
            .doc(followerID),
        {"follow": true});
    batch.set(
        _firestore
            .collection("following")
            .doc(followerID)
            .collection("u_following")
            .doc(followedID),
        {"follow": true});
    batch.update(_firestore.collection("users").doc(followedID),
        {"followers": FieldValue.increment(1)});
    batch.update(_firestore.collection("users").doc(followerID),
        {"following": FieldValue.increment(1)});

    await batch.commit();
    var sfc = Get.find<StreamFeedController>();

    await sfc.friendFeed?.follow(sfc.getSomeonesPersonalFeed(followedID));
    await NotificationService().notifyAboutNewFollower(followedID, isFollowed);

    return;
  }

  Future<void> removeFollower(String followedID, String followerID) async {
    var batch = FirebaseFirestore.instance.batch();

    batch.delete(_firestore
        .collection("followers")
        .doc(followedID)
        .collection("u_followers")
        .doc(followerID));
    batch.update(_firestore.collection("users").doc(followedID),
        {"followers": FieldValue.increment(-1)});

    await batch.commit();
    return;
  }

  Future<void> unFollowUser(String followerID, String followedID) async {
    var batch = FirebaseFirestore.instance.batch();
    batch.delete(_firestore
        .collection("followers")
        .doc(followedID)
        .collection("u_followers")
        .doc(followerID));
    batch.delete(_firestore
        .collection("following")
        .doc(followerID)
        .collection("u_following")
        .doc(followedID));
    batch.update(db.usersCollection.doc(followerID), {
      "following": FieldValue.increment(-1),
    });
    batch.update(db.usersCollection.doc(followedID), {
      "followers": FieldValue.increment(-1),
    });
    try {
      await batch.commit();

      var sfc = Get.find<StreamFeedController>();

      await sfc.friendFeed!.unfollow(sfc.getSomeonesPersonalFeed(followedID));
      log("now in friend list");

      return;
    } catch (e) {
      return;
    }
  }

  var userController = Get.find<UserController>();

  Future<void> broadcastAsSuggestionToMyFriends(
      String myID, String userID) async {
    try {
      var result = await userController.areFriends(myID, userID);
      if (result) {
        var batch = FirebaseFirestore.instance.batch();
        var friends = await FollowDatabase().getFriendList(myID);
        for (var friend in friends.friends) {
          batch.set(db.suggestionsCollection(friend).doc(userID),
              {"suggestion": true});
        }
        await batch.commit();
      }
      // await db.suggestionsCollection(myID).doc(userID).set({"suggested": true});
      return;
    } catch (e) {}
  }
}
