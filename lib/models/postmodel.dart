import 'dart:convert';

import 'package:giphy_get/giphy_get.dart';
import 'package:intl/intl.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils/globalHelperMethods.dart';
import 'package:stream_feed/stream_feed.dart';

class PostModel {
  String activityId;
  String postId;
  String? ownerId;
  String? thumbnailUrl;
  String? postCaption;
  String? postLocation;
  String? attachedRecipeId;
  String? attachedWorkoutId;
  String? postAttachmentUrl;
  DateTime? timestamp;
  bool? videoMode;
  bool get hasMedia => !isNullOrBlank(postAttachmentUrl!);
  bool get hasVideo => videoMode! && !isNullOrBlank(postAttachmentUrl!);
  bool get isTextPost => isNullOrBlank(postAttachmentUrl!) && !hasGif;
  bool get hasText => !isNullOrBlank(postCaption!);
  bool get hasGif => gifUrl.isNotEmpty;
  int? likeCount;
  int? commentCount;
  int? totalCommentCount;
  List<String>? followedBy;
  List<String>? likedBy;
  List<String>? savedBy;
  List<String?>? taggedUsers;
  List<UserModel>? taggedUserModels;
  List<String> get hashtags => getAllHashtagsFromPost;
  GiphyGif? gif;
  String gifUrl;
  int popularity;
  double? videoAspectRatio;
  int? reports;
  String? pinnedCommentID;
  PostModel(
      {required this.postId,
      this.activityId = '',
      this.ownerId,
      this.postCaption = '',
      this.postLocation,
      this.attachedRecipeId = '',
      this.attachedWorkoutId = '',
      this.postAttachmentUrl = '',
      this.likeCount,
      this.commentCount,
      this.followedBy,
      this.likedBy,
      this.savedBy,
      this.taggedUsers,
      this.taggedUserModels = const [],
      this.timestamp,
      this.videoMode,
      this.pinnedCommentID,
      this.thumbnailUrl,
      this.gif,
      this.gifUrl = "",
      this.popularity = 0,
      this.videoAspectRatio,
      this.totalCommentCount,
      this.reports});

  Map<String, dynamic> toMap() {
    var map = {
      'actor': "SU:$ownerId",
      'verb': 'post',
      'object': 'post:$postId',
      'day': DateFormat.MMMd().format(DateTime.now()),
      'hasMedia': hasMedia || gif != null,
      'thumbnailUrl': thumbnailUrl,
      'videoMode': videoMode,
      'postId': postId,
      'ownerId': ownerId,
      'postCaption': postCaption,
      'postLocation': postLocation,
      'attachedRecipeId': attachedRecipeId,
      'attachedWorkoutId': attachedWorkoutId,
      'postAttachmentUrl': postAttachmentUrl,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'followedBy': followedBy,
      'likedBy': likedBy,
      'savedBy': savedBy,
      'taggedUsers': taggedUsers,
      'hashtags': getAllHashtagsFromPost,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'pinnedCommentID': pinnedCommentID,
      'gif': gif == null ? null : gif!.toJson(),
      'gifUrl': gif?.images?.previewWebp?.url,
      'popularity': popularity,
      'videoAspectRatio': videoAspectRatio,
      'to': ['grand:US'],
      'taggedUserModels': List.generate(taggedUserModels!.length,
          (index) => taggedUserModels![index].toMap()),
      'reports': reports
    };
    return map;
  }

