// import 'dart:convert';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:googleapis/pubsub/v1.dart' as pubsub;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'package:http/http.dart' as http;

// class FirestoreService {
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   // Pub/Sub configuration
//   final String _projectId = 'cjb-app-429507';
//   final String _subscriptionName = 'your-subscription-name';
//   final String _topicName =
//       'projects/your-google-cloud-project-id/topics/your-topic-name';

//   // Google Cloud Pub/Sub client
//   late final pubsub.PubsubApi _pubsub;

//   FirestoreService() {
//     _initializePubSub();
//   }

//   // Initialize Google Cloud Pub/Sub
//   Future<void> _initializePubSub() async {
//     final accountCredentials = auth.ServiceAccountCredentials.fromJson({
//       "private_key_id": "5227f53f061197870e1f5eefce566b306beed313",
//       "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDJXZ24g1LzQMx6\n5kQZvbOhsp7nOJw0i02FaoXULsNQ30mEuPSdq++/Khj7IonGeGYCoKqVDH0l7V67\nsIrDE+i3L8sUvqOkvx774whUU2ND4/Sef7QKSFMg9Jdbm3EsOJlEqrVZiAtQC6Bw\n9FstJgkKDWUNRm+0DUjauJIDT8lRi6bQadM2C07mqUni+vNxT7D3cAEx/vfIJWyh\nhv7pFd99eVmbdihbWUITA495UMYB9ZPWC5y0g13J35uUpi2yjxMA5uWfeE/s9iKZ\ngW96P7x2GFHh+KIvscmlR/VoZiwx3LsPNrg9Rpp8BsB1QuZo9xMlcm+/xUefOQ8P\nsmY14OZZAgMBAAECggEAEOmwhB1fm7fPFOl/Qcw5qLSofRI3qIAkyDZsvCgbVpES\nize/r/iPf/Zot7ssaEOXidP1z+QHJObdhJUs6nqjGrPEcl8avo0g7JYijnaciUi9\ntIxUUmLFvKheiB6zsDumv+o4pibzkEsRtDsJ525g5vu+B5Hpcu2Et342IVoTtioG\n5gsS/r2LAt5bTF2PYgs5YD2N0KwY2gxEDef7eMIXkWXR/ukvyboa6INjB04SwqrD\nM8m93M0vP2hQraBNt7o4xuKd7InqOvJCfDDxzYK/GCY9vZP2eXpOj6LfGF++5tWR\n6vDV7pM0UNqQSQ8DoRBtjEd3vDQXbZbRNcm7X0eKWwKBgQDyNjwEtOWOLhwgSecg\nmYal0arPu8ZpgKO4RDuu+ZxoRJBlf+Gy8TkOxsGceLW4/LsLw3WhVIUCb1lnyqeg\nUDiprnvL1yqKiZkw6ioN3dC9drV9tt/czNyacwYCvfRCQCX6Z0luynntqZVw46At\nylck/YpjqfnPdG5vo2F1L+WxJwKBgQDU1CDgNYxERW2xReHc9BSBauIwIDWl4AWw\nE+dfntnWTqJWRiwWN8lXbbquNYDLXTJCYP/9EguEIuYA6aS7AabGqEal1Q3nZDlS\nldvJxDfnNsLBY0Sr7RAbgMna45wnKt9vUGNgCCzJp2fXEAFsvTlUaoEaNyYPSNjd\nBGvcoRxcfwKBgQCRjjYTPgKVpvAQF1lmJdzc2Vsk61sZG81HdvnG9QohPtLnrCoe\nNwhq8NZ5CbFrMbXWI+gUw44LII9B6G9Dz/G9RrXukadnCbmdw5ryKlK/CQ+YNMXj\nEtmfl3ANRcn75kDschWXFuafBEJiTOh9nBMyj4sSyZruKLIVNMHkgpwuEQKBgQCa\nVrL4pRxxLgAcPFdMylxMddxNli4RemHljKmPeDz04tVqxzyVaCNEmbh1OSuLTqxx\n4rIBLiLX0g8FvmnNi6cMDWAeRmDs2ouPTkmzCe6YZ+fYIkrceu/hYgYADGtjI/4g\nVSWbsJH6MsJk/aBq4NZAV3QENNYO438Q2HH374YHtQKBgHbH2ARgup8raDpnOEEw\nIHxQv+gpWOusU6IYTDub3uiNLFl4Ea3pRWvKw7ZzTAglEPsdQtPO5+5MxtAvJQJW\n5umqRGHBcU+XqRIB8glqjZVxiljmUVAE4HrLDpcpvv8flYfKV5PzADHFxV9Vrs9w\nw0f8UIpPFiT4Exm8N7TM5r0s\n-----END PRIVATE KEY-----\n",
//       "client_email": "herman@cjb-app-429507.iam.gserviceaccount.com",
//       "client_id": "116029001283287572504",
//       "type": "service_account"
//     });

