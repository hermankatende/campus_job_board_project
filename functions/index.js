// /**
//  * Import function triggers from their respective submodules:
//  *
//  * const {onCall} = require("firebase-functions/v2/https");
//  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
//  *
//  * See a full list of supported triggers at https://firebase.google.com/docs/functions
//  */
// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// // Example function
// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

// // Create and deploy your first functions
// // https://firebase.google.com/docs/functions/get-started

// // exports.helloWorld = onRequest((request, response) => {
// //   logger.info("Hello logs!", {structuredData: true});
// //   response.send("Hello from Firebase!");
// // });
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendJobNotification = functions.firestore
    .document('jobs/{jobId}')
    .onCreate(async (snap, context) => {
        const job = snap.data();
        const jobCategory = job.category;

        const usersRef = admin.firestore().collection('users');
        const usersSnapshot = await usersRef
            .where('subscriptions', 'array-contains', jobCategory)
            .get();

        const tokens = [];
        usersSnapshot.forEach(doc => {
            const user = doc.data();
            if (user.fcmToken) {
                tokens.push(user.fcmToken);
            }
        });

        const payload = {
            notification: {
                title: 'New Job Posted',
                body: `A new ${jobCategory} job has been posted.`,
            },
        };

        if (tokens.length > 0) {
            await admin.messaging().sendToDevice(tokens, payload);
        }
    });

// HTTP-triggered function for testing
exports.testSendJobNotification = functions.https.onRequest(async (req, res) => {
    const testPayload = { data: { category: 'IT' } };
    const context = { params: { jobId: 'sampleJob' } };
    try {
        await exports.sendJobNotification(testPayload, context);
        res.send('Notification sent successfully.');
    } catch (error) {
        console.error('Function error:', error);
        res.status(500).send('Function error: ' + error);
    }
});
