import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ThreadPage extends StatefulWidget {
  ThreadPage({
    Key? key,
    this.parent,
  }) : super(key: key);

  final Message? parent;

  @override
  State<ThreadPage> createState() => _ThreadPageState();
}

class _ThreadPageState extends State<ThreadPage> {
  StreamMessageInputController messageInputController =
      StreamMessageInputController();
  @override
  void initState() {
    messageInputController = StreamMessageInputController(
      message: widget.parent,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamThreadHeader(
        parent: widget.parent!,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamMessageListView(
              parentMessage: widget.parent,
            ),
          ),
          StreamMessageInput(
            messageInputController: messageInputController,
          ),
        ],
      ),
    );
  }
}
