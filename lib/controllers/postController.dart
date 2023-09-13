import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:optimized_cached_image/optimized_cached_image.dart';
import 'package:rxdart/rxdart.dart' as rxDart;
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/post_enriched_model.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/services/follow_database.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:sano_gano/utils/database.dart';
import 'package:sano_gano/utils/globalHelperMethods.dart';
import 'package:sano_gano/view/pages/profile/settingsPages/report_post_screen.dart';
import 'package:sano_gano/view/widgets/parse/extensions.dart';
import 'package:sano_gano/view/widgets/post_menu_options.dart';
import 'package:sano_gano/view/widgets/post_widget.dart';
import 'package:sano_gano/view/widgets/recipe_controller.dart';
import 'package:sano_gano/view/widgets/workout_controller.dart';

import '../models/user.dart';
import '../services/ImagePickerServices.dart';
import '../view/widgets/custom_widgets/custom_paginate_firestore.dart';

class PostController extends GetxController {
  var db = Database();
  var currentUserUid = Get.find<AuthController>().user!.uid;
  NotificationService notificationService = NotificationService();
  Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  Uint8List? get recentImage => imageBytes.value;

  @override
  void onInit() {
    getRecentSavedImage();
    super.onInit();
  }

  DocumentReference postRef(String postId) => db.postsCollection.doc(postId);

  Future<PostModel?> getPost(String postId) async {
    try {
      var doc = await db.postsCollection.doc(postId).get();
      if (doc.exists)
        return PostModel.fromMap(doc.data() as Map<String, dynamic>);
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Uint8List?> getRecentSavedImage() async {
    imageBytes.value = await ImagePickerServices().getRecentlySavedImage();
    return imageBytes.value;
  }

  Future<EnrichedPostModel?> getPostEnriched(String postId) async {
    try {
      late PostModel post;
      var postdoc = await db.postsCollection.doc(postId).get();
      if (postdoc.exists) {
        post = PostModel.fromMap(postdoc.data() as Map<String, dynamic>);
      } else {
        return null;
      }

      var owner = await Database().getUser(post.ownerId!);
      if (owner == null) return null;
      var liked = await isLiked(postId);
      var saved = await isPostSaved(postId);
      return EnrichedPostModel(
        post: post,
        owner: owner,
        isLiked: liked,
        isSaved: saved,
      );
    } catch (e) {
      printError(info: "Something went wrong while fetching enriched post");
      return null;
    }
  }

  // Future<void> reportPost(PostModel postModel) async {
  //   try {
  //     String? id = await Database().getUserIdFromEmail("support@sanogano.com");
  //     if (userController.userModel.id == id) return;
  //     var reason = await Get.to(ReportPostScreen());
  //     if (reason == null) return;
  //     db
  //         .postReportsCollection(postModel.postId)
  //         .doc(userController.userModel.id)
  //         .set({
  //       "reportedBy": userController.userModel.id,
  //       "reportedTo": id,
  //       "postId": postModel.postId,
  //       "reason": reason ?? "",
  //       "date": DateTime.now().toIso8601String(),
  //     });
  //     db.postsCollection.doc(postModel.postId).update({
  //       "reportCount": FieldValue.increment(1),
  //       reason: FieldValue.increment(1),
  //     });
  //     var pDoc = await db.postsCollection.doc(postModel.postId).get();
  //     if (((pDoc.data() as Map)[reportlist[4]] ?? 0) > 10) {
  //       await pDoc.reference.delete();
  //       return;
  //     }
  //     if (((pDoc.data() as Map)[reportlist[6]] ?? 0) > 10) {
  //       await pDoc.reference.delete();
  //       return;
  //     }

  //     return null;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  Future<void> reportPost(PostModel postModel) async {
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
        "postId": postModel.postId,
        "reason": reason ?? "",
        "date": DateTime.now().toIso8601String(),
      });
      db.postsCollection.doc(postModel.postId).update({
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
    } catch (e) {
      return null;
    }
  }

