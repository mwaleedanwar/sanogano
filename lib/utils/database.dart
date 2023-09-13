import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/models/user.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/view/global/constants.dart';
import 'package:sano_gano/view/pages/search/recent_searches.dart';

class Database {
  var currentUserId = Get.find<AuthController>().user?.uid ?? "";
  CollectionReference get usersCollection =>
      FirebaseFirestore.instance.collection("users");

  CollectionReference get subscriptionsCollection =>
      FirebaseFirestore.instance.collection("subscriptions");

  CollectionReference timelinesCollection(String uid) =>
      FirebaseFirestore.instance
          .collection("timelines")
          .doc(uid)
          .collection('posts');

  CollectionReference storyCollection(String uid) => FirebaseFirestore.instance
      .collection("stories")
      .doc(uid)
      .collection('stories');
  CollectionReference blockedUsersCollection(String blockerId) =>
      usersCollection.doc(blockerId).collection('blockedUsers');
  CollectionReference get postsCollection =>
      FirebaseFirestore.instance.collection("posts");
  CollectionReference get streamFeedActivities => FirebaseFirestore.instance
      .collection("feeds")
      .doc('user')
      .collection(currentUserId);

  CollectionReference savedPosts(String uid) =>
      usersCollection.doc(uid).collection('savedPosts');
  CollectionReference likedPosts(String uid) =>
      usersCollection.doc(uid).collection('likedPosts');
  CollectionReference subscribers(String uid) =>
      usersCollection.doc(uid).collection(USERS_SUBSCRIBERS_COLLECTION);
  CollectionReference likedComments(String uid) =>
      usersCollection.doc(uid).collection('likedPosts');
  CollectionReference get chatCollection =>
      FirebaseFirestore.instance.collection("chat");
  CollectionReference recipeCollection({String? uid}) =>
      usersCollection.doc(uid ?? currentUserId).collection("recipes");
  CollectionReference workoutCollection({String? uid}) =>
      usersCollection.doc(uid ?? currentUserId).collection("workouts");
  CollectionReference appActivityHistory(String uid) =>
      usersCollection.doc(uid).collection("appActivityHistory");
  Query appActivityHistoryQuery(String uid) => usersCollection
      .doc(uid)
      .collection("appActivityHistory")
      .where('timestamp',
          isGreaterThan: DateTime.now()
              .subtract(Duration(days: 84))
              .millisecondsSinceEpoch);
  CollectionReference get reportsCollection =>
      FirebaseFirestore.instance.collection("/reports");
  CollectionReference suggestionsCollection(String uid) =>
      usersCollection.doc(uid).collection("/suggestions");
  CollectionReference get hashTagsCollection =>
      FirebaseFirestore.instance.collection("/hashtags");

  CollectionReference<Map<String, dynamic>> commentsCollection(String postId) =>
      postsCollection.doc(postId).collection('comments');

  CollectionReference postReportsCollection(String postId) =>
      postsCollection.doc(postId).collection('reports');
  CollectionReference postLikes(String postId) =>
      postsCollection.doc(postId).collection('likes');
  CollectionReference postSaves(String postId) =>
      postsCollection.doc(postId).collection('saves');

  CollectionReference savedRecipes(String uid) =>
      usersCollection.doc(uid).collection("/savedRecipes");

  CollectionReference savedWorkouts(String uid) =>
      usersCollection.doc(uid).collection("/savedWorkouts");
  DocumentReference notificationSettings(String uid) =>
      FirebaseFirestore.instance.collection("/notificationSettings").doc(uid);
  CollectionReference followRequests(String uid) =>
      usersCollection.doc(uid).collection("/followRequests");

  CollectionReference recentSearches(String uid) =>
      usersCollection.doc(uid).collection("/recentSearches");
  Query recentSearchesQuery(String uid) =>
      recentSearches(uid).orderBy('timeOfSearch', descending: true);

  CollectionReference followingCollection(String uid) =>
      FirebaseFirestore.instance
          .collection("following")
          .doc(uid)
          .collection("u_following");

  CollectionReference followersCollection(String uid) =>
      FirebaseFirestore.instance
          .collection("followers")
          .doc(uid)
          .collection("u_followers");

  Query get allRecipes => FirebaseFirestore.instance.collectionGroup("recipes");
  Query get allStories => FirebaseFirestore.instance.collectionGroup("stories");
  Query get allWorkouts =>
      FirebaseFirestore.instance.collectionGroup("workouts");
  Future<List<DocumentSnapshot>> documentsWithParametersThatAreInList(
      Query collectionReference,
      String parameterName,
      List<String> listOfValues) async {
    var allDocs = <DocumentSnapshot>[];
    int chunkSize = 10;
    while (listOfValues.length >= 0) {
      if (listOfValues.length > chunkSize) {
        var result = await collectionReference
            .where(parameterName, whereIn: listOfValues.sublist(0, chunkSize))
            .get();
        if (result.docs.length > 0) {
          allDocs.addAll(result.docs);
        }
        listOfValues.removeRange(0, chunkSize);
      } else {
        var result = await collectionReference
            .where(parameterName,
                whereIn: listOfValues.sublist(0, listOfValues.length))
            .get();
        if (result.docs.length > 0) {
          allDocs.addAll(result.docs);
        }
        listOfValues.removeRange(0, listOfValues.length);
      }
    }
    return allDocs;
  }

  Future<RecipeModel?> getRecipe(String recipeId) async {
    try {
      var docs = await allRecipes.where('recipeId', isEqualTo: recipeId).get();
      if (docs.docs.isNotEmpty) {
        return RecipeModel.fromMap(
            docs.docs.first.data() as Map<String, dynamic>);
      } else {
        print("recipe is null");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<RecipeModel?> getRecipeStream(String recipeId) {
    return allRecipes
        .where('recipeId', isEqualTo: recipeId)
        .snapshots()
        .map((event) {
      if (event.docs.isNotEmpty) {
        return RecipeModel.fromMap(
            event.docs.first.data() as Map<String, dynamic>);
      } else {
        print("recipe is null");
        return null;
      }
    });
  }

  Future<WorkoutModel?> getWorkout(String workoutId) async {
    try {
      var docs =
          await allWorkouts.where('workoutId', isEqualTo: workoutId).get();
      if (docs.docs.isNotEmpty) {
        return WorkoutModel.fromMap(
            docs.docs.first.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<UserModel> getUserNonNullable(String id) async {
    try {
      var docs = await usersCollection.doc(id).get();
      if (docs.exists) {
        return UserModel.fromFirestore(docs);
      } else {
        throw Exception("User does not exist");
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<UserModel?> getUser(String id) async {
    try {
      var docs = await usersCollection.doc(id).get();
      if (docs.exists) {
        return UserModel.fromFirestore(docs);
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<String?> getUserIdFromEmail(String email) async {
    try {
      var docs = await usersCollection.where('email', isEqualTo: email).get();
      if (docs.docs.isNotEmpty) {
        return docs.docs.first.id;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<PostModel?> getPost(String postId) async {
    try {
      var doc = await postsCollection.doc(postId).get();
      if (doc.exists)
        return PostModel.fromMap(doc.data() as Map<String, dynamic>);
      return null;
    } catch (e) {
      print("Error getting post");
      print(e);
      return null;
    }
  }

  Future<List<PostModel>> getPosts(List<String> postIds) async {
    try {
      var doc = await postsCollection.where('postId', whereIn: postIds).get();

      if (doc.docs.isNotEmpty)
        return doc.docs
            .map((e) => PostModel.fromMap(e.data() as Map<String, dynamic>))
            .toList();

      print(doc.docs.length);
      return [];
    } catch (e) {
      print("Error getting post");
      print(e);
      return [];
    }
  }

  Future<List<PostModel>> getAllPostsFromIDs(List<String> postIds) async {
    try {
      List<PostModel> posts = [];
      posts.addAll(await getPosts(postIds));
      // for (var item in postIds) {
      //   var p = await getPost(item);
      //   if (p != null) posts.add(p);
      // }
      return posts;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
