import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

exports.streamFeedWebhook = functions.https.onRequest(async (req, res) => {
  await admin.firestore().collection('streamfeedevents').add({ 'events': req.body });
  res.send('All OK');
});



exports.onPostCreatedToStream = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    var post = snap.data();
    var ownerId = post.ownerId;
    var postId = snap.id;

    await admin.firestore().doc(`/feeds/user/${ownerId}/${postId}`).set(post);
  });

exports.onPostDeletedToStream = functions.firestore
  .document('posts/{postId}')
  .onDelete(async (snap, context) => {
    var post = snap.data();
    var ownerId = post.ownerId;
    var postId = snap.id;

    await admin.firestore().doc(`/feeds/user/${ownerId}/${postId}`).delete();
  });


exports.onPostUpdatedToStream = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (snap, context) => {
    var post = snap.after.data();
    var ownerId = post.ownerId;
    var postId = snap.after.id;

    if (post.likeCount > snap.before.data().likeCount) {
      post.popularity = post.popularity + 1;
    }



    await admin.firestore().doc(`/feeds/user/${ownerId}/${postId}`).update(post);
    await admin.firestore().collection('posts').doc(postId).update({ 'popularity': post.popularity });
  });  