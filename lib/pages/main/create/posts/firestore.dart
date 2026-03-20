import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis/pubsub/v1.dart' as pubsub;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Pub/Sub configuration
  final String _projectId = 'cjb-app';
  final String _subscriptionName = 'job-category-subscription';
  final String _topicName = 'projects/cjb-app/topics/job-notifications';

  // Google Cloud Pub/Sub client
  pubsub.PubsubApi? _pubsub;

  FirestoreService() {
    _initializePubSub();
  }

  // Initialize Google Cloud Pub/Sub
  Future<void> _initializePubSub() async {
    try {
      const requiredKeys = <String>[
        'GOOGLE_CLOUD_TYPE',
        'GOOGLE_CLOUD_PROJECT_ID',
        'GOOGLE_CLOUD_PRIVATE_KEY_ID',
        'GOOGLE_CLOUD_PRIVATE_KEY',
        'GOOGLE_CLOUD_CLIENT_EMAIL',
        'GOOGLE_CLOUD_CLIENT_ID',
        'GOOGLE_CLOUD_AUTH_URI',
        'GOOGLE_CLOUD_TOKEN_URI',
        'GOOGLE_CLOUD_AUTH_PROVIDER_X509_CERT_URL',
        'GOOGLE_CLOUD_CLIENT_X509_CERT_URL',
        'GOOGLE_CLOUD_UNIVERSE_DOMAIN',
      ];

      final missingKeys = requiredKeys
          .where((key) => (dotenv.env[key] ?? '').trim().isEmpty)
          .toList();

      if (missingKeys.isNotEmpty) {
        print('Pub/Sub disabled. Missing env keys: ${missingKeys.join(', ')}');
        return;
      }

      final accountCredentials = auth.ServiceAccountCredentials.fromJson({
        "type": dotenv.env['GOOGLE_CLOUD_TYPE']!,
        "project_id": dotenv.env['GOOGLE_CLOUD_PROJECT_ID']!,
        "private_key_id": dotenv.env['GOOGLE_CLOUD_PRIVATE_KEY_ID']!,
        "private_key": dotenv.env['GOOGLE_CLOUD_PRIVATE_KEY']!,
        "client_email": dotenv.env['GOOGLE_CLOUD_CLIENT_EMAIL']!,
        "client_id": dotenv.env['GOOGLE_CLOUD_CLIENT_ID']!,
        "auth_uri": dotenv.env['GOOGLE_CLOUD_AUTH_URI']!,
        "token_uri": dotenv.env['GOOGLE_CLOUD_TOKEN_URI']!,
        "auth_provider_x509_cert_url":
            dotenv.env['GOOGLE_CLOUD_AUTH_PROVIDER_X509_CERT_URL']!,
        "client_x509_cert_url":
            dotenv.env['GOOGLE_CLOUD_CLIENT_X509_CERT_URL']!,
        "universe_domain": dotenv.env['GOOGLE_CLOUD_UNIVERSE_DOMAIN']!
      });

      final client = await auth.clientViaServiceAccount(
          accountCredentials, [pubsub.PubsubApi.pubsubScope]);
      _pubsub = pubsub.PubsubApi(client);
      print('Pub/Sub initialized successfully');
    } catch (e) {
      print('Pub/Sub initialization failed: $e');
      // Handle the error appropriately - maybe disable Pub/Sub features
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

      final pubsub.PubsubApi? pubsubClient = _pubsub;
      if (pubsubClient == null) {
        print('Pub/Sub client unavailable. Skipping subscription setup.');
        return;
      }

      final backendUrl = (dotenv.env['BACKEND_URL'] ?? '').trim();
      if (backendUrl.isEmpty) {
        print('Missing BACKEND_URL. Skipping push endpoint registration.');
        return;
      }
      final normalizedBackend = backendUrl.endsWith('/')
          ? backendUrl.substring(0, backendUrl.length - 1)
          : backendUrl;

      await pubsubClient.projects.subscriptions.create(
        pubsub.Subscription(
          name: 'projects/$_projectId/subscriptions/$_subscriptionName',
          topic: _topicName,
          pushConfig: pubsub.PushConfig(
            pushEndpoint: '$normalizedBackend/api/common/send-notification/',
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

      final pubsub.PubsubApi? pubsubClient = _pubsub;
      if (pubsubClient == null) {
        print('Pub/Sub client unavailable. Skipping subscription removal.');
        return;
      }

      await pubsubClient.projects.subscriptions
          .delete('projects/$_projectId/subscriptions/$_subscriptionName');
    }
  }

  // Publish job notification
  Future<void> publishJobNotification(String category, String jobId) async {
    final pubsub.PubsubApi? pubsubClient = _pubsub;
    if (pubsubClient == null) {
      print('Pub/Sub client unavailable. Skipping notification publish.');
      return;
    }

    await pubsubClient.projects.topics.publish(
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