  Future<List<PostModel>?> getAllSavedPosts({required String uid}) async {
    try {
      List<PostModel> posts = [];
      var listOfDocs = await db
          .savedPosts(uid.isNotEmpty ? uid : currentUserUid)
          .orderBy('timestamp')
          .get();

      var postIds = listOfDocs.docs.map((e) => e.id).toList();
      for (var id in postIds) {
        var post = await getPost(id);
        if (post != null) posts.add(post);
      }
      return posts.reversed.toList();
    } catch (e) {
      return null;
    }
  }

  String generatePostId() => db.postsCollection.doc().id;
  Future<PostModel?> createPost(
      PostModel postModel, List<UserModel> sendNotificationTo) async {
    try {
      // if (postModel.hasVideo) {
      //   var file = await ImagePickerServices.getImageThumbnail(
      //       postModel.postAttachmentUrl!);
      //   var url = await FirebaseStorageServices.uploadToStorage(
      //     file: file,
      //     folderName: "thumbnails",
      //   );
      //   postModel.thumbnailUrl = url;
      // }
      //removed
      postModel.postId = generatePostId();
      var doc = db.postsCollection.doc(postModel.postId);
      await sfc.createPost(postModel);

      await doc.set(postModel.toMap());
      log("saved post with Id ${postModel.postId}");

      for (var element in postModel.getAllHashtagsFromPost) {
        if (element.isValidUsername) {
          await db.hashTagsCollection.doc(element.toLowerCase()).set({
            'id': element.toLowerCase(),
            'hitCount': FieldValue.increment(1),
          }, SetOptions(merge: true));
        }
      }

      List<String?> usersToBeNotified = [];
      if (postModel.taggedUsers!.isNotEmpty) {
        for (var element in postModel.taggedUsers!) {
          if (element != null) {
            usersToBeNotified.add(element);
          }
        }
      }
      if (sendNotificationTo.isNotEmpty) {
        for (var element in sendNotificationTo) {
          if (element.id != null) {
            usersToBeNotified.add(element.id);
          }
        }
      }
      //remove duplicates
      usersToBeNotified = usersToBeNotified.toSet().toList();
      print(usersToBeNotified);
      for (var element in usersToBeNotified) {
        if (element != null) {
          await notificationService.notifyAboutBeingTagged(
              element, postModel.postId);
        }
      }

      // if (postModel.taggedUsers!.isNotEmpty) {
      //   for (var user in postModel.taggedUsers!) {
      //     await notificationService.notifyAboutBeingTagged(
      //         user!, postModel.postId);
      //   }
      // }
      // if (sendNotificationTo.isNotEmpty) {
      //   for (var user in sendNotificationTo) {
      //     await notificationService.notifyAboutBeingTagged(
      //         user.id!, postModel.postId);
      //   }
      // }
      // addToTimelines(postModel.postId, postModel.ownerId!);
      notificationService.addedANewPostNotification();
      return postModel;
    } on FirebaseException catch (e) {
      Get.snackbar("Error", e.message!, backgroundColor: Colors.white);
      return null;
    }
  }

