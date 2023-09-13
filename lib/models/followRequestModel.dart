import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class FollowRequestModel {
  String? requestID;
  String? receiverId;
  String? senderId;
  Timestamp? timestamp;
  RequestStatus? requestStatus;
  DocumentReference? reference;

  bool get isAccepted => this.requestStatus == RequestStatus.ACCEPTED;
  bool get isRejected => this.requestStatus == RequestStatus.REJECTED;

  FollowRequestModel({
    this.requestID,
    this.receiverId,
    this.senderId,
    this.timestamp,
    this.requestStatus,
    this.reference,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestID': requestID,
      'receiverId': receiverId,
      'senderId': senderId,
      'timestamp': DateTime.now(),
      'requestStatus': requestStatus!.index,
    };
  }

  factory FollowRequestModel.fromMap(Map<String, dynamic> map) {
    return FollowRequestModel(
      requestID: map['requestID'],
      receiverId: map['receiverId'],
      senderId: map['senderId'],
      timestamp: map['timestamp'],
      requestStatus: RequestStatus.values[map['requestStatus'] ?? 3],
    );
  }

  factory FollowRequestModel.fromFirestore(DocumentSnapshot doc) {
    // if (!doc.exists) return null;
    return FollowRequestModel.fromMap(doc.data() as Map<String, dynamic>)
        .copyWith(reference: doc.reference);
  }

  String toJson() => json.encode(toMap());

  factory FollowRequestModel.fromJson(String source) =>
      FollowRequestModel.fromMap(json.decode(source));

  FollowRequestModel copyWith({
    String? requestID,
    String? receiverId,
    String? senderId,
    Timestamp? timestamp,
    RequestStatus? requestStatus,
    DocumentReference? reference,
  }) {
    return FollowRequestModel(
      requestID: requestID ?? this.requestID,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      timestamp: timestamp ?? this.timestamp,
      requestStatus: requestStatus ?? this.requestStatus,
      reference: reference ?? this.reference,
    );
  }
}

enum RequestStatus {
//  0     , 1       , 2      , 3
  ACCEPTED,
  REJECTED,
  DELETED,
  IGNORED
}
