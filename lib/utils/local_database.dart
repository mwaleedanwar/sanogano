import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:sano_gano/view/pages/search/searched_item.dart';

class LocalDatabase {
  init() async {}

  static Future<void> addToRecents(
    SearchedItemModel model,
  ) async {
    try {
      print("adding to recents");
      var recentSearches = await Hive.openBox('recent-searches');
      var index = await recentSearches.add(model);
      print("saved to index $index");
      return;
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  Future<void> addToPostCache(List<String> postIds, String uid) async {
    try {
      print("adding to recents");
      var recentSearches = await Hive.openBox(uid);
      var index = await recentSearches.addAll(postIds);
      print("saved to index $index");
      return;
    } catch (e) {
      print(e.toString());
      return;
    }
  }
}
