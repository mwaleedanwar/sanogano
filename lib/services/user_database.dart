import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';

import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/algolia_search.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/view/global/constants.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as StreamChat;

import '../utils/functions_service.dart';

class UserDatabase {
  Future<bool> createUser(UserModel user) async {
    try {
      showLoading(loadingText: "Finishing up..");
      await FirebaseFirestore.instance.collection("users").doc(user.id).update(
            user.toMap(),
          );
      // var result = await FunctionsService.callFunction(
      //     'sanogano-createUserToken', {'uid': user.id});

      // await StreamChat.StreamChat.of(Get.context!).client.connectUser(
      //     StreamChat.User(
      //       id: user.id!,
      //       name: user.name,
      //       image: user.profileURL,
      //     ),
      //     result.data as String,
      //     connectWebSocket: false);
      // Get.find<UserController>().userModel.feedToken = result.data as String;
      // Get.find<UserController>().userModel.chatToken = result.data as String;
      hideLoading();
      return true;
    } on FirebaseException catch (e) {
      hideLoading();
      print(e);
      Get.snackbar("error", e.message!);
      return false;
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      if (Get.find<AuthController>().user == null) return UserModel();
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("users").doc(id).get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print(e);
      //Get.snackbar("error", e.toString());
      rethrow;
    }
  }

  Future<UserModel?> getUserNullable(String id) async {
    try {
      if (Get.find<AuthController>().user == null) return UserModel();
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("users").doc(id).get();
      return UserModel.fromFirestore(doc);
    } catch (e) {
      print(e);
      //Get.snackbar("error", e.toString());
      return null;
    }
  }

  Future<UserMutualResponse> getUserWithFriends(String id) async {
    try {
      DocumentSnapshot doc =
          await FirebaseFirestore.instance.collection("users").doc(id).get();
      var user = UserModel.fromFirestore(doc);
      var mutuals =
          await FunctionsService.callFunction('sanogano-getMutualFriends', {
        'uid': user.id,
      });
      return UserMutualResponse(
        friends: mutuals as List<String>,
        user: user,
      );
    } catch (e) {
      print(e);
      //Get.snackbar("error", e.toString());
      rethrow;
    }
  }

  Future<int> getMutualFriendsCount(String otherUserUid) async {
    try {
      var myFriends = await FollowDatabase()
          .getFriendList(Get.find<AuthController>().user!.uid);
      var otherFriends = await FollowDatabase().getFriendList(otherUserUid);
      return myFriends.friends
          .toSet()
          .intersection(otherFriends.friends.toSet())
          .length;
    } catch (e) {
      print(e);
      //Get.snackbar("error", e.toString());
      rethrow;
    }
  }

  Future<String?> getUserIDFromUsername(String username) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .where('username', isEqualTo: username)
          .get();
      return doc.docs.first.id;
    } catch (e) {
      print(e);
      // Get.snackbar("error", e.toString());
      return null;
    }
  }

  Future<String?> getUserIDFromUsernameWithNoCaseSensitivity(
      String username) async {
    try {
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .where('plainUsername', isEqualTo: username.toLowerCase())
          .get();

      return doc.docs.first.id;
    } catch (e) {
      print(e);
      // Get.snackbar("error", e.toString());
      return null;
    }
  }

  Stream<List<UserModel>> getLeaderBoardUsers() {
    try {
      var ref = FirebaseFirestore.instance
          .collection("users")
          .orderBy("followers", descending: true);
      return ref.snapshots().map((list) =>
          list.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
    } catch (e) {
      print(e);
      // Get.snackbar("error", e);
      rethrow;
    }
  }
}

class UserMutualResponse {
  UserModel user;
  List<String> friends;
  int? mutualFriendCount;
  UserMutualResponse(
      {required this.user, required this.friends, this.mutualFriendCount});
}
