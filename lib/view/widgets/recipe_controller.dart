import 'dart:developer';

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/recipeModel.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/functions_service.dart';

import '../../controllers/search_controller.dart';

class RecipeController extends GetxController {
  var db = Database();
  var userController = Get.find<UserController>();

  Future<void> saveAllRecipes(String ownerId) async {
    try {
      // showLoading(loadingText: "Saving all recipes..");
      await FunctionsService.callFunction(
          'sanogano-saveAllRecipes', {'ownerId': ownerId});
      // hideLoading();
    } on Exception catch (e) {
      log(e.toString());
      return;
      // TODO
    }
  }

  String generateId() {
    return db.recipeCollection().doc().id;
  }

  Future<Iterable<RecipeModel>?> getAllRecipes() async {
    var docs = await db.recipeCollection().get();
    if (docs.docs.isEmpty) return [];
    return docs.docs
        .map((e) => RecipeModel.fromMap(e.data() as Map<String, dynamic>));
  }

  Future<bool> submitRecipe(RecipeModel recipeModel) async {
    try {
      await db
          .recipeCollection()
          .doc(recipeModel.recipeId)
          .set(recipeModel.toMap());
      await saveRecipe(recipeModel.recipeId!);

      return true;
    } catch (e) {
      printError(info: e.toString());
      return false;
    }
  }

  Future<bool> updateRecipe(RecipeModel recipeModel) async {
    try {
      await db
          .recipeCollection()
          .doc(recipeModel.recipeId)
          .update(recipeModel.toMap());
      await Get.find<SearchController>().loadInitialTrendingData();

      return true;
    } catch (e) {
      printError(info: e.toString());
      return false;
    }
  }

  Future<RecipeModel?> getRecipe(String id) async {
    try {
      var doc =
          await db.allRecipes.where('recipeId', isEqualTo: id).limit(1).get();

      if (doc.docs.isNotEmpty)
        return RecipeModel.fromMap(
            doc.docs.first.data() as Map<String, dynamic>);
      return null;
    } catch (e) {
      printError(info: e.toString());
      return null;
    }
  }

  Future<DocumentSnapshot?> getRecipeDoc(String id) async {
    try {
      var doc =
          await db.allRecipes.where('recipeId', isEqualTo: id).limit(1).get();

      if (doc.docs.isNotEmpty) return doc.docs.first;
      return null;
    } catch (e) {
      printError(info: e.toString());
      return null;
    }
  }

  Future<bool> toggleSave(RecipeModel recipeModel, bool currentState) async {
    try {
      if (currentState) {
        // if (postModel.likedBy.contains(currentUserUid)) {
        print("unsaving");
        await unsaveRecipe(recipeModel);
        await Get.find<SearchController>().loadInitialTrendingData();

        return false;
      } else {
        print("saving");
        await saveRecipe(recipeModel.recipeId!, ownerId: recipeModel.ownerId!);
        await Get.find<SearchController>().loadInitialTrendingData();

        return true;
      }
    } catch (e) {
      print("Error toggling saves in recipe");
      print(e);
      rethrow;
    }
  }

  Future<bool> isSaved(String recipeId) async {
    try {
      var doc = await db
          .savedRecipes(userController.userModel.id!)
          .doc(recipeId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Stream<bool>? isSavedStream(String recipeId) {
    try {
      return db
          .savedRecipes(userController.userModel.id!)
          .doc(recipeId)
          .snapshots()
          .map((event) => event.exists);
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getRecipeSavedBy(String recipeId) async {
    try {
      RecipeModel? recipe = await getRecipe(recipeId);
      if (recipe == null) return [];
      return recipe.savedBy;
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveRecipe(String recipeId, {String? ownerId}) async {
    try {
      await db.savedRecipes(userController.currentUid).doc(recipeId).set({
        'recipeId': recipeId,
        'timestamp': FieldValue.serverTimestamp(),
        'createdOn': FieldValue.serverTimestamp(),
        'ownerId': ownerId ?? this.userController.currentUid,
      });
      return true;
    } catch (e) {
      print("Error saving recipe");
      print(e);
      return false;
    }
  }

  Future<bool> unsaveRecipe(RecipeModel recipeModel) async {
    try {
      await db
          .savedRecipes(userController.currentUid)
          .doc(recipeModel.recipeId)
          .delete();
      await Get.find<SearchController>().loadInitialTrendingData();

      return true;
    } catch (e) {
      print("Error unsaving recipe");
      print(e);
      return false;
    }
  }

  Future<bool> deleteRecipe(String recipeId) async {
    try {
      showLoading(loadingText: "Deleting..");
      RecipeModel? recipe = await getRecipe(recipeId);
      if (recipe == null) {
        hideLoading();
        Fluttertoast.showToast(msg: "Recipe not found");
        return false;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.delete(
          db.recipeCollection(uid: userController.currentUid).doc(recipeId));
      await Get.find<SearchController>().loadInitialTrendingData();
      await batch.commit();
      hideLoading();
      return true;
    } catch (e) {
      print("Error unsaving recipe");
      print(e);
      return false;
    }
  }

  Future<void> incrementRecipeLikes(String recipeId) async {
    try {
      var recipe = await getRecipeDoc(recipeId);
      recipe!.reference.update({'likeCount': FieldValue.increment(1)});

      return;
    } on AlgoliaError catch (e) {
      print(e.error);
    }
  }

  Future<void> reportWorkout(RecipeModel recipe) async {
    try {
      String? id = await Database().getUserIdFromEmail("support@sanogano.com");
      if (userController.userModel.id == id) return;
      var reason = await Get.to(ReportPostScreen());
      if (reason == null) return;
      db
          .postReportsCollection(postModel.postId)
          .doc(userController.userModel.id)
          .set({
        "reportedBy": userController.userModel.id,
        "reportedTo": id,
        "postId": recipe.recipeId,
        "reason": reason ?? "",
        "date": DateTime.now().toIso8601String(),
      });
      db.allRecipes.doc(recipe.recipeId).update({
        "reports": FieldValue.increment(1),
      });
      // var pDoc = await db.postsCollection.doc(postModel.postId).get();
      // if (((pDoc.data() as Map)[reportlist[4]] ?? 0) > 10) {
      //   await pDoc.reference.delete();
      //   return;
      // }
      // if (((pDoc.data() as Map)[reportlist[6]] ?? 0) > 10) {
      //   await pDoc.reference.delete();
      //   return;
      // }

      // return null;
    } catch (e) {
      return null;
    }
  }
  // Future<bool> incrementRecipeSaves(String recipeId) async {
  //   try {
  //     var recipe = await getRecipeDoc(recipeId);
  //     if (recipe == null) {
  //       return false;
  //     } else {
  //       recipe.reference.update({'saveCount': FieldValue.increment(1)});

  //       return true;
  //     }
  //   } on AlgoliaError catch (e) {
  //     print(e.error);
  //     return false;
  //   }
  // }

  // Future<bool> decrementRecipeSaves(String recipeId) async {
  //   try {
  //     var recipe = await getRecipeDoc(recipeId);
  //     recipe!.reference.update({'saveCount': FieldValue.increment(-1)});

  //     return true;
  //   } on AlgoliaError catch (e) {
  //     print(e.error);
  //     return false;
  //   }
  // }
}
