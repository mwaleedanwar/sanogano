import 'dart:convert';

class HashtagModel {
  String id;
  String hashtag;
  int hitCount;
  HashtagModel({
    required this.id,
    required this.hashtag,
    required this.hitCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hashtag': hashtag,
      'hitCount': hitCount,
    };
  }

  factory HashtagModel.fromMap(Map<String, dynamic> map) {
    return HashtagModel(
      id: map['id'] ?? '',
      hashtag: map['hashtag'] ?? '',
      hitCount: map['hitCount']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory HashtagModel.fromJson(String source) =>
      HashtagModel.fromMap(json.decode(source));
}