//     final client = await auth.clientViaServiceAccount(
//         accountCredentials, [pubsub.PubsubApi.pubsubScope]);
//     _pubsub = pubsub.PubsubApi(client);
//   }

//   // Subscribe to job category
//   Future<void> subscribeToCategory(String category) async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       final docRef = _db.collection('users').doc(user.uid);
//       await docRef.update({
//         'subscriptions': FieldValue.arrayUnion([category])
//       });

//       // Subscribe to Pub/Sub topic
//       await _pubsub.projects.subscriptions.create(
//           pubsub.Subscription(
//             name: 'projects/$_projectId/subscriptions/$_subscriptionName',
//             topic: _topicName,
//             pushConfig: pubsub.PushConfig(
//               pushEndpoint: 'https://your-app-url.com/push-endpoint',
//               attributes: {'category': category},
//             ),
//           ),
//           _subscriptionName);
//     }
//   }

//   // Unsubscribe from job category
//   Future<void> unsubscribeFromCategory(String category) async {
//     final user = _auth.currentUser;
//     if (user != null) {
//       final docRef = _db.collection('users').doc(user.uid);
//       await docRef.update({
//         'subscriptions': FieldValue.arrayRemove([category])
//       });

//       // Unsubscribe from Pub/Sub topic
//       await _pubsub.projects.subscriptions
//           .delete('projects/$_projectId/subscriptions/$_subscriptionName');
//     }
//   }

//   // Publish job notification
//   Future<void> publishJobNotification(String category, String jobId) async {
//     await _pubsub.projects.topics.publish(
//       pubsub.PublishRequest(
//         messages: [
//           pubsub.PubsubMessage(
//             data: base64Encode(utf8.encode(jobId)),
//             attributes: {'category': category},
//           ),
//         ],
//       ),
//       _topicName,
//     );
//   }

//   // Listen for job notifications
//   Future<void> listenForJobNotifications() async {
//     _messaging.subscribeToTopic(_topicName);
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       // Handle the job notification here
//       print('Received job notification: ${message.data}');
//     });
//   }

