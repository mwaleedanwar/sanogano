const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

const firestore = admin.firestore();
const settings = { timestampInSnapshots: true };
firestore.settings(settings)


import * as moduleFunctions from "./modules/modules_functions";

exports.sanogano = moduleFunctions;



  




    