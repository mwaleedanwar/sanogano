import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/loaders.dart';
import 'package:sano_gano/models/workoutModel.dart';
import 'package:sano_gano/utils/database.dart';

import '../../controllers/search_controller.dart';

class WorkoutController extends GetxController {
  var db = Database();
  var userController = Get.find<UserController>();
  String generateId() {
    return db.workoutCollection().doc().id;
  }

  Future<List<WorkoutModel>> getAllWorkouts() async {
    var docs = await db.workoutCollection().get();
    if (docs.docs.isEmpty) return [];
    return docs.docs
        .map((e) => WorkoutModel.fromMap(e.data() as Map<String, dynamic>))
        .toList();
  }

  Future<bool> submitWorkout(WorkoutModel workoutModel) async {
    try {
      // var doc = db.workoutCollection.doc();
      //workoutModel.workoutId = doc.id;
      await db
          .workoutCollection()
          .doc(workoutModel.workoutId)
          .set(workoutModel.toMap());
      await saveWorkout(workoutModel.workoutId!, workoutModel.workoutName!);
      print(workoutModel.workoutId);
      return true;
    } catch (e) {
      printError(info: e.toString());
      return false;
    }
  }

  Future<bool> updateWorkout(WorkoutModel workoutModel) async {
    try {
      await db
          .workoutCollection()
          .doc(workoutModel.workoutId)
          .update(workoutModel.toMap());
      await Get.find<SearchController>().loadInitialTrendingData();

      return true;
    } catch (e) {
      printError(info: e.toString());
      return false;
    }
  }

  Future<WorkoutModel?> getWorkout(String id) async {
    try {
      var doc =
          await db.allWorkouts.where('workoutId', isEqualTo: id).limit(1).get();

      if (doc.docs.isNotEmpty)
        return WorkoutModel.fromMap(
            doc.docs.first.data() as Map<String, dynamic>);
      return null;
    } catch (e) {
      printError(info: e.toString());
      return null;
    }
  }

  Future<DocumentSnapshot?> getWorkoutDoc(String id) async {
    try {
      print(id);
      var doc =
          await db.allWorkouts.where('workoutId', isEqualTo: id).limit(1).get();

      if (doc.docs.isNotEmpty) return doc.docs.first;
      return null;
    } catch (e) {
      printError(info: e.toString());
      return null;
    }
  }

  Future<bool> toggleSave(WorkoutModel workoutModel) async {
    try {
      if (await isSaved(workoutModel.workoutId!)) {
        // if (postModel.likedBy.contains(currentUserUid)) {
        print("unsaving");
        await unsaveWorkout(
          workoutModel.workoutId!,
        );
        Get.find<SearchController>().loadInitialTrendingData();

        return false;
      } else {
        print("saving");
        await saveWorkout(workoutModel.workoutId!, workoutModel.workoutName!,
            ownerId: workoutModel.ownerId);

        return true;
      }
    } catch (e) {
      print("Error toggling saves in workout");
      print(e);
      rethrow;
    }
  }

  Future<bool> isSaved(String workoutId) async {
    try {
      var doc = await db
          .savedWorkouts(userController.userModel.id!)
          .doc(workoutId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Stream<bool> isSavedStream(String workoutId) {
    return db
        .savedWorkouts(userController.userModel.id!)
        .doc(workoutId)
        .snapshots()
        .map((event) => event.exists);
  }

  Future<bool> saveWorkout(String workoutId, String workoutName,
      {String? ownerId}) async {
    try {
      await db.savedWorkouts(userController.currentUid).doc(workoutId).set({
        'workoutId': workoutId,
        'timestamp': FieldValue.serverTimestamp(),
        'workoutName': workoutName,
        'ownerId': ownerId ?? userController.currentUid
      });
      await Get.find<SearchController>().loadInitialTrendingData();

      // await incrementWorkoutSaves(workoutId);
      return true;
    } catch (e) {
      print("Error saving workout");
      print(e);
      return false;
    }
  }

  Future<void> reportWorkout(WorkoutModel workout) async {
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
        "postId": workout.workoutId,
        "reason": reason ?? "",
        "date": DateTime.now().toIso8601String(),
      });
      db.allWorkouts.doc(workout.workoutId).update({
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

  Future<bool> deleteWorkout(String workoutId) async {
    try {
      showLoading(loadingText: "Deleting...");
      await db
          .workoutCollection(uid: userController.currentUid)
          .doc(workoutId)
          .delete();
      //* refresh data
      await Get.find<SearchController>().loadInitialTrendingData();

      hideLoading();
      return true;
    } catch (e) {
      print("Error deleting workout");
      print(e);
      return false;
    }
  }

  Future<bool> unsaveWorkout(String workoutId) async {
    try {
      // showLoading(loadingText: "Deleting...");

      await db.savedWorkouts(userController.currentUid).doc(workoutId).delete();
      await Get.find<SearchController>().loadInitialTrendingData();

      // await decrementWorkoutSaves(workoutId);
      // hideLoading();
      return true;
    } catch (e) {
      print("Error unsaving workout");
      print(e);
      return false;
    }
  }

  Future<void> incrementWorkoutLikes(String workoutId) async {
    var workout = await getWorkoutDoc(workoutId);
    if (workout == null) return;

    workout.reference.update({'likeCount': FieldValue.increment(1)});

    return;
  }

  // Future<void> incrementWorkoutSaves(String workoutId) async {
  //   var workout = await getWorkoutDoc(workoutId);
  //   if (workout == null) return;

  //   workout.reference.update({'saveCount': FieldValue.increment(1)});

  //   return;
  // }

  // Future<void> decrementWorkoutSaves(String workoutId) async {
  //   var workout = await getWorkoutDoc(workoutId);
  //   if (workout == null) return;

  //   workout.reference.update({'saveCount': FieldValue.increment(-1)});

  //   return;
  // }
}
