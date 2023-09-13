import * as functions from 'firebase-functions';
// import algoliasearch from 'algoliasearch';
import * as admin from 'firebase-admin';

// const algolia = algoliasearch('RDQMDZX2JA', '9902893bb529f2f83ae44a44609c592a');

// const workoutIndex = algolia.initIndex('Workouts');

exports.onWorkoutDeleted = functions.firestore
  .document('users/{userID}/workouts/{workoutID}')
  .onDelete(async (snap, context) => {
    try {
      var workoutId = context.params.workoutID;
      var savedWorkouts = await admin.firestore().collectionGroup('savedWorkouts').where('workoutId', "==", workoutId).get();
      for (let index = 0; index < savedWorkouts.docs.length; index++) {
        const element = savedWorkouts.docs[index];
        await element.ref.delete();

      }
      var postsWithThisWorkout = await admin.firestore().collection('posts').where('attachedWorkoutId', "==", workoutId).get();
      for (let index = 0; index < postsWithThisWorkout.docs.length; index++) {
        const element = postsWithThisWorkout.docs[index];
        await element.ref.update({ 'attachedWorkoutId': '' });

      }
      var recentSearchesWithThisWorkout = await admin.firestore().collectionGroup('recentSearches').where('id', "==", workoutId).get();
      for (let index = 0; index < recentSearchesWithThisWorkout.docs.length; index++) {
        const element = recentSearchesWithThisWorkout.docs[index];
        await element.ref.delete();

      }
    } catch (error) {
      console.log(error);
    }

  });


exports.onWorkoutUpdated = functions.firestore
  .document('users/{userID}/workouts/{workoutID}')
  .onUpdate(async (snap, context) => {
    var workoutId = context.params.workoutID;
    var savedWorkouts = await admin.firestore().collectionGroup('workouts').where('workoutId', "==", workoutId).get();
    for (let index = 0; index < savedWorkouts.docs.length; index++) {
      const element = savedWorkouts.docs[index];
      await element.ref.update(snap.after.data());

    }

    var recentSearchesWithThisWorkouts = await admin.firestore().collectionGroup('recentSearches').where('id', "==", workoutId).get();

    for (let index = 0; index < recentSearchesWithThisWorkouts.docs.length; index++) {
      const element = recentSearchesWithThisWorkouts.docs[index];
      await element.ref.update({ 'snapshotJson': snap.after.data() });
    }
  });



exports.onWorkoutSaved = functions.firestore
  .document('users/{userID}/savedWorkouts/{workoutID}')
  .onCreate(async (snap, context) => {
    var data = snap.data();
    var ownerId = data.ownerId;
    var workoutId = context.params.workoutID;
    await admin.firestore().collection('users').doc(ownerId).collection('workouts').doc(context.params.workoutID).update({ 'saveCount': admin.firestore.FieldValue.increment(1) });
    var recentSearchesWithThisWorkouts = await admin.firestore().collectionGroup('recentSearches').where('id', "==", workoutId).get();

    for (let index = 0; index < recentSearchesWithThisWorkouts.docs.length; index++) {
      const element = recentSearchesWithThisWorkouts.docs[index];
      await element.ref.update({ 'snapshotJson.saveCount': admin.firestore.FieldValue.increment(1) });
    }
  });


exports.onWorkoutUnsaved = functions.firestore
  .document('users/{userID}/savedWorkouts/{workoutID}')
  .onDelete(async (snap, context) => {
    var data = snap.data();
    var ownerId = data.ownerId;
    var workoutId = context.params.workoutID;
    await admin.firestore().collection('users').doc(ownerId).collection('workouts').doc(context.params.workoutID).update({ 'saveCount': admin.firestore.FieldValue.increment(-1) });
    var recentSearchesWithThisWorkouts = await admin.firestore().collectionGroup('recentSearches').where('id', "==", workoutId).get();

    for (let index = 0; index < recentSearchesWithThisWorkouts.docs.length; index++) {
      const element = recentSearchesWithThisWorkouts.docs[index];
      await element.ref.update({ 'snapshotJson.saveCount': admin.firestore.FieldValue.increment(-1) });
    }
  });
