import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sano_gano/models/notifications_settings.dart';
import 'package:sano_gano/utils/database.dart';

class UserModel {
  String? id;
  String? name;
  String? username;
  DateTime? established;
  String? bio;
  String? email;
  String? profileURL;
  String? website;
  int? followers;
  int? following;
  bool? isPrivate;
  String? bannerURL;
  String? chatToken;
  String? feedToken;
  bool feedInitializationComplete;

  List<String>? likedPosts;
  List<String>? savedPosts;
  List<String>? blockedUsers;

  /// UIDS of people who follow this user
  List<String>? followedBy;

  /// the people this user follows
  List<String>? follows;
  var _db = Database();
  Future<NotificationSettings?> get notificationSettings async {
    var doc = await _db.notificationSettings(this.id!).get();
    if (doc.exists)
      return NotificationSettings.fromMap(doc.data() as Map<String, dynamic>);
    return null;
  }

  UserModel({
    this.id,
    this.name,
    this.username,
    this.established,
    this.bio,
    this.email,
    this.profileURL,
    this.website,
    this.followers,
    this.following,
    this.blockedUsers,
    this.followedBy,
    this.follows,
    this.likedPosts,
    this.savedPosts,
    this.isPrivate,
    this.bannerURL,
    this.chatToken,
    this.feedToken,
    this.feedInitializationComplete = false,
  });

  bool get isNull => this.id == null || id!.isEmpty;
  Map<String, dynamic> toMap() {
    return {
      'objectId': id,
      'id': id,
      "name": this.name,
      "username": this.username,
      'plainUsername': this.username?.toLowerCase() ?? '',
      "bio": this.bio,
      "email": this.email,
      "established":
          this.established == null ? null : this.established.toString(),
      "followers": this.followers,
      "following": this.following,
      "website": this.website,
      "profileURL": this.profileURL,
      'likedPosts': likedPosts,
      'savedPosts': savedPosts,
      'blockedUsers': blockedUsers,
      'followedBy': followedBy,
      'follows': follows,
      'isPrivate': isPrivate,
      'bannerURL': bannerURL,
      'feedInitializationComplete': feedInitializationComplete,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map["name"],
      username: map["username"],
      bio: map["bio"],
      email: map["email"],
      established: map["established"] == null
          ? DateTime.now()
          : map["established"].runtimeType == Timestamp
              ? DateTime.fromMillisecondsSinceEpoch(
                  map["established"].millisecondsSinceEpoch)
              : DateTime.now(),
      followers: map["followers"],
      following: map["following"],
      website: map["website"],
      profileURL: map["profileURL"],
      blockedUsers: map['blockedUsers']?.cast<String>() ?? [],
      followedBy: map['followedBy']?.cast<String>() ?? [],
      follows: map['follows']?.cast<String>() ?? [],
      likedPosts: map['likedPosts']?.cast<String>() ?? [],
      savedPosts: map['savedPosts']?.cast<String>() ?? [],
      isPrivate: map['isPrivate'] ?? false,
      bannerURL: map['bannerURL'] ?? '',
      chatToken: map['chatToken'] ?? "",
      feedToken: map['feedToken'],
      feedInitializationComplete: map['feedInitializationComplete'] ?? false,
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map<String, dynamic>;
    // if (data == null) return null;
    return UserModel(
      id: snapshot.id,
      name: data["name"],
      username: data["username"],
      bio: data["bio"],
      email: data["email"],
      established: data["established"] == null
          ? DateTime.now()
          : DateTime.fromMillisecondsSinceEpoch(
              data["established"].millisecondsSinceEpoch),
      followers: data["followers"] ?? 0,
      following: data["following"] ?? 0,
      website: data["website"] ?? '',
      profileURL: data["profileURL"] ?? '',
      blockedUsers: data['blockedUsers']?.cast<String>() ?? [],
      followedBy: data['followedBy']?.cast<String>() ?? [],
      follows: data['follows']?.cast<String>() ?? [],
      likedPosts: data['likedPosts']?.cast<String>() ?? [],
      savedPosts: data['savedPosts']?.cast<String>() ?? [],
      isPrivate: data['isPrivate'] ?? false,
      bannerURL: data['bannerURL'] ?? '',
      chatToken: data['chatToken'] ?? "",
      feedToken: data['feedToken'],
      feedInitializationComplete: data['feedInitializationComplete'] ?? false,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    Map data = map;

    // if (data == null) return null;
    return UserModel(
      id: map['id'],
      name: data["name"],
      username: data["username"],
      bio: data["bio"],
      email: data["email"],
      established: data["established"] == null
          ? DateTime.now()
          : data["established"].runtimeType == Timestamp
              ? DateTime.fromMillisecondsSinceEpoch(
                  data["established"].millisecondsSinceEpoch)
              : DateTime.now(),
      followers: data["followers"],
      following: data["following"],
      website: data["website"],
      profileURL: data["profileURL"],
      blockedUsers: data['blockedUsers']?.cast<String>() ?? [],
      followedBy: data['followedBy']?.cast<String>() ?? [],
      follows: data['follows']?.cast<String>() ?? [],
      likedPosts: data['likedPosts']?.cast<String>() ?? [],
      savedPosts: data['savedPosts']?.cast<String>() ?? [],
      isPrivate: data['isPrivate'] ?? false,
      bannerURL: data['bannerURL'] ?? '',
      chatToken: data['chatToken'] ?? "",
    );
  }

  @override
  String toString() {
    return "$username ($name)";
  }
}
