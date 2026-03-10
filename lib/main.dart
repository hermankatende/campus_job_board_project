// ignore_for_file: prefer_const_constructors, avoid_print, use_super_parameters

//import 'dart:convert';

import 'package:cjb/firebase_options.dart';
//import 'package:cjb/pages/auth/user_pref.dart';
import 'package:cjb/pages/main/main_page/joblist.dart';
import 'package:cjb/pages/main/main_page/main_page.dart'; // Added import for Notification_Page
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cjb/pages/splash/splash_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pages/onboarding/on_boarding_screen.dart';
// import 'package:googleapis/pubsub/v1.dart' as pubsub;
// import 'package:googleapis_auth/auth_io.dart' as auth;
// import 'dart:io';
// import 'package:googleapis/pubsub/v1.dart';
// import 'package:googleapis_auth/auth_io.dart';
// import 'package:flutter/services.dart' show rootBundle;
//import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
// Import the JobsList widget

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('notifications');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        // Navigate to JobsList on notification click
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => JobsList(),
        ));
      }
    },
  );

  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground message
      print('Received a foreground message: ${message.messageId}');
      _showNotification(message.notification);
      print('Now saving to local ');
      _saveNotificationToLocal(message.notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background message when the app is opened from notification
      navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) => JobsList(),
      ));
      print('Message clicked!');
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        // Handle initial message when the app is opened directly from the notification
        navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => JobsList(),
        ));
        print('Received an initial message: ${message.messageId}');
      }
    });

    _storeFCMToken();
  }

  void _requestPermissions() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');
  }

  Future<void> _storeFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    if (token != null) {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
      print('Stored FCM token: $token');
    } else {
      print('Failed to get FCM token');
    }
  }

  Future<void> _showNotification(RemoteNotification? notification) async {
    if (notification != null) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'job_postings_channel', // Channel ID
        'Job Postings', // Channel Name
        channelDescription:
            'Notifications about new job postings', // Channel Description
        importance: Importance.max,
        priority: Priority.high,
        showWhen: false,
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformChannelSpecifics,
      );
      print('Notification shown: ${notification.title} - ${notification.body}');
    } else {
      print('No notification to show');
    }
  }

  void _saveNotificationToLocal(RemoteNotification? notification) async {
    if (notification != null) {
      Box box = Hive.box('notifications');
      await box.add({
        'title': notification.title,
        'body': notification.body,
      });
      print('Notification saved: ${notification.title} - ${notification.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (FirebaseAuth.instance.currentUser != null) {
      return MainPage(
        firstName: '',
        first_Name: '',
      ); // Navigate to HomePage if the user is logged in
    } else {
      return SplashPage(
        child: OnBoardingScreen(),
      );
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');

  // Display notification
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'job_postings_channel', // Channel ID
      'Job Postings', // Channel Name
      channelDescription:
          'Notifications about new job postings', // Channel Description
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
    print(
        'Background notification shown: ${notification.title} - ${notification.body}');
  } else {
    print('No background notification to show');
  }
}