//   // Create job posting
//   Future<void> createJobPosting(
//       String title, String description, List<String> categories) async {
//     final jobId = _db.collection('jobs').doc().id;
//     await _db.collection('jobs').doc(jobId).set({
//       'title': title,
//       'description': description,
//       'categories': categories,
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     for (String category in categories) {
//       await publishJobNotification(category, jobId);
//     }
//   }

//   // Add user subscriptions
//   Future<void> addUserSubscription(
//       String userId, List<String> categories) async {
//     final docRef = _db.collection('users').doc(userId);
//     await docRef.update({
//       'subscriptions': categories,
//     });
//   }

//   // Get user subscriptions
//   Future<List<String>> getUserSubscriptions(String userId) async {
//     final docRef = _db.collection('users').doc(userId);
//     final docSnapshot = await docRef.get();

//     if (docSnapshot.exists &&
//         docSnapshot.data()!.containsKey('subscriptions')) {
//       return List<String>.from(docSnapshot.data()!['subscriptions']);
//     } else {
//       return [];
//     }
//   }

//   // Test and deploy your application
//   Future<void> testAndDeploy() async {
//     // Implement your testing and deployment logic here
//   }
// }

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis/pubsub/v1.dart' as pubsub;
import 'package:googleapis_auth/auth_io.dart' as auth;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Pub/Sub configuration
  final String _projectId = 'cjb-app-429507';
  final String _subscriptionName = 'job-category-subscription';
  final String _topicName = 'projects/cjb-app-429507/topics/job-notifications';

  // Google Cloud Pub/Sub client
  late final pubsub.PubsubApi _pubsub;

  FirestoreService() {
    _initializePubSub();
  }

  // Initialize Google Cloud Pub/Sub
  Future<void> _initializePubSub() async {
    // TODO: Load credentials from environment variables or secure storage
    // DO NOT hardcode credentials in source code
    // Use: await rootBundle.loadString('assets/service-account-file.json')
    // Or load from secure backend endpoint
    try {
      print('Pub/Sub initialization requires service account credentials');
      // Initialize only if credentials are available
    } catch (e) {
      print('Pub/Sub initialization failed: $e');
    }
  }

  // Subscribe to job category
  Future<void> subscribeToCategory(String category) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = _db.collection('users').doc(user.uid);
      await docRef.update({
        'subscriptions': FieldValue.arrayUnion([category])
      });

      await _pubsub.projects.subscriptions.create(
        pubsub.Subscription(
          name: 'projects/$_projectId/subscriptions/$_subscriptionName',
          topic: _topicName,
          pushConfig: pubsub.PushConfig(
            pushEndpoint:
                'https://395f-102-85-30-115.ngrok-free.app/push-endpoint',
            attributes: {'category': category},
          ),
        ),
        _subscriptionName,
      );
    }
  }

  // Unsubscribe from job category
  Future<void> unsubscribeFromCategory(String category) async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = _db.collection('users').doc(user.uid);
      await docRef.update({
        'subscriptions': FieldValue.arrayRemove([category])
      });

      await _pubsub.projects.subscriptions
          .delete('projects/$_projectId/subscriptions/$_subscriptionName');
    }
  }

  // Publish job notification
  Future<void> publishJobNotification(String category, String jobId) async {
    await _pubsub.projects.topics.publish(
      pubsub.PublishRequest(
        messages: [
          pubsub.PubsubMessage(
            data: base64Encode(utf8.encode(jobId)),
            attributes: {'category': category},
          ),
        ],
      ),
      _topicName,
    );
  }

  // Listen for job notifications
  Future<void> listenForJobNotifications() async {
    _messaging.subscribeToTopic(_topicName);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received job notification: ${message.data}');
    });
  }

  // Create job posting
  Future<void> createJobPosting(
      String title, String description, List<String> categories) async {
    final jobId = _db.collection('jobs').doc().id;
    await _db.collection('jobs').doc(jobId).set({
      'title': title,
      'description': description,
      'categories': categories,
      'timestamp': FieldValue.serverTimestamp(),
    });

    for (String category in categories) {
      await publishJobNotification(category, jobId);
    }
  }

  // Add user subscriptions
  Future<void> addUserSubscription(
      String userId, List<String> categories) async {
    final docRef = _db.collection('users').doc(userId);
    await docRef.update({
      'subscriptions': categories,
    });
  }

  // Get user subscriptions
  Future<List<String>> getUserSubscriptions(String userId) async {
    final docRef = _db.collection('users').doc(userId);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists &&
        docSnapshot.data()!.containsKey('subscriptions')) {
      return List<String>.from(docSnapshot.data()!['subscriptions']);
    } else {
      return [];
    }
  }

  // Test and deploy your application
  Future<void> testAndDeploy() async {
    // Implement your testing and deployment logic here
  }
}

//   // Create job posting
//   Future<void> createJobPosting(
//       String title, String description, List<String> categories) async {
//     final jobId = _db.collection('jobs').doc().id;
//     await _db.collection('jobs').doc(jobId).set({
//       'title': title,
//       'description': description,
//       'categories': categories,
//       'timestamp': FieldValue.serverTimestamp(),
//     });

//     for (String category in categories) {
//       await publishJobNotification(category, jobId);
//     }
//   }

//   // Add user subscriptions
//   Future<void> addUserSubscription(
//       String userId, List<String> categories) async {
//     final docRef = _db.collection('users').doc(userId);
//     await docRef.update({
//       'subscriptions': categories,
//     });
//   }

//   // Get user subscriptions
//   Future<List<String>> getUserSubscriptions(String userId) async {
//     final docRef = _db.collection('users').doc(userId);
//     final docSnapshot = await docRef.get();

//     if (docSnapshot.exists &&
//         docSnapshot.data()!.containsKey('subscriptions')) {
//       return List<String>.from(docSnapshot.data()!['subscriptions']);
//     } else {
//       return [];
//     }
//   }

//   // Test and deploy your application
//   Future<void> testAndDeploy() async {
//     // Implement your testing and deployment logic here
//   }
// }
