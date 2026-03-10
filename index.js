const express = require('express');
const functions = require('firebase-functions');
const admin = require('firebase-admin');
const { PubSub } = require('@google-cloud/pubsub');

const serviceAccount = require('C:/Users/hp/Desktop/Rani/cjb/service-account-file.json'); // Update this path

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const pubsub = new PubSub();
const app = express();
const PORT = process.env.PORT || 3000;

// Define your endpoint to handle incoming requests if needed
app.get('/', (req, res) => {
  res.send('Server is running!');
});

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});

// Firebase Cloud Function to handle Pub/Sub messages
exports.handlePubSubMessage = functions.pubsub.topic('job-notifications').onPublish(async (message) => {
  console.log(`Received message ${message.id}:`);
  console.log(`Data: ${message.json}`);
  console.log(`Attributes: ${message.attributes}`);

  const data = message.json;

  const payload = {
    notification: {
      title: 'New Job Posted!',
      body: `${data.title} in ${data.category} category`,
      sound: 'default',
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      message: `${data.title} in ${data.category} category`,
    },
  };

  try {
    const response = await admin.messaging().sendToTopic(data.category, payload);
    console.log('Successfully sent message:', response);
  } catch (error) {
    console.log('Error sending message:', error);
  }
});
