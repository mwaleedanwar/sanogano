import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import algoliasearch from "algoliasearch";
import { DocumentSnapshot } from "firebase-functions/v1/firestore";
const algolia = algoliasearch('RDQMDZX2JA', '9902893bb529f2f83ae44a44609c592a');

const userIndex = algolia.initIndex('USERS');
var userCollection = admin.firestore().collection('users');

import * as stream from 'getstream';
const streamClient = stream.connect(
  'g7auprpewf5u',
  '2p78kgxudrrkgxd963zwvf3ng4kjhckrfzt4eatukrfjzjasp4t37pw263k4fm6k'
);

async function fetchFriends(followerID: string,): Promise<Array<DocumentSnapshot>> {
  var friends = await admin.firestore().collection('following').doc(followerID).collection('u_following').where('isFriend', "==", true).get();
  return friends.docs;
}
async function isFollowed(followerID: string, followedID: string): Promise<boolean> {
  var doc = await admin.firestore().collection('following').doc(followerID).collection('u_following').doc(followedID).get();
  return doc.exists;
}

exports.onUserFollowed = functions.firestore// this function
  .document('following/{followerID}/u_following/{followedID}')
  .onCreate(async (snap, context) => {
    var followerID = context.params.followerID;
    var followedID = context.params.followedID;
    var isFriend = await isFollowed(followedID, followerID);
    console.log("IS FRIEND FOR Follower" + followerID + " Followed " + followedID + " " + isFriend);
    var targetUser = context.params.followedID;
    if (isFriend) {//oops
      await snap.ref.update({ 'isFriend': true });
      await admin.firestore().collection('following').doc(followedID).collection('u_following').doc(followerID).update({ 'isFriend': true });
      await streamClient.feed('friends', followerID).follow('user', followedID);
      var followerFriends = await fetchFriends(context.params.followerID);
      var followedFriends = await fetchFriends(context.params.followedID);
      // follwerFriends that are not followed by followedID
      var followerFriendsNotFollowed = followerFriends.filter(friend => !followedFriends.some(f => f.id === friend.id));
      const batch = admin.firestore().batch();
      for (let index = 0; index < ((followerFriendsNotFollowed.length > 5) ? 5 : followerFriendsNotFollowed.length); index++) {
        const element = followerFriendsNotFollowed[index];
        var ref = userCollection.doc(targetUser).collection("/suggestions").doc(element.id);
        batch.set(ref, { 'suggested': true, 'suggestedBy': context.params.followerID, 'suggestedAt': admin.firestore.FieldValue.serverTimestamp() });

      }
      await batch.commit();

    }


  });

exports.onUserUnfollowed = functions.firestore
  .document('following/{followerID}/u_following/{followedID}')
  .onDelete(async (snap, context) => {
    var followerID = context.params.followerID;
    var followedID = context.params.followedID;
    await streamClient.feed('friends', followerID).unfollow('user', followedID);
    // await  admin.firestore().doc("following/"+context.params.followedID+"/u_following/"+context.params.followerID).delete();
    // TODO suspecting stack overflow here, 


  });


//store chat token when user created
exports.onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {


  });

exports.onUserUpdated = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (snap, context) => {


    var necessaryData = {

      image: snap.after.data().profileURL, name: snap.after.data().name, username: snap.after.data().username,
    };

    await streamClient.user(snap.after.id).update(necessaryData);


  });


exports.onUserDeleted = functions.firestore
  .document('users/{userID}')
  .onDelete(async (snap, context) => {
    // Get an object representing the document prior to deletion
    // e.g. {'name': 'Marie', 'age': 66}
    await userIndex.deleteObject(snap.id);
    return;


    // perform desired operations ...
  });


exports.createUserToken = functions.https.onCall(async (data, context) => {
  var uid = data.uid;
  const userToken = streamClient.createUserToken(uid);
  await admin.firestore().collection('users').doc(uid).update({ 'chatToken': userToken, 'feedToken': userToken, });
  return userToken;
});


exports.getMutualFriends = functions.https.onCall(async (data, context) => {
  try {
    var uid = data.uid;
    var friends = await fetchFriends(uid);
    var myFriends = await fetchFriends(context.auth.uid);
    var mutualFriends = friends.filter(friend => myFriends.some(f => f.id === friend.id));

    return mutualFriends;
  } catch (error) {
    return [];

  }
});

exports.fetchRelationship = functions.https.onCall(async (data, context) => {
  try {
    var uid = data.uid;

    var following = await admin.firestore().collection('following').doc(context.auth.uid).collection('u_following').doc(uid).get();
    var isCurrentUserFollowingOtherUser = following.exists;
    var isCurrentUserFriendsWithOtherUser = isCurrentUserFollowingOtherUser ? following.data().isFriend : false;
    var otherUserFollowers = admin.firestore()
      .collection("followers")
      .doc(uid)
      .collection("u_followers")
      .get();
    var followerCount = (await otherUserFollowers).docs.length;

    return {
      'areFriends': isCurrentUserFriendsWithOtherUser,
      'isFollowing': isCurrentUserFollowingOtherUser,
      'otherUserFollowers': followerCount,
    };
  } catch (error) {
    return {};

  }
});


exports.addUserToFirestore = functions.auth.user().onCreate(async (user) => {
  const userToken = streamClient.createUserToken(user.uid);
  await userCollection.doc(user.uid).set({
    'chatToken': userToken, 'feedToken': userToken, 'id': user.uid, 'email': user.email,
  }, { merge: true });
  await streamClient.feed('grand', 'US').follow('user', user.uid);
  return;
});// this is where it is created with token,got it