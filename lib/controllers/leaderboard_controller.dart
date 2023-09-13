import 'package:get/get.dart';
import 'package:sano_gano/models/hashtag_model.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/services/user_database.dart';

import '../utils/database.dart';

class LeaderBoardController extends GetxController {
  Rx<List<UserModel>?> userList = Rx<List<UserModel>?>([]);
  List<UserModel>? get usersModelList => userList.value;
  Rx<List<HashtagModel>?> _popularHashtags = Rx<List<HashtagModel>?>([]);
  List<HashtagModel>? get popularHashtags => _popularHashtags.value;
  Rx<List<RecipeModel>?> _popularRecipes = Rx<List<RecipeModel>?>([]);
  List<RecipeModel>? get popularRecipes => _popularRecipes.value;
  Rx<List<WorkoutModel>?> _popularWorkouts = Rx<List<WorkoutModel>?>([]);
  List<WorkoutModel>? get popularWorkouts => _popularWorkouts.value;
  Rx<List<PostModel>?> _popularPosts = Rx<List<PostModel>?>([]);
  List<PostModel>? get popularPosts => _popularPosts.value;

  Database _database = Database();

  RxBool _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  Stream<List<HashtagModel>> _popularHashtagsStream() {
    return _database.hashTagsCollection
        .orderBy('hitCount', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                HashtagModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<RecipeModel>> _popularRecipesStream() {
    return _database.allRecipes
        .orderBy('saveCount', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                RecipeModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<WorkoutModel>> _popularWorkoutsStream() {
    return _database.allWorkouts
        .orderBy('saveCount', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                WorkoutModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<PostModel>> _popularPostsStream() {
    return _database.postsCollection
        .orderBy('likeCount', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  void onInit() {
    userList.bindStream(UserDatabase().getLeaderBoardUsers());
    _popularHashtags.bindStream(_popularHashtagsStream());
    _popularRecipes.bindStream(_popularRecipesStream());
    _popularWorkouts.bindStream(_popularWorkoutsStream());
    _popularPosts.bindStream(_popularPostsStream());
    _isLoading.value = false;
    super.onInit();
  }
}
