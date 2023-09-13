import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:sano_gano/controllers/auth_controller.dart';
import 'package:sano_gano/controllers/postController.dart';
import 'package:sano_gano/controllers/stream_feed_controller.dart';
import 'package:sano_gano/controllers/user_controller.dart';
import 'package:sano_gano/models/commentModel.dart';
import 'package:sano_gano/models/postmodel.dart';
import 'package:sano_gano/services/notificationService.dart';
import 'package:sano_gano/utils/database.dart';
import 'dart:developer' as dev;

class CommentsController extends GetxController {
  var db = Database();
  var currentUser = Get.find<UserController>().userModel;

  Future<CommentModel?> getComment(String commentId, String postId) async {
    var comment = await db.commentsCollection(postId).doc(commentId).get();
    if (comment.exists) {
      return CommentModel.fromFirestore(comment);
    } else {
      return null;
    }
  }

  bool isMyComment(CommentModel comment) =>
      comment.commenterId == currentUser.id;

  Future<CommentModel?> getPinnedComment(
    String postID,
  ) async {
    try {
      var postDoc = await db.postsCollection.doc(postID).get();
      var post = PostModel.fromMap(postDoc.data() as Map<String, dynamic>);
      if (post.pinnedCommentID!.isEmpty) {
        return null;
      }

      var doc =
          await db.commentsCollection(postID).doc(post.pinnedCommentID).get();
      return CommentModel.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> userCommentStream(
          String postID) =>
      db
          .commentsCollection(postID)
          .where('commenterId', isEqualTo: Get.find<AuthController>().user!.uid)
          .orderBy('timestamp')
          .snapshots() as Stream<QuerySnapshot<Map<String, dynamic>>>;

  Future<bool> isLiked(String commentId) async {
    try {
      var doc = await db.likedComments(currentUser.id!).doc(commentId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleLike(CommentModel commentModel) async {
    try {
      if (await isLiked(commentModel.id!)) {
        // if (postModel.likedBy.contains(currentUserUid)) {
        await unlikeComment(commentModel);
        return false;
      } else {
        await likeComment(commentModel);
        //TODO TRIGGER COMMENT LIKES
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> likeComment(CommentModel commentModel) async {
    try {
      await db.likedComments(currentUser.id!).doc(commentModel.id).set({
        'liked': true,
        'id': commentModel.id,
      });
      await commentModel.ref!.collection('likedBy').doc(currentUser.id).set({
        'liked': true,
        'id': commentModel.id,
        'timestamp': FieldValue.serverTimestamp()
      });
      await commentModel.ref!.update({'commentLikes': FieldValue.increment(1)});

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> unlikeComment(CommentModel commentModel) async {
    try {
      await db.likedComments(currentUser.id!).doc(commentModel.id).delete();
      await commentModel.ref!
          .collection('likedBy')
          .doc(currentUser.id)
          .delete();
      await commentModel.ref!
          .update({'commentLikes': FieldValue.increment(-1)});
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> commentCount(
    String postId,
  ) async {
    try {
      var postDoc = await db.postsCollection.doc(postId).get();
      var post = PostModel.fromMap(postDoc.data() as Map<String, dynamic>);
      return post.commentCount!;
    } catch (e) {
      return 0;
    }
  }

  // Stream<int> commentCountStream(
  //   String postId,
  // ) {
  //   return db.postsCollection.doc(postId).snapshots().map((event) {
  //     return PostModel.fromMap(event.data() as Map<String, dynamic>)
  //         .commentCount!;
  //   });
  // }

  Stream<int> repliesCount(
    String postId,
    String commentId,
  ) {
    return db
        .commentsCollection(postId)
        .doc(commentId)
        .collection('replies')
        .snapshots()
        .map((event) {
      return event.docs.length;
    });
    // var commentDoc = await db
    //     .commentsCollection(postId)
    //     .doc(commentId)
    //     .collection('replies')
    //     .get();
    // return commentDoc.docs.length;
  }

  Stream<int> totalCommentCount(
    String postId,
  ) {
    return db.postsCollection.doc(postId).snapshots().map((event) {
      return PostModel.fromMap(event.data() as Map<String, dynamic>)
              .totalCommentCount ??
          0;
    });
    // try {
    //   var postDoc = await db.postsCollection.doc(postId).get();
    //   var post = PostModel.fromMap(postDoc.data() as Map<String, dynamic>);

    //   return post.totalCommentCount!;
    // } catch (e) {
    //   return 0;
    // }
  }

  var sfc = Get.find<StreamFeedController>();
  Stream<int> commentCountStream(postId) =>
      db.commentsCollection(postId).snapshots().map((event) {
        return event.docs.length;
      });
  Future<bool> postComment(
    String postId,
    String commentText, {
    List<String> taggedIds = const [],
    Map<String, dynamic>? taggedUsersIdandUsersName,
  }) async {
    try {
      dev.log(taggedIds.toString());

      var commentModel = CommentModel(
          commentLikes: 0,
          commentText: commentText,
          commentorName: currentUser.username,
          commenterId: currentUser.id,
          isReply: false,
          likedBy: [],
          taggedUsersIdandUsername: taggedUsersIdandUsersName,
          postId: postId,
          replyCount: 0,
          timestamp: DateTime.now());
      var doc = db.commentsCollection(postId).doc();
      commentModel.id = doc.id;
      NotificationService().notifyNewComment(postId, commentModel);
      await doc.set(commentModel.toMap());

      if (commentModel.hashtags.isNotEmpty) {
        var pc = Get.put(PostController());
        await pc.addHastagsToPost(postId, commentModel.hashtags);
      }
      for (var element in taggedIds.toSet().toList()) {
        NotificationService()
            .notifyAboutBeingTaggedInComment(element, commentModel.id!, postId);
      }
      var uc = Get.find<UserController>();
      uc.addComment(postId);

      //  await sfc.increasePopularity(postId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> postAReplyComment(CommentModel commentModel, String replyText,
      {List<String> taggedIds = const [],
      Map<String, dynamic>? taggedUsersIdandUsersName}) async {
    try {
      var doc = commentModel.repliesRef.doc();
      var reply = CommentModel(
          commentLikes: 0,
          commentText: replyText,
          commentorName: currentUser.username,
          commenterId: currentUser.id,
          isReply: true,
          likedBy: [],
          taggedUsersIdandUsername: taggedUsersIdandUsersName,
          postId: commentModel.postId,
          replyCount: 0,
          timestamp: DateTime.now());
      reply.id = doc.id;
      reply.isReply = true;
      NotificationService()
          .notifyNewReply(commentModel.postId!, commentModel, reply);
      await doc.set(reply.toMap());
      await db.postsCollection
          .doc(commentModel.postId)
          .update({'totalCommentCount': FieldValue.increment(1)});
      await commentModel.commentRef
          .update({'replyCount': FieldValue.increment(1)});
      // for (var element in taggedIds) {
      //   NotificationService().notifyAboutBeingTaggedInComment(
      //       element, commentModel.id!, commentModel.postId!,
      //       isReply: true);
      // }
      var uc = Get.find<UserController>();
      uc.addComment(commentModel.postId!);
      if (commentModel.hashtags.isNotEmpty) {
        var pc = Get.put(PostController());
        await pc.addHastagsToPost(commentModel.postId!, reply.hashtags);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> reportComment(CommentModel commentModel) async {
    try {
      String? id = await Database().getUserIdFromEmail("support@sanogano.com");

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteComment(
      String postId, CommentModel commentModel, int replyCount) async {
    try {
      var batch = FirebaseFirestore.instance.batch();
      batch.delete(commentModel.ref!);
      var uc = Get.find<UserController>();
      uc.removeComment(commentModel.postId!);

      await batch.commit();
      // await commentModel.ref.delete();
      // await db.postsCollection
      //     .doc(postId)
      //     .update({'commentCount': FieldValue.increment(-(replyCount + 1))});
      return true;
    } catch (e) {
      return false;
    }
  }
}
