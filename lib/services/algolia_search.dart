import 'package:algolia/algolia.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/view/widgets/recipe_controller.dart';

class AlgoliaApplication {
  static final Algolia algolia = Algolia.init(
    applicationId: '0GMU7W6FWU', //ApplicationID
    apiKey:
        '4f7e94d3c3285c058d59a8bbd133f542', //search-only api key in flutter code
  );

  Future<List<AlgoliaObjectSnapshot>> getSearchResult(
      String input, String collectionName) async {
    AlgoliaQuery query = algolia.instance.index(collectionName).query(input);
    try {
      AlgoliaQuerySnapshot querySnap = await query.getObjects();
      var results = querySnap.hits;
      var hitsList = results;

      return hitsList;
      print("function Called");
    } on AlgoliaError catch (e) {
      print(e.error.toString());
      return [];
    }
  }
}

sortUserSearchResults(List<AlgoliaObjectSnapshot> resultsALG) {
  var results = resultsALG.map((e) => e.objectID).toList();
  var userController = Get.find<UserController>();
  var sortedList = <String>[];
  var friendsInResult =
      userController.friendList.toSet().intersection(results.toSet()).toList();
  var followingInResult = userController.followingList
      .toSet()
      .intersection(results.toSet())
      .toList();
  var followersInResult = userController.followingList
      .toSet()
      .intersection(results.toSet())
      .toList();
  sortedList.addAll(friendsInResult);
  sortedList.addAll(followingInResult);
  sortedList.addAll(followersInResult);
  sortedList.addAll(
      results.where((element) => !sortedList.contains(element)).toList());
  return sortedList.toSet().toList();
}

Future<List<String>> defaultUserSearchResults() async {
  var userDocs = await Database()
      .usersCollection
      .orderBy('followers', descending: true)
      .limit(50)
      .get();

  var results = userDocs.docs.map((e) => e.id).toList();
  var userController = Get.find<UserController>();
  var sortedList = <String>[];
  var friendsInResult =
      userController.friendList.toSet().intersection(results.toSet()).toList();
  var followingInResult = userController.followingList
      .toSet()
      .intersection(results.toSet())
      .toList();
  var followersInResult = userController.followingList
      .toSet()
      .intersection(results.toSet())
      .toList();
  sortedList.addAll(friendsInResult);
  sortedList.addAll(followingInResult);
  sortedList.addAll(followersInResult);
  sortedList.addAll(
      results.where((element) => !sortedList.contains(element)).toList());
  return sortedList.toSet().toList().reversed.toList();
}

sortRecipeSearchResults(List<AlgoliaObjectSnapshot> resultsALG) {
  var results = resultsALG.map((e) => e.objectID).toList();
  var userController = Get.find<UserController>();
  var sortedList = <String>[];
  var friendsInResult =
      userController.friendList.toSet().intersection(results.toSet()).toList();
  var followingInResult = userController.followingList
      .toSet()
      .intersection(results.toSet())
      .toList();
  var followersInResult = userController.followingList
      .toSet()
      .intersection(results.toSet())
      .toList();
  sortedList.addAll(friendsInResult);
  sortedList.addAll(followingInResult);
  sortedList.addAll(followersInResult);
  sortedList.addAll(
      results.where((element) => !sortedList.contains(element)).toList());
  return sortedList.toSet().toList();
}
