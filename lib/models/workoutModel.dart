import 'dart:convert';

import 'package:sano_gano/const/theme.dart';

class WorkoutModel {
  String? workoutId;
  String? ownerId;
  String? workoutName;
  String? notes;
  String? exercises;
  int? saveCount;
  String? workoutCoverURL;
  bool? indexedInSearch;
  int? postCount;
  int? likeCount;
  int? reports;
  WorkoutModel(
      {this.workoutId,
      this.ownerId,
      this.workoutName,
      this.notes,
      this.exercises,
      this.workoutCoverURL,
      this.indexedInSearch,
      this.postCount,
      this.likeCount,
      this.saveCount,
      this.reports});

  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'ownerId': ownerId,
      'workoutName': workoutName,
      'notes': notes,
      'exercises': exercises,
      'workoutCoverURL': workoutCoverURL,
      'timestamp': DateTime.now(),
      'indexedInSearch': indexedInSearch,
      'postCount': postCount,
      'likeCount': likeCount,
      'saveCount': saveCount,
      'reports': reports
    };
  }

  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
        likeCount: map['likeCount'] ?? 0,
        workoutId: map['workoutId'],
        ownerId: map['ownerId'],
        workoutName: map['workoutName'],
        notes: map['notes'],
        exercises: map['exercises'].toString(),
        workoutCoverURL: map['workoutCoverURL'],
        indexedInSearch: map['indexedInSearch'] ?? false,
        postCount: map['postCount'] ?? 0,
        saveCount: map['saveCount'] ?? 0,
        reports: map['reports'] ?? 0);
  }

  String toJson() => json.encode(toMap());

  factory WorkoutModel.fromJson(String source) =>
      WorkoutModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'WorkoutModel(workoutId: $workoutId, ownerId: $ownerId, workoutName: $workoutName, notes: $notes, exercises: $exercises, workoutCoverURL: $workoutCoverURL, indexedInSearch: $indexedInSearch)';
  }

  bool get isDefaultImage => this.workoutCoverURL == defaultWorkoutImage;
}
