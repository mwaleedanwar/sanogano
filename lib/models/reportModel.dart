import 'dart:convert';

class ReportModel {
  String? reportID;
  String? userID;
  String? flaggedBy;
  String? reportedFor;
  bool? isGroup;
  String? conversationId;
  String? messageId;
  ReportModel({
    this.reportID,
    this.userID,
    this.flaggedBy,
    this.reportedFor,
    this.isGroup,
    this.conversationId,
    this.messageId,
  });

  Map<String, dynamic> toMap() {
    return {
      'reportID': reportID,
      'userID': userID,
      'flaggedBy': flaggedBy,
      'reportedFor': reportedFor,
      'isGroup': isGroup,
      'conversationId': conversationId,
      'messageId': messageId,
    };
  }

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportID: map['reportID'],
      userID: map['userID'],
      flaggedBy: map['flaggedBy'],
      reportedFor: map['reportedFor'],
      isGroup: map['isGroup'] ?? false,
      conversationId: map['conversationId'] ?? "",
      messageId: map['messageId'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ReportModel.fromJson(String source) =>
      ReportModel.fromMap(json.decode(source));
}
