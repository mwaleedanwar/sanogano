import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

var postCollection= admin.firestore().collection('posts');

exports.onSavedPostCreated = functions.firestore
.document('/users/{userId}/savedPosts/{postId}')
.onCreate(async (snap, context) => {
    await postCollection.doc(context.params.postId).update({ 'saveCount': admin.firestore.FieldValue.increment(1) });
});

exports.onSavedPostDeleted = functions.firestore
.document('/users/{userId}/savedPosts/{postId}')
.onDelete(async (snap, context) => {
    await postCollection.doc(context.params.postId).update({ 'saveCount': admin.firestore.FieldValue.increment(-1) });
});