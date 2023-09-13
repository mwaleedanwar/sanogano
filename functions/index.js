const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const algoliasearch = require('algoliasearch');

const algolia = algoliasearch('0GMU7W6FWU', '19706199dc7fb6b22867a64b249f40b8');
const recipeIndex = algolia.initIndex('Recipes');
const workoutIndex = algolia.initIndex('Workouts');
const userIndex = algolia.initIndex('Users');

const firestore = admin.firestore();
const settings = { timestampInSnapshots: true };
firestore.settings(settings)



const stream = require('getstream');
const client = stream.connect(
    'g7auprpewf5u',
    '2p78kgxudrrkgxd963zwvf3ng4kjhckrfzt4eatukrfjzjasp4t37pw263k4fm6k'
);



exports.sendNotificationToIndividual = functions.https.onCall(async (request, response) => {
    const tokensdoc = await admin.firestore().collection('users').doc(request.uid).get();
    let body;
    let title;

    title = request.alertHeading;
    body = request.alertMessage;

    const payload = {
        'notification': {
            'body': body,
            'clickAction': 'FLUTTER_NOTIFICATION_CLICK',
            'title': title,
            // "imageUrl": "https://my-cdn.com/extreme-weather.png",
            'sound': 'default'
        },
        "data": {
            "alertID": request.alertID,
        }
    };

    try {
        admin.messaging().sendToDevice(tokensdoc.data().androidNotificationToken, payload);
        return true;
    } catch (e) {
        console.log(e);
        return false;
    }



});
exports.disableUser = functions.https.onCall(async (request, response) => {
    try {
        await admin.auth().updateUser(request.uid, { disabled: true });
        return true;
    } catch (e) {
        console.log(e);
        return false;
    }
});

exports.sendNotificationToList = functions.https.onCall(async (request, response) => {
    let body;
    let title;

    title = request.alertHeading;
    body = request.alertMessage;

    const payload = {
        'notification': {
            'body': body,
            'clickAction': 'FLUTTER_NOTIFICATION_CLICK',
            'title': title,
            // "imageUrl": "https://my-cdn.com/extreme-weather.png",
            'sound': 'default'
        },
        "data": {
            "alertID": request.alertID,
        }
    };

    try {
        admin.messaging().sendToDevice(request.uid, payload);
        return true;
    } catch (e) {
        console.log(e);
        return false;
    }



});



//store chat token when user created
exports.onUserCreated = functions.firestore
    .document('users/{userId}')
    .onCreate(async (snap, context) => {
        
        var user = snap.data();
        const uid = snap.id;
        const userToken = client.createUserToken(uid);
        
        await admin.auth().setCustomUserClaims(uid, {'streamToken': userToken});
        await snap.ref.update({ 'chatToken': userToken, 'feedToken': userToken,  });


    });



    exports.onUserUpdated = functions.firestore
    .document('users/{userId}')
    .onUpdate(async (snap, context) => {
    var data=snap.after.data();
    
    var necessaryData={
        
        image: snap.after.data().profileURL, name: snap.after.data().name, username: snap.after.data().username,};
        
       await client.user(snap.id).update(necessaryData);


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


    exports.onRecipeDeleted = functions.firestore
    .document('users/{userID}/recipes/{recipeID}')
    .onDelete(async (snap, context) => {
        await recipeIndex.deleteObject(snap.id);
        return;
    });


    exports.onWorkoutDeleted = functions.firestore
    .document('users/{userID}/workouts/{workoutID}')
    .onDelete(async (snap, context) => {
      // Get an object representing the document prior to deletion
      // e.g. {'name': 'Marie', 'age': 66}
      await workoutIndex.deleteObject(snap.id);
        return;

      // perform desired operations ...
    });



// exports.onLikeCreated = functions.firestore
//     .document('posts/{postId}/likes/{likeId}')
//     .onCreate(async (snap, context) => {
//         try {
//             var feed=  client.feed('timeline', snap.data().liker);
//             var post=await admin.firestore().collection('posts').doc(context.params.postId).get();
//             var popularity=post.data().popularity;
//            await client.activityPartialUpdate({
//              id: context.params.postId,
//              set: {
//                  'popularity': popularity+1
//              },
//              unset: [
              
//              ]
//            })
//         } catch (error) {
//             console.log(error);
//         }
            
        
      
      
//      })

// // exports.onLikeDeleted = functions.firestore
// //     .document('posts/{postId}/likes/{likeId}')
// //     .onDelete(async (snap, context) => {
    
// //         try {
// //             var feed=  client.feed('timeline', snap.data().liker);
           
// //             var post=await admin.firestore().collection('posts').doc(context.params.postId).get();
// //             var popularity=post.data().popularity;
// //             await client.activityPartialUpdate({
// //              id: context.params.postId,
// //              set: {
// //                  'popularity': popularity-1
// //              },
// //              unset: [
              
// //              ]
// //            })
// //         } catch (error) {
// //             console.log(error);
// //         }
            
        
       
// //      })
