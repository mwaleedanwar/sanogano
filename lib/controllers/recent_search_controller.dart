import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/view/pages/search/searched_item.dart';

import '../utils/database.dart';

class RecentSearchController extends GetxController {
  var db = Database();
  var ac = Get.find<AuthController>();
  Rx<List<SearchedItemModel>?> _recentSearchList =
      Rx<List<SearchedItemModel>?>([]);
  List<SearchedItemModel>? get recentSearchList => _recentSearchList.value;
  Stream<List<SearchedItemModel>?> recentSearchStream() {
    return db
        .recentSearchesQuery(ac.user!.uid)
        .limit(15)
        .snapshots()
        .map((event) {
      return event.docs.map((e) {
        print(e.id);
        return SearchedItemModel.fromFirestore(e);
      }).toList();
    });
  }

  @override
  void onInit() {
    _recentSearchList.bindStream(recentSearchStream());
    super.onInit();
  }
}
