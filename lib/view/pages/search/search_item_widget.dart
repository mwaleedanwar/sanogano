import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/search_controller.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/pages/search/searched_item.dart';

class SearchItemWidget extends StatelessWidget {
  final Function onTap;
  final String id;
  final Widget child;
  final Map<String, dynamic> map;
  SearchItemWidget(
      {super.key,
      required this.onTap,
      required this.id,
      required this.child,
      required this.map});
  SearchController sc = Get.find<SearchController>();
  Database db = Database();
  AuthController ac = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    var model = SearchedItemModel(
        timeOfSearch: DateTime.now(),
        searchTerm: sc.textFieldController.text,
        type: sc.getSearchType(),
        id: id,
        snapshotJson: map);
    return GestureDetector(
      onTap: () async {
        db.recentSearches(ac.user!.uid).doc(model.id).set(model.toMap());
        onTap();
      },
      child: SearchedItemWidget(
        model: model,
        child: child,
        withDeletion: false,
      ),
    );
  }
}
