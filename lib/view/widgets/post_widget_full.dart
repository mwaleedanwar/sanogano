import 'package:flutter/material.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/view/global/custom_appbar.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';

class PostWidgetFull extends StatefulWidget {
  final PostModel postModel;

  const PostWidgetFull(this.postModel);

  @override
  _PostWidgetFullState createState() => _PostWidgetFullState();
}

class _PostWidgetFullState extends State<PostWidgetFull> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
      ),
      body: PostWidget(
        postModel: widget.postModel,
        postId: widget.postModel.postId,
      ),
    );
  }
}
