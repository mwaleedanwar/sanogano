import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/search_controller.dart';

import '../../../models/hashtag_model.dart';
import 'build_initial.dart';
import 'hashtag_search_tile.dart';

class HashTagsSearchScreen extends StatelessWidget {
  HashTagsSearchScreen({super.key});
  SearchController sc = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(children: <Widget>[
        Expanded(
            child: sc.isHitListEmpty && sc.textFieldController.text.isEmpty
                ? BuildInitial(index: 1)
                : ListView.builder(
                    shrinkWrap: false,
                    physics: ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      var snapshot = sc.hitsList![index];
                      var hashtag = HashtagModel.fromMap(snapshot.data);
                      return HashtagSearchTile(hashtagModel: hashtag);
                    },
                    itemCount: sc.searchCount,
                  )),
      ]);
    });
  }
}