  Future<bool> addHastagsToPost(String postId, List<String> hashtags) async {
    try {
      hashtags = hashtags.map((e) => e.toLowerCase()).toList();
      await db.postsCollection.doc(postId).update({
        'hashtags': FieldValue.arrayUnion(hashtags),
      });
      for (var element in hashtags) {
        if (element.isValidUsername) {
          await db.hashTagsCollection.doc(element.toLowerCase()).set({
            'id': element.toLowerCase(),
          }, SetOptions(merge: true));
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // addToTimelines(String postId, String ownerId) {
  //   sendToMyTimeline(postId, ownerId);
  //   sendToFollowersTimeline(postId, ownerId);
  // }

  // sendToMyTimeline(String postId, String ownerId) async {
  //   await db.timelinesCollection(userController.userModel.id!).doc(postId).set({
  //     'timestamp': FieldValue.serverTimestamp(),
  //     'ownerId': ownerId,
  //     'visible': true
  //   });
  // }

  sendToFollowersTimeline(String postId, String ownerId) async {
    var list =
        await FollowDatabase().getFollowerList(userController.userModel.id!);
    for (var item in list) {
      await db.timelinesCollection(item).doc(postId).set({
        'timestamp': FieldValue.serverTimestamp(),
        'ownerId': ownerId,
        'visible': true
      });
    }
  }

  var uc = Get.find<UserController>();
  Future<void> sendToChannel(
      PostModel post, String channelType, String channelId,
      {String captionText = ''}) async {
    try {
      //TODO send post to chat
      return;
    } catch (e) {
      return;
    }
  }

  var sfc = Get.put(StreamFeedController());
  Future<bool> deletePost(PostModel postModel) async {
    try {
      if (postModel.ownerId == currentUserUid) {
        await db.postsCollection.doc(postModel.postId).delete();
        await sfc.deletePost(postModel);
        return true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePost(PostModel postModel) async {
    try {
      return true;
    } catch (e) {
      return false;
    }
  }

  var userController = Get.find<UserController>();
  Future<bool> savePost(String postId) async {
    try {
      print('saving post');

      var wb = FirebaseFirestore.instance.batch();
      var liked = await isLiked(postId);
      wb.set(db.savedPosts(userController.currentUid).doc(postId), {
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
        'isPublic': liked
      });
      wb.set(db.postSaves(postId).doc(userController.currentUid), {
        'saver': userController.currentUid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // await db.postSaves(postId).doc(userController.currentUid).set({
      //   'saver': userController.currentUid,
      //   'timestamp': FieldValue.serverTimestamp(),
      // });
      await wb.commit();
      //  sfc.increasePopularity(postId);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unsavePost(String postId) async {
    try {
      print('unsaving post');
      await db.savedPosts(userController.currentUid).doc(postId).delete();
      await db.postSaves(postId).doc(userController.currentUid).delete();
      return true;
    } catch (e) {
      print("Error Updating post");
      print(e);
      return false;
    }
  }

  Future<bool> likePost(String postId) async {
    try {
      await db.likedPosts(userController.currentUid).doc(postId).set({
        'liked': true,
        'id': postId,
      });
      await db.postLikes(postId).doc(userController.currentUid).set({
        'liker': userController.currentUid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      log("increasing popularity of post $postId");
      await db.postsCollection.doc(postId).update({
        'likeCount': FieldValue.increment(1),
        // 'popularity': FieldValue.increment(1)
      });

      return true;
    } catch (e) {
      print("Error Liking post");
      print(e);
      return false;
    }
  }

  Future<bool> unlikePost(String postId) async {
    try {
      await db.likedPosts(userController.currentUid).doc(postId).delete();
      await db.postLikes(postId).doc(userController.currentUid).delete();
      await db.postsCollection.doc(postId).update({
        'likeCount': FieldValue.increment(-1),
        // 'popularity': FieldValue.increment(-1)
      });
      return true;
    } catch (e) {
      print("Error Unliking post");
      print(e);
      return false;
    }
  }

  Query postLikes(String postId) =>
      db.postLikes(postId).orderBy('timestamp', descending: false);

  Future<bool> isPostSaved(String postId) async {
    try {
      var doc =
          await db.savedPosts(userController.currentUid).doc(postId).get();
      if (doc.exists) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleLike(PostModel postModel) async {
    try {
      log("toggling post ${postModel.postId}");
      bool isSaved = await isPostSaved(postModel.postId);
      if (await isLiked(postModel.postId)) {
        // if (postModel.likedBy.contains(currentUserUid)) {
        await unlikePost(postModel.postId);
        //  await sfc.decreasePopularity(postModel.postId);
        if (isSaved) {
          await db
              .savedPosts(userController.currentUid)
              .doc(postModel.postId)
              .update({'isPublic': false});
        }
        return false;
      } else {
        await likePost(postModel.postId);
        //   await sfc.increasePopularity(postModel.postId);
        NotificationService().likedYourPost(postModel);
        if (!isNullOrBlank(postModel.attachedRecipeId!)) {
          var controller = Get.put(RecipeController());
          controller.incrementRecipeLikes(postModel.attachedRecipeId!);
        }
        if (!isNullOrBlank(postModel.attachedWorkoutId!)) {
          var controller = Get.put(WorkoutController());
          controller.incrementWorkoutLikes(postModel.attachedWorkoutId!);
        }
        if (isSaved) {
          await db
              .savedPosts(userController.currentUid)
              .doc(postModel.postId)
              .update({'isPublic': true});
        }
        return true;
      }
    } catch (e) {
      print("Error toggling likes in post");
      print(e);
      rethrow;
    }
  }

  Future<bool> toggleLikeWithInitialState(
      PostModel postModel, bool _isLiked) async {
    try {
      log("toggling post ${postModel.postId}");
      if (_isLiked) {
        // if (postModel.likedBy.contains(currentUserUid)) {
        await unlikePost(postModel.postId);
        // await sfc.decreasePopularity(postModel.postId);
        return false;
      } else {
        await likePost(postModel.postId);
        //   await sfc.increasePopularity(postModel.postId);
        NotificationService().likedYourPost(postModel);
        if (!isNullOrBlank(postModel.attachedRecipeId!)) {
          var controller = Get.put(RecipeController());
          controller.incrementRecipeLikes(postModel.attachedRecipeId!);
        }
        if (!isNullOrBlank(postModel.attachedWorkoutId!)) {
          var controller = Get.put(WorkoutController());
          controller.incrementWorkoutLikes(postModel.attachedWorkoutId!);
        }

        return true;
      }
    } catch (e) {
      print("Error toggling likes in post");
      print(e);
      rethrow;
    }
  }

  Future<bool> toggleSave(PostModel postModel) async {
    try {
      if (await isPostSaved(postModel.postId)) {
        // if (postModel.likedBy.contains(currentUserUid)) {
        print("unsaving");
        await unsavePost(postModel.postId);
        return false;
      } else {
        print("saving");
        await savePost(postModel.postId);

        return true;
      }
    } catch (e) {
      print("Error toggling saves in post");
      print(e);
      rethrow;
    }
  }

  Future<bool> isLiked(String postId) async {
    try {
      var doc = await db.likedPosts(currentUserUid).doc(postId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isSaved(String postId) async {
    try {
      var doc = await db.savedPosts(currentUserUid).doc(postId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  postMenuAction(PostMenuOption userMenuOptions, PostModel post,
      {required Function postActionCallback,
      required VoidCallback onDelete}) async {
    switch (userMenuOptions) {
      case PostMenuOption.Delete:
        {
          Get.defaultDialog(
            title: "Alert!",
            content: Text("Are You Sure?"),
            confirm: TextButton(
                onPressed: () async {
                  await deletePost(post).whenComplete(() => Get.back());
                  onDelete();
                },
                child: Text("Delete", style: TextStyle(color: Colors.red))),
            cancel: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: !Get.isDarkMode ? Colors.black : Colors.white),
                )),
          );
        }
        break;
      case PostMenuOption.Report:
        {
          await reportPost(post);
        }
        break;
      default:
        {}
    }
    postActionCallback();
    return;
  }

  Widget getPaginatedPosts(Query query,
      {Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
          optionalChildBuilder,
      Key? key,
      bool isGrid = false,
      bool showEmpty = false,
      List<String> filterOutList = const [],
      ScrollController? scrollController}) {
    // print("filter out list inside pagination");
    // print(filterOutList);
    return CustomPaginateFirestore(
      key: key,
      physics: BouncingScrollPhysics(),
      onEmpty: Container(),

      // showEmpty
      //     ? Container()
      //     : Center(
      //         child: Text("No Posts"),
      //       ),
      shrinkWrap: true,
      allowImplicitScrolling: true,
      scrollController: scrollController,
      //item builder type is compulsory.
      itemBuilder: optionalChildBuilder ??
          (context, docs, index) {
            Map data = docs[index].data() as Map<String, dynamic>;
            var post = PostModel.fromMap(data as Map<String, dynamic>);

            if (isGrid) {
              if (post.isTextPost)
                return Container(
                  child: Center(child: Text("Text")),
                );
              if (post.videoMode!) return Container();

              // return FutureBuilder(
              //   future: ImagePickerServices.getImageThumbnail(
              //       post.postAttachmentUrl),
              //   builder: (BuildContext context, AsyncSnapshot snapshot) {
              //     if (!snapshot.hasData) return Container();
              //     return Image.file(snapshot.data);
              //   },
              // );
              return Image.network(
                post.postAttachmentUrl!,
                height: Get.width * 0.3,
                width: Get.width * 0.3,
                fit: BoxFit.cover,
              );
            }
            if (filterOutList.isNotEmpty) {
              print("filtering");
              if (filterOutList.contains(post.ownerId)) {
                print("filtered ${post.ownerId}");
                return Container();
              }
            }

            return Container(
              child: PostWidget(
                postModel: post,
                postId: post.postId,
              ),
            );
          },
      // orderBy is compulsory to enable pagination
      query: query,
      //Change types accordingly
      itemBuilderType:
          isGrid ? PaginateBuilderType.gridView : PaginateBuilderType.listView,
      // to fetch real-time data
      isLive: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }

  Stream<LikeData> getLikeData(String postId) {
    return rxDart.CombineLatestStream.combine2<DocumentSnapshot,
            DocumentSnapshot, LikeData>(
        db.postLikes(postId).doc(uc.currentUid).snapshots(),
        db.postsCollection.doc(postId).snapshots(),
        (a, b) => LikeData(
              isLiked: a.exists,
              likeCount: PostModel.fromMap(b.data() as Map<String, dynamic>)
                      .likeCount ??
                  0,
            ));
  }
}

class BuildPostPagination extends StatelessWidget {
  final Query query;
  final Widget Function(BuildContext, List<DocumentSnapshot<Object?>>, int)?
      optionalChildBuilder;
  final bool isGrid;
  final List<String> filterOutList;
  final ScrollController? scrollController;

  const BuildPostPagination(this.query,
      {Key? key,
      this.optionalChildBuilder,
      this.isGrid = false,
      this.filterOutList = const [],
      this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaginateFirestore(
      key: key,
      physics: ClampingScrollPhysics(),
      onEmpty: Center(
        child: Text("No Posts"),
      ),
      shrinkWrap: true,
      allowImplicitScrolling: true,
      scrollController: scrollController,
      //item builder type is compulsory.
      itemBuilder: optionalChildBuilder ??
          (_, docs, index) {
            Map<String, dynamic> data =
                docs[index].data() as Map<String, dynamic>;
            var post = PostModel.fromMap(data);
            if (isGrid) {
              if (post.isTextPost)
                return Container(
                  child: Center(child: Text("Text")),
                );
              if (post.videoMode!) return Container();

              if (filterOutList.isNotEmpty) if (!filterOutList
                  .contains(post.ownerId)) return Container();
              // return FutureBuilder(
              //   future: ImagePickerServices.getImageThumbnail(
              //       post.postAttachmentUrl),
              //   builder: (BuildContext context, AsyncSnapshot snapshot) {
              //     if (!snapshot.hasData) return Container();
              //     return Image.file(snapshot.data);
              //   },
              // );
              return Image.network(
                post.postAttachmentUrl!,
                height: Get.width * 0.3,
                width: Get.width * 0.3,
                fit: BoxFit.cover,
              );
            }
            return Container(
              child: PostWidget(
                postModel: post,
                postId: post.postId,
              ),
            );
          },
      // orderBy is compulsory to enable pagination
      query: query,
      //Change types accordingly
      itemBuilderType:
          isGrid ? PaginateBuilderType.gridView : PaginateBuilderType.listView,
      // to fetch real-time data
      isLive: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
    );
  }
}
