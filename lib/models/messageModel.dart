import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  int? type;
  String? content;
  DateTime? sentAt;
  String? sender;

  MessageModel({this.type, this.content, this.sentAt, this.sender});

  Map<String, dynamic> toMap() {
    return {
      "type": this.type,
      "content": this.content,
      "sentAt": this.sentAt,
      "sender": this.sender,
    };
  }

  factory MessageModel.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data() as Map<String, dynamic>;

    return MessageModel(
      type: data["type"],
      content: data["content"],
      sentAt: data["sentAt"].toDate(),
      sender: data["sender"],
    );
  }
}
