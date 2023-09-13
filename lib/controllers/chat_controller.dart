import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/messageModel.dart';
import 'package:sano_gano/services/chat_database.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatController extends GetxController {
  final String? groupChatID;
  final BuildContext context;
  var chatCollection = FirebaseFirestore.instance.collection("chat");
  var user = Get.find<AuthController>().user;
  UserController uc = Get.find<UserController>();
  var _conversation = <MessageModel>[].obs;

  ChatController({this.groupChatID, required this.context});
  List<MessageModel> get conversation => _conversation.value;
  Rx<StreamChannelListController?> _channelListController =
      Rx<StreamChannelListController?>(null);
  StreamChannelListController? get channelListController =>
      _channelListController.value;
  Query get currentUserInbox =>
      chatCollection.where('users', arrayContains: user!.uid);

  @override
  void onInit() {
    _channelListController.value = StreamChannelListController(
      client: uc.chatClient,
      filter: Filter.or([
        Filter.and([
          Filter.in_(
            'members',
            [StreamChat.of(context).currentUser!.id],
          ),
          Filter.exists(
            'messageCount',
            exists: true,
          ),
        ]),
        Filter.and([
          Filter.in_(
            'members',
            [StreamChat.of(context).currentUser!.id],
          ),
          Filter.exists(
            'isGroup',
            exists: true,
          ),
        ]),
      ]),
      channelStateSort: const [
        SortOption('last_message_at'),
        SortOption(
          'created_at',
          direction: SortOption.ASC,
        ),
      ],
      presence: true,
      limit: 30,
    );
    super.onInit();
  }

  Future<void> refreshChannelList() async {
    await _channelListController.value!.refresh();
  }

  @override
  void onClose() {
    _channelListController.value?.dispose();
    super.onClose();
  }

  Future<void> sendMessage(
      String content, int type, String sender, String receiver,
      {String? chatId}) async {
    DateTime timeStamp = DateTime.now();

    var chatID = chatId != null ? chatId : createChatID(sender, receiver);

    var message = MessageModel(
        type: type, content: content, sentAt: timeStamp, sender: sender);
    try {
      chatCollection
          .doc(chatID)
          .collection("conversation")
          .add(message.toMap())
          .whenComplete(() async {
        await updateChatMetaData(chatID, timeStamp, content, sender);
      });
      await NotificationService().sendNotificationForNewMessage(
          [receiver], null, message.content!, sender, chatID);
    } on FirebaseException catch (e) {
      print(e);
      Get.snackbar("Error", e.message!, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateChatMetaData(
      String chatID, DateTime timeStamp, String message, String sender) async {
    await chatCollection.doc(chatID).update({
      "lastMessage": message,
      "timeStamp": timeStamp,
      "sender": sender,
    });
  }

  Future<bool> createChatRoom(String userID, String myID) async {
    var chatID = createChatID(userID, myID);
    var snapshot =
        await FirebaseFirestore.instance.collection("chat").doc(chatID).get();

    if (snapshot.exists) {
      return true;
    } else {
      await FirebaseFirestore.instance.collection("chat").doc(chatID).set({
        "users": [myID, userID]
      });
      return true;
    }
  }

  getConversation(
    myID,
    userID,
  ) async {
    var chatID =
        groupChatID!.isNotEmpty ? groupChatID : createChatID(myID, userID);
    _conversation.bindStream(ChatDatabase().getMessageStream(chatID!));
  }

  String createChatID(String a, String b) {
    if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
      return "$b\_$a";
    } else {
      return "$a\_$b";
    }
  }

  Future<bool> sendToMultipleSeparately(
      List<String> uids, String textMessage) async {
    try {
      var currentUID = Get.find<AuthController>().user!.uid;
      for (var otherID in uids) {
        await sendMessage(textMessage, 1, currentUID, otherID);
      }
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  /// returns the group id
  Future<String?> createGroup(List<String> uids, String groupName) async {
    try {
      var ref = FirebaseFirestore.instance.collection("chat").doc();
      var currentUID = Get.find<AuthController>().user!.uid;
      uids.add(currentUID);
      await FirebaseFirestore.instance.collection("chat").doc(ref.id).set({
        "users": uids,
        "groupName": groupName,
        'groupMode': true,
      });
      return ref.id;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
