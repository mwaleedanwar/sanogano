import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'package:sano_gano/models/messageModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/user_database.dart';
import 'package:sano_gano/utils/functions_service.dart';

class FollowDatabase {
  Stream<List<UserModel>> getFollowerUsersdata(var list) {
    try {
      if (list.isEmpty) {
        list = ['null'];
      }
      var ref = FirebaseFirestore.instance
          .collection("users")
          .where(FieldPath.documentId, whereIn: list ?? ["null"]);
      return ref.snapshots().map((list) =>
          list.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<UserModel>> getFollowingUsersdata(var list) {
    try {
      var ref = FirebaseFirestore.instance
          .collection("users")
          .where(FieldPath.documentId, whereIn: list ?? ["null"]);
      return ref.snapshots().map((list) =>
          list.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<String>> getFollowerList(String id) async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection("followers")
          .doc(id)
          .collection("u_followers")
          .get();
      //  print(ref.snapshots().length);

      return collection.docs.map((e) {
        return e.id;
      }).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<int> getFollowerCount(String id) async {
    var d = await getFollowerList(id);
    return d.length;
  }

  Stream<List<String>> getFollowerListStream(String id) {
    try {
      return FirebaseFirestore.instance
          .collection("followers")
          .doc(id)
          .collection("u_followers")
          .snapshots()
          .map((event) => event.docs.map((e) => e.id).toList());
      //  print(ref.snapshots().length);

      // return collection.docs.map((e) {
      //   return e.id;
      // }).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  var userDb = UserDatabase();

  Future<List<UserModel>> getFollowerModelList(String id) async {
    try {
      List<UserModel> users = [];
      var collection = await FirebaseFirestore.instance
          .collection("followers")
          .doc(id)
          .collection("u_followers")
          .get();
      //  print(ref.snapshots().length);

      var list = collection.docs.map((e) => e.id).toList();
      for (var item in list) {
        var result = await userDb.getUser(item);
        if (result != null) users.add(result);
      }
      return users;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Stream<List<String>?> getFollowingCountStream(String id) {
    try {
      return FirebaseFirestore.instance
          .collection("following")
          .doc(id)
          .collection("u_following")
          .snapshots()
          .map((event) => event.docs.map((e) => e.id).toList());
      //  print(ref.snapshots().length);

      // return collection.docs.map((e) {
      //   return e.id;
      // }).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<String>> getFollowingList(String id) async {
    try {
      var collection = await FirebaseFirestore.instance
          .collection("following")
          .doc(id)
          .collection("u_following")
          .get();
      //  print(ref.snapshots().length);

      return collection.docs.map((e) {
        return e.id;
      }).toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<UserModel>> getFollowingModelList(String id) async {
    try {
      var users = <UserModel>[];
      var collection = await FirebaseFirestore.instance
          .collection("following")
          .doc(id)
          .collection("u_following")
          .get();
      //  print(ref.snapshots().length);

      var list = collection.docs.map((e) => e.id).toList();
      for (var item in list) {
        var result = await userDb.getUser(item);
        if (result != null) users.add(result);
      }
      return users;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<FriendListResponse> getFriendList(String id) async {
    try {
      var list1 = await getFollowingList(id);
      var list2 = await getFollowerList(id);

      var finalList = list1.toSet().intersection(list2.toSet()).toList();

      return FriendListResponse(
        followers: list2,
        following: list1,
        friends: finalList,
      );
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  static Future<UserRelationship?> getUserRelationship(String uid) async {
    try {
      var result = (await FunctionsService.callFunction(
              'sanogano-fetchRelationship', {'uid': uid}))
          .data as Map<String, dynamic>;
      if (result.isEmpty) return null;
      return UserRelationship.fromMap(result);
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}

class FriendListResponse {
  final List<String> followers;
  final List<String> following;
  final List<String> friends;

  FriendListResponse(
      {required this.followers,
      required this.following,
      required this.friends});
}

class UserRelationship {
  bool areFriends;
  bool isFollowing;
  int otherUserFollowers;
  UserRelationship({
    required this.areFriends,
    required this.isFollowing,
    required this.otherUserFollowers,
  });

  Map<String, dynamic> toMap() {
    return {
      'areFriends': areFriends,
      'isFollowing': isFollowing,
      'otherUserFollowers': otherUserFollowers,
    };
  }

  factory UserRelationship.fromMap(Map<String, dynamic> map) {
    return UserRelationship(
      areFriends: map['areFriends'] ?? false,
      isFollowing: map['isFollowing'] ?? false,
      otherUserFollowers: map['otherUserFollowers']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserRelationship.fromJson(String source) =>
      UserRelationship.fromMap(json.decode(source));
}