  factory PostModel.fromActivity(
      {Activity? activity,
      GenericEnrichedActivity? activityEnriched,
      bool withReactions = false}) {
    assert(activity != null || activityEnriched != null);

    if (activity != null) {
      var post = PostModel.fromMap(activity.extraData as Map<String, Object?>);
      post.activityId = activity.id ?? "";
      return post;
    }
    if (activityEnriched != null) {
      var post =
          PostModel.fromMap(activityEnriched.extraData as Map<String, Object?>);
      post.activityId = activityEnriched.id ?? "";
      if (withReactions &&
          activityEnriched.reactionCounts != null &&
          activityEnriched.reactionCounts!.containsKey('like'))
        post.likeCount = activityEnriched.reactionCounts!['like'];
      return post;
    }
    return PostModel(postId: "");
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
        thumbnailUrl: map['thumbnailUrl'] ?? "",
        videoMode: map['videoMode'] ?? false,
        postId: map['postId'],
        ownerId: map['ownerId'],
        postCaption: map['postCaption'],
        postLocation: map['postLocation'],
        attachedRecipeId: map['attachedRecipeId'],
        attachedWorkoutId: map['attachedWorkoutId'],
        postAttachmentUrl: map['postAttachmentUrl'],
        likeCount: map['likeCount'],
        commentCount: map['commentCount'],
        totalCommentCount: map['commulativeCommentCount'] ?? 0,
        followedBy: map['followedBy']?.cast<String>() ?? [],
        likedBy: map['likedBy']?.cast<String>() ?? [],
        savedBy: map['savedBy']?.cast<String>() ?? [],
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
        taggedUsers: map['taggedUsers']?.cast<String>() ?? [],
        pinnedCommentID: map['pinnedCommentID'] ?? '',
        gif: map['gif'] != null ? GiphyGif.fromJson(map['gif']) : null,
        gifUrl: map['gifUrl'] ?? "",
        popularity: map['popularity'] ?? 0,
        videoAspectRatio:
            double.tryParse((map['videoAspectRatio'] ?? 1.0).toString()),
        taggedUserModels: map['taggedUserModels'] == null
            ? []
            : (map['taggedUserModels'] as List)
                .map((e) => UserModel.fromJson(e))
                .toList(),
        reports: map['reports'] ?? 0);
  }

  String toJson() => json.encode(toMap());

  factory PostModel.fromJson(String source) =>
      PostModel.fromMap(json.decode(source));

  PostModel copyWith({
    String? postId,
    String? ownerId,
    String? postCaption,
    String? postLocation,
    String? attachedRecipeId,
    String? attachedWorkoutId,
    String? postAttachmentUrl,
    int? likeCount,
    int? commentCount,
    List<String>? followedBy,
    List<String>? likedBy,
    List<String>? savedBy,
    List<String>? taggedUsers,
    DateTime? timestamp,
    int? reports,
  }) {
    return PostModel(
        timestamp: timestamp ?? this.timestamp,
        postId: postId ?? this.postId,
        ownerId: ownerId ?? this.ownerId,
        postCaption: postCaption ?? this.postCaption,
        postLocation: postLocation ?? this.postLocation,
        attachedRecipeId: attachedRecipeId ?? this.attachedRecipeId,
        attachedWorkoutId: attachedWorkoutId ?? this.attachedWorkoutId,
        postAttachmentUrl: postAttachmentUrl ?? this.postAttachmentUrl,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        followedBy: followedBy ?? this.followedBy,
        likedBy: likedBy ?? this.likedBy,
        savedBy: savedBy ?? this.savedBy,
        taggedUsers: taggedUsers ?? this.taggedUsers,
        reports: reports ?? this.reports);
  }

  PostModel? updateWith(PostModel newModel) {}

  List<String> get getAllHashtagsFromPost {
    if (!postCaption!.contains("#")) {
      print("no hashtags");
      return [];
    }
    var list = postCaption;

    List<String> hashtags = list!
        .replaceAll("\n", " ")
        .split(" ")
        .where((element) => element.startsWith("#"))
        .toList();
    List<String> lowerCased =
        hashtags.map((e) => e.toLowerCase()).toSet().toList();
    List<String> finalList = <String>[];
    finalList.addAll(lowerCased);

    // list!.replaceAll("\n", " ");
    // var l = list
    //     .split(" ")
    //     .where((element) {
    //       print("element[0]: ${element[0]}");
    //       return element[0] == "#";
    //     })
    //     .toSet()
    //     .toList();
    // var lowerCased = l.map((e) => e.toLowerCase());
    // var finalList = <String>[];
    // finalList.addAll(lowerCased);
    // finalList.addAll(l);
    // l.forEach((element) {
    //   element.toLowerCase();
    // });
    // if (l.isNotEmpty)
    //   l.forEach((element) {
    //     var h = element.split("#");
    //     if (h.length > 1) {
    //       l.remove(element);
    //       l.add(h[1]);
    //       l.add(h[0]);
    //     }
    //   });
    return finalList;
  }

  List<String> get getPlainHashtagsFromPost {
    if (!postCaption!.contains("#")) return [];
    var list = postCaption;
    list!.replaceAll("\n", "");
    var l =
        list.split(" ").where((element) => element[0] == "#").toSet().toList();
    l.forEach((element) {
      element.toLowerCase();
    });
    return l.toSet().toList();
  }

  @override
  String toString() {
    return 'PostModel(postId: $postId, postCaption: $postCaption)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostModel && other.postId == postId;
  }

  @override
  int get hashCode {
    return postId.hashCode ^
        ownerId.hashCode ^
        postCaption.hashCode ^
        postLocation.hashCode ^
        attachedRecipeId.hashCode ^
        attachedWorkoutId.hashCode ^
        postAttachmentUrl.hashCode ^
        timestamp.hashCode ^
        videoMode.hashCode ^
        likeCount.hashCode ^
        commentCount.hashCode ^
        followedBy.hashCode ^
        likedBy.hashCode ^
        savedBy.hashCode ^
        taggedUsers.hashCode ^
        pinnedCommentID.hashCode ^
        reports.hashCode;
  }
}

extension StreamFeedActivity on PostModel {}

class LikeData {
  bool isLiked;
  int likeCount;
  LikeData({this.isLiked = false, this.likeCount = 0});
}
