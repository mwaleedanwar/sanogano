import 'dart:convert';

import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/services/notificationService.dart';

class NotificationModel {
  List<String>? receiverUids;
  String? senderUid;
  String? notificationId;
  String? notificationHeader;
  String? notificationBody;
  DateTime? timestamp;
  String? senderName;
  NotificationType? notificationType;
  String? postId;
  String? originalCommentId;
  NotificationModel({
    this.receiverUids,
    this.senderUid,
    this.notificationId,
    this.notificationHeader,
    this.notificationBody,
    this.timestamp,
    this.senderName,
    this.notificationType,
    this.postId,
    this.originalCommentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'receiverUid': receiverUids,
      'senderUid': senderUid,
      'notificationId': notificationId,
      'notificationHeader': notificationHeader,
      'notificationBody': notificationBody,
      'timestamp': timestamp!.millisecondsSinceEpoch,
      'senderName': senderName,
      'notificationType': notificationType!.index,
      'postId': postId,
      'originalCommentId': originalCommentId,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      receiverUids: map['receiverUid']?.cast<String>() ?? [],
      senderUid: map['senderUid'],
      notificationId: map['notificationId'],
      notificationHeader: map['notificationHeader'],
      notificationBody: map['notificationBody'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      senderName: map['senderName'],
      notificationType: NotificationType.values[map['notificationType'] ?? 0],
      postId: map['postId'] ?? '',
      originalCommentId: map['originalCommentId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory NotificationModel.fromJson(String source) =>
      NotificationModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'NotificationModel(receiverUids: $receiverUids, senderUid: $senderUid, notificationId: $notificationId, notificationHeader: $notificationHeader, notificationBody: $notificationBody, timestamp: $timestamp, senderName: $senderName)';
  }
}

class DetailedNotificationModel {
  NotificationModel notificationModel;
  UserModel sender;
  DetailedNotificationModel({
    required this.notificationModel,
    required this.sender,
  });
}
