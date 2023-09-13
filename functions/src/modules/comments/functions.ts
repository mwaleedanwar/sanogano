import * as functions from "firebase-functions";
import * as admin from "firebase-admin";



exports.onCommentCreated = functions.firestore
    .document('posts/{postId}/comments/{commentId}')
    .onCreate(async (snap, context) => {
        var isReply = snap.data().isReply as boolean;
        var postId = context.params.postId;
        if (isReply) {

        } else {
            admin.firestore().collection('posts').doc(postId).update({
                'commentCount': admin.firestore.FieldValue.increment(1),
                'commulativeCommentCount': admin.firestore.FieldValue.increment(1),
                'popularity': admin.firestore.FieldValue.increment(1)
            });
        }

    });


exports.onCommentDeleted = functions.firestore
    .document('posts/{postId}/comments/{commentId}')
    .onDelete(async (snap, context) => {
        var isReply = snap.data().isReply as boolean;
        var postId = context.params.postId;
        var replyCount = snap.data().replyCount as number;
        if (isReply) {

        } else {
            admin.firestore().collection('posts').doc(postId).update({
                'commentCount': admin.firestore.FieldValue.increment(-1),
                'commulativeCommentCount': admin.firestore.FieldValue.increment(-(replyCount + 1))
            });
        }

    });




exports.onReplyCreated = functions.firestore
    .document('posts/{postId}/comments/{commentId}/replies/{replyId}')
    .onCreate(async (snap, context) => {
        var isReply = snap.data().isReply as boolean;
        var postId = context.params.postId;
        if (isReply) {
            admin.firestore().collection('posts').doc(postId).update({
                'replyCount': admin.firestore.FieldValue.increment(1),
                'commulativeCommentCount': admin.firestore.FieldValue.increment(1),
                'popularity': admin.firestore.FieldValue.increment(1)
            });
        } else {

        }

    });


exports.onReplyDeleted = functions.firestore
    .document('posts/{postId}/comments/{commentId}/replies/{replyId}')
    .onDelete(async (snap, context) => {
        var isReply = snap.data().isReply as boolean;
        var postId = context.params.postId;
        if (isReply) {
            admin.firestore().collection('posts').doc(postId).update({
                'replyCount': admin.firestore.FieldValue.increment(-1),
                'commulativeCommentCount': admin.firestore.FieldValue.increment(-1)
            });
            admin.firestore().collection('posts').doc(postId).collection('comments').doc(context.params.commentId).update({
                'replyCount': admin.firestore.FieldValue.increment(-1)
            });
        } else {

        }

    });

