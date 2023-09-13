import 'dart:convert';

import 'package:story_view/story_view.dart';

class StoryModel {
  String? ownerId;
  DateTime? timestamp;
  String? attachmentUrl;
  bool? isVideo;
  String? storyId;
  int? viewCount;
  StoryModel({
    this.ownerId,
    this.timestamp,
    this.attachmentUrl,
    this.isVideo,
    this.storyId,
    this.viewCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'timestamp': timestamp!.millisecondsSinceEpoch,
      'attachmentUrl': attachmentUrl,
      'isVideo': isVideo,
      'storyId': storyId,
      'viewCount': viewCount,
    };
  }

  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      ownerId: map['ownerId'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      attachmentUrl: map['attachmentUrl'],
      isVideo: map['isVideo'],
      storyId: map['storyId'],
      viewCount: map['viewCount'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory StoryModel.fromJson(String source) =>
      StoryModel.fromMap(json.decode(source));

  StoryItem storyItem(StoryController controller) {
    if (this.isVideo!)
      return StoryItem.pageVideo(this.attachmentUrl!, controller: controller);
    return StoryItem.pageImage(
        url: this.attachmentUrl!, controller: controller);
  }
}
