import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/models/messageModel.dart';

class ChatDatabase {
  Stream<List<MessageModel>> getMessageStream(String chatID) {
    try {
      var ref = FirebaseFirestore.instance
          .collection("chat")
          .doc(chatID)
          .collection("conversation")
          .orderBy("sentAt", descending: true);

      return ref.snapshots().map((list) =>
          list.docs.map((doc) => MessageModel.fromFirestore(doc)).toList());
    } on FirebaseException catch (e) {
      print(e);
      Get.snackbar("error", e.message!);
      rethrow;
    }
  }
}
