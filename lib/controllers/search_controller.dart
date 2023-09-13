import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sano_gano/services/algolia_search.dart';
import 'package:sano_gano/utils/database.dart';

import '../view/pages/search/searched_item.dart';

class SearchController extends GetxController {
  final Algolia _algoliaApp = AlgoliaApplication.algolia;
  Database db = Database();

  //* initial data to show before search
  Rx<Map<int, List<Map<String, dynamic>>>> _initialTrendingData =
      Rx<Map<int, List<Map<String, dynamic>>>>({});
  Map<int, List<Map<String, dynamic>>> get initialTrendingData =>
      _initialTrendingData.value;
  RxBool get _isInitialDataEmpty => initialTrendingData.isEmpty.obs;
  bool get isInitialDataEmpty => _isInitialDataEmpty.value;
  // * currently selected screen
  RxInt _currentScreen = 0.obs;
  int get currentScreen => _currentScreen.value;
  set setCurrentScreen(int value) => _currentScreen.value = value;

//* Search related data [Algolia]
  Rx<List<AlgoliaObjectSnapshot>?> _hitsList =
      Rx<List<AlgoliaObjectSnapshot>?>([]);
  List<AlgoliaObjectSnapshot>? get hitsList => _hitsList.value;
  RxBool get _isHitsEmpty => hitsList!.isEmpty.obs;
  bool get isHitListEmpty => _isHitsEmpty.value;
  RxInt get _hitsCount => hitsList!.length.obs;
  int get searchCount => _hitsCount.value;

//* variables

  Rx<List<String>?> _defaultUsers = Rx<List<String>?>([]);
  List<String>? get defaultUsers => _defaultUsers.value;
  Rx<TextEditingController> _textFieldController = TextEditingController().obs;
  TextEditingController get textFieldController => _textFieldController.value;
  RxBool _isSearchActive = false.obs;
  bool get isSearchActive => _isSearchActive.value;
  set setIsSearchActive(bool value) => _isSearchActive.value = value;

  var resultTypes = {
    0: SearchedItemType.USER,
    1: SearchedItemType.HASHTAG,
    2: SearchedItemType.RECIPE,
    3: SearchedItemType.WORKOUT,
  };

  SearchedItemType getSearchType() {
    return resultTypes[currentScreen]!;
  }

  @override
  void onInit() {
    loadInitialTrendingData();
    textFieldController.addListener(() async {
      if (textFieldController.text.isNotEmpty) {
        _isSearchActive.value = true;
      }
      EasyDebounce.debounce('search-debounce', 700.milliseconds, () async {
        await _getSearchResult(textFieldController.text).then((value) {
          print("getting search results ${value!.length}");
          _hitsList.value = value;
        });
      });
    });
    loadDefaultUsers();
    super.onInit();
  }

  void clearSearchField({bool showRecentSearches = false}) {
    _textFieldController.value.clear();
    _hitsList.value = [];
    if (showRecentSearches) {
      _isSearchActive.value = false;
    }
  }

  Future<void> loadDefaultUsers() async {
    _defaultUsers.value = await defaultUserSearchResults();
  }

// Stream loadInitialDataStream() {
//     return db.usersCollection
//         .orderBy('followers', descending: true)
//         .limit(25)
//         .snapshots();
//   }

  Future<void> loadInitialTrendingData() async {
    try {
      _initialTrendingData.value = {
        0: [],
        1: [],
        2: [],
        3: [],
      };
      var users = await db.usersCollection
          .orderBy('followers', descending: true)
          .limit(25)
          .get();
      var hashtags = await db.hashTagsCollection
          .orderBy('hitCount', descending: true)
          .limit(25)
          .get();
      var recipes = await db.allRecipes
          .orderBy('saveCount', descending: true)
          .limit(25)
          .get();
      var workouts = await db.allWorkouts
          .orderBy('saveCount', descending: true)
          .limit(25)
          .get();

      _initialTrendingData.value[0] =
          users.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      _initialTrendingData.value[1] =
          hashtags.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      _initialTrendingData.value[2] =
          recipes.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      _initialTrendingData.value[3] =
          workouts.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      return;
    } on Exception catch (e) {
      print(e);
      return;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }

//* Check which screen is active
  String getCollectionName() {
    switch (currentScreen) {
      case 0:
        return "Users";

      case 1:
        return "Hashtags";

      case 2:
        return "Recipes";

      case 3:
        return "Workouts";

      default:
        return "Users";
    }
  }

  Future<List<AlgoliaObjectSnapshot>?> _getSearchResult(
    String input,
  ) async {
    AlgoliaQuery query = _algoliaApp.instance
        .index(getCollectionName())
        .query(input)
        .setOffset(0)
        .setHitsPerPage(25);

    if (input.length > 0) {
      try {
        AlgoliaQuerySnapshot querySnap = await query.getObjects();
        var results = querySnap.hits;
        var hits = results;

        return hits;
      } on AlgoliaError catch (e) {
        print(e.error.toString());
        return [];
      }
    } else {
      return [];
    }
  }

  Future<bool> getRecipe(String recipeId) async {
    try {
      var recipeQuery =
          await db.allRecipes.where('recipeId', isEqualTo: recipeId).get();
      return recipeQuery.docs.isNotEmpty;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> getWorkout(String workoutId) async {
    try {
      var workout =
          await db.allWorkouts.where('workoutId', isEqualTo: workoutId).get();
      return workout.docs.isNotEmpty;
    } on Exception catch (e) {
      print(e);
      return false;
    }
  }
}




// removed code
// Timer? _timer;
// var _searchedUsers = <AlgoliaObjectSnapshot>[].obs;
// List<AlgoliaObjectSnapshot> get searchedUsers => _searchedUsers.value;
// TextEditingController searchTextController = TextEditingController();
// var _searchText = "".obs;

// searchTextController.dispose();

// _searchUserTimer() {
//   if (_timer!.isActive) {
//     _timer!.cancel();
//   }
//   _timer = Timer(Duration(milliseconds: 400), () {
//     if (_searchText.value != searchTextController.text &&
//         searchTextController.text.length > 1) {
//       _searchText.value = searchTextController.text;
//       getSearchedUserResults(_searchText.value);
//       print(_searchText.value);
//     }
//   });
// }

// void getSearchedUserResults(String input) async {
//   AlgoliaQuery query = _algoliaApp.instance.index("USERS").query(input);
//   AlgoliaQuerySnapshot querySnap = await query.getObjects();
//   _searchedUsers.value = querySnap.hits;
//   print(querySnap.nbHits);
//   print("function Called");
// }

//init state code
// searchTextController.addListener(() {
//   _searchUserTimer();
// });
//getSearchedUserResults('');
