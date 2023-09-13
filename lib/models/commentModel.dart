import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sano_gano/utils/database.dart';

class CommentModel {
  String? id;
  String? commenterId;
  String? commentorName;
  String? commentText;
  String? postId;
  int? replyCount;
  int? commentLikes;
  List<String>? likedBy;
  Map<String, dynamic>? taggedUsersIdandUsername;
  DateTime? timestamp;
  bool? isReply;
  String? posterId;
  List<String> get hashtags => getAllHashtagsFromPost;

  var _db = Database();
  DocumentReference? ref;
  DocumentReference get commentRef =>
      _db.postsCollection.doc(postId).collection('comments').doc(id);
  CollectionReference get repliesRef => _db.postsCollection
      .doc(postId)
      .collection('comments')
      .doc(id)
      .collection('replies');

  List<String> get getAllHashtagsFromPost {
    if (!commentText!.contains("#")) return [];
    var list = commentText;
    return list!
        .split(" ")
        .where((element) => element[0] == "#")
        .toSet()
        .toList();
  }

  CommentModel({
    this.commenterId,
    this.commentorName,
    this.commentText,
    this.replyCount = 0,
    this.commentLikes,
    this.likedBy,
    this.taggedUsersIdandUsername,
    this.timestamp,
    this.postId,
    this.isReply,
    this.posterId,
    this.id,
    this.ref,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'commenterId': commenterId,
      'commentorName': commentorName,
      'commentText': commentText,
      'replyCount': replyCount,
      'commentLikes': commentLikes,
      'likedBy': likedBy,
      'taggedUsersIdandUsername': taggedUsersIdandUsername,
      'timestamp': timestamp!.millisecondsSinceEpoch,
      'postId': postId,
      'isReply': isReply,
      'posterId': posterId,
    };
  }

  factory CommentModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>>? documentSnapshot,
      {QueryDocumentSnapshot<Map<String, dynamic>>? querydocumentSnapshot}) {
    Map<String, dynamic> map = {};

    map = documentSnapshot?.data() ?? {};
    if (documentSnapshot == null && querydocumentSnapshot != null)
      map = querydocumentSnapshot.data();
    return CommentModel(
      id: map['id'],
      commenterId: map['commenterId'],
      commentorName: map['commentorName'],
      commentText: map['commentText'],
      replyCount: map['replyCount'],
      commentLikes: map['commentLikes'],
      likedBy: map['likedBy']?.cast<String>() ?? [],
      taggedUsersIdandUsername: map['taggedUsersIdandUsername'] == null
          ? {}
          : Map<String, dynamic>.from(map['taggedUsersIdandUsername'] ?? {}),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      postId: map['postId'] ?? '',
      isReply: map['isReply'] ?? false,
      posterId: map['posterId'] ?? '',
      ref: querydocumentSnapshot != null
          ? querydocumentSnapshot.reference
          : documentSnapshot?.reference,
    );
  }

  String toJson() => json.encode(toMap());

  CommentModel copyWith({
    String? commenterId,
    String? commentorName,
    String? commentText,
    int? replyCount,
    int? commentLikes,
    List<String>? likedBy,
    Map<String, dynamic>? taggedUsersIdandUsername,
    DateTime? timestamp,
  }) {
    return CommentModel(
      commenterId: commenterId ?? this.commenterId,
      commentorName: commentorName ?? this.commentorName,
      commentText: commentText ?? this.commentText,
      replyCount: replyCount ?? this.replyCount,
      commentLikes: commentLikes ?? this.commentLikes,
      likedBy: likedBy ?? this.likedBy,
      taggedUsersIdandUsername:
          taggedUsersIdandUsername ?? this.taggedUsersIdandUsername,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'CommentModel(id: $id, commenterId: $commenterId, commentorName: $commentorName, commentText: $commentText, postId: $postId, replyCount: $replyCount, commentLikes: $commentLikes, likedBy: $likedBy,taggedUsersIdandUsername:$taggedUsersIdandUsername, timestamp: $timestamp, isReply: $isReply)';
  }
}
