import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/models/hashtag_model.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/pages/search/searched_item.dart';

import '../../../controllers/search_controller.dart';
import '../../widgets/comments_page.dart';
import '../../widgets/hashtag_screen.dart';

class HashtagSearchTile extends StatelessWidget {
  final HashtagModel hashtagModel;

  HashtagSearchTile({super.key, required this.hashtagModel});
  Database db = Database();
  AuthController ac = Get.find<AuthController>();
  SearchController sc = Get.find<SearchController>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        var model = SearchedItemModel(
            timeOfSearch: DateTime.now(),
            searchTerm: sc.textFieldController.text,
            type: sc.getSearchType(),
            id: hashtagModel.id,
            snapshotJson: hashtagModel.toMap());
        db.recentSearches(ac.user!.uid).doc(hashtagModel.id).set(model.toMap());

        Get.to(HashtagsScreen(
          hashtag: hashtagModel.id,
          sortMode: SortMode.new_to_old,
        ));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hashtagModel.id,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Text(
                      hashtagModel.hitCount.toString() +
                          " Post${hashtagModel.hitCount == 1 ? '' : 's'}",
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.5))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
