import 'package:flutter/material.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';

import '../../models/postmodel.dart';
import '../global/custom_appbar.dart';

class ShowPostWidget extends StatelessWidget {
  final PostModel postModel;
  const ShowPostWidget({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        back: true,
      ),
      body: PostWidget(
        // postModel: postModel,
        postId: postModel.postId,
        // miniMode: true,
      ),
    );
  }
}
