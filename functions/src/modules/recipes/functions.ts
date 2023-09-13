


// import algoliasearch from "algoliasearch";
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
// const algolia = algoliasearch('RDQMDZX2JA', '9902893bb529f2f83ae44a44609c592a');
// const recipeIndex = algolia.initIndex('Recipes');
var userCollection = admin.firestore().collection('users');

// async function getARecipe(recipeID: string): Promise<FirebaseFirestore.DocumentData> {
//   var recipe =await admin.firestore().collectionGroup('recipes').where('recipeId',"==", recipeID).limit(1).get();
//   return recipe.docs[0].data();
// }


exports.onRecipeSaved = functions.firestore
  .document('users/{userID}/savedRecipes/{recipeID}')
  .onCreate(async (snap, context) => {
    var data = snap.data();
    var ownedId = data.ownerId;
    var recipeId = context.params.recipeID;
    await admin.firestore().collection('users').doc(ownedId).collection('recipes').doc(context.params.recipeID).update({ 'saveCount': admin.firestore.FieldValue.increment(1) });
    var recentSearchesWithThisRecipe = await admin.firestore().collectionGroup('recentSearches').where('id', "==", recipeId).get();

    for (let index = 0; index < recentSearchesWithThisRecipe.docs.length; index++) {
      const element = recentSearchesWithThisRecipe.docs[index];
      await element.ref.update({ 'snapshotJson.saveCount': admin.firestore.FieldValue.increment(1) });
    }
  });


exports.onRecipeUnsaved = functions.firestore
  .document('users/{userID}/savedRecipes/{recipeID}')
  .onDelete(async (snap, context) => {
    var data = snap.data();
    var ownedId = data.ownerId;
    var recipeId = context.params.recipeID;
    await admin.firestore().collection('users').doc(ownedId).collection('recipes').doc(context.params.recipeID).update({ 'saveCount': admin.firestore.FieldValue.increment(-1) });
    var recentSearchesWithThisRecipe = await admin.firestore().collectionGroup('recentSearches').where('id', "==", recipeId).get();

    for (let index = 0; index < recentSearchesWithThisRecipe.docs.length; index++) {
      const element = recentSearchesWithThisRecipe.docs[index];
      await element.ref.update({ 'snapshotJson.saveCount': admin.firestore.FieldValue.increment(-1) });
    }
  });




exports.saveAllRecipes = functions.https.onCall(async (data, context) => {
  var ownerId = data.ownerId;
  var recipes = await userCollection.doc(ownerId).collection('recipes').where('ownerId', "==", ownerId).get();
  for (let index = 0; index < recipes.docs.length; index++) {
    const element = recipes.docs[index];
    let data = element.data();
    data.createdOn = admin.firestore.FieldValue.serverTimestamp();
    await admin.firestore().collection('users').doc(ownerId).collection('recipes').doc(element.id).update({ 'saveCount': admin.firestore.FieldValue.increment(1) });

    await userCollection.doc(context.auth.uid).collection('savedRecipes').doc(element.id).set({
      'recipeId': element.id,
      'timestamp': admin.firestore.FieldValue.serverTimestamp(),

      'ownerId': ownerId,
    });

  }
  return;
});


exports.onRecipeUpdated = functions.firestore
  .document('users/{userID}/recipes/{recipeID}')
  .onUpdate(async (snap, context) => {
    var recipeId = context.params.recipeID;
    var savedRecipes = await admin.firestore().collectionGroup('recipes').where('recipeId', "==", recipeId).get();
    for (let index = 0; index < savedRecipes.docs.length; index++) {
      const element = savedRecipes.docs[index];
      await element.ref.update(snap.after.data());

    }

    var recentSearchesWithThisRecipe = await admin.firestore().collectionGroup('recentSearches').where('id', "==", recipeId).get();

    for (let index = 0; index < recentSearchesWithThisRecipe.docs.length; index++) {
      const element = recentSearchesWithThisRecipe.docs[index];
      await element.ref.update({ 'snapshotJson': snap.after.data() });
    }
  });



exports.onRecipeDeleted = functions.firestore
  .document('users/{userID}/recipes/{recipeID}')
  .onDelete(async (snap, context) => {
    try {
      var recipeId = context.params.recipeID;
      var savedRecipes = await admin.firestore().collectionGroup('savedRecipes').where('recipeId', "==", recipeId).get();
      for (let index = 0; index < savedRecipes.docs.length; index++) {
        const element = savedRecipes.docs[index];
        await element.ref.delete();

      }
      var postsWithThisRecipe = await admin.firestore().collection('posts').where('attachedRecipeId', "==", recipeId).get();
      for (let index = 0; index < postsWithThisRecipe.docs.length; index++) {
        const element = postsWithThisRecipe.docs[index];
        await element.ref.update({ 'attachedRecipeId': '' });

      }
      var recentSearchesWithThisRecipe = await admin.firestore().collectionGroup('recentSearches').where('id', "==", recipeId).get();
      for (let index = 0; index < recentSearchesWithThisRecipe.docs.length; index++) {
        const element = recentSearchesWithThisRecipe.docs[index];
        await element.ref.delete();

      }
    } catch (error) {
      console.log(error);
    }

  });