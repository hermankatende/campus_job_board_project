// ignore_for_file: prefer_const_constructors, avoid_print, use_super_parameters

//import 'dart:convert';

import 'package:cjb/pages/app_router.dart';
import 'package:cjb/firebase_options.dart';
//import 'package:cjb/pages/auth/user_pref.dart';
import 'package:cjb/pages/main/main_page/joblist.dart';
import 'package:cjb/services/auth_service.dart';
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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Import the JobsList widget

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
const String _jobPostingsChannelId = 'job_postings_channel';
const String _jobPostingsChannelName = 'Job Postings';
const String _jobPostingsChannelDescription =
    'Notifications about new job postings';
const String _openJobsPayload = 'open_jobs';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (error) {
    debugPrint('Failed to load .env: $error');
  }

  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  await Hive.openBox('notifications');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (!kIsWeb) {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload == _openJobsPayload) {
          navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (context) => JobsList(),
          ));
        }
      },
    );
  }

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
      _handleIncomingMessage(message, showLocalNotification: true);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle background message when the app is opened from notification
      _handleMessageTap();
      _saveNotificationToLocal(message);
      print('Message clicked!');
    });

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        // Handle initial message when the app is opened directly from the notification
        _handleMessageTap();
        _saveNotificationToLocal(message);
        print('Received an initial message: ${message.messageId}');
      }
    });

    _storeFCMToken();

    // Token can rotate; keep backend in sync for reliable pushes.
    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      try {
        await AuthService.instance.saveFcmToken(token);
        print('Refreshed FCM token synced');
      } catch (e) {
        print('Failed to sync refreshed FCM token: $e');
      }
    });
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
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        await AuthService.instance.saveFcmToken(token);
        print('Stored FCM token: $token');
      } else {
        print('Failed to get FCM token');
      }
    } on FirebaseException catch (error) {
      debugPrint('Failed to store FCM token: ${error.message ?? error.code}');
    }
  }

  void _handleIncomingMessage(
    RemoteMessage message, {
    required bool showLocalNotification,
  }) {
    final notification = message.notification;
    if (showLocalNotification && !kIsWeb && notification != null) {
      _showNotification(notification);
    }
    _saveNotificationToLocal(message);
  }

  void _handleMessageTap() {
    navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (context) => JobsList(),
    ));
  }

  Future<void> _showNotification(RemoteNotification notification) async {
    if (!kIsWeb) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        _jobPostingsChannelId,
        _jobPostingsChannelName,
        channelDescription: _jobPostingsChannelDescription,
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
        payload: _openJobsPayload,
      );
      print('Notification shown: ${notification.title} - ${notification.body}');
    }
  }

  void _saveNotificationToLocal(RemoteMessage message) async {
    final title = message.notification?.title ??
        (message.data['title']?.toString() ?? '');
    final body =
        message.notification?.body ?? (message.data['body']?.toString() ?? '');
    final messageId = message.messageId;

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    final Box box = Hive.box('notifications');

    if (messageId != null) {
      for (var i = 0; i < box.length; i++) {
        final dynamic raw = box.getAt(i);
        if (raw is Map && raw['message_id'] == messageId) {
          return;
        }
      }
    }

    await box.add({
      'message_id': messageId,
      'title': title,
      'body': body,
      'type': _notificationTypeFromTitle(title, body),
      'created_at': DateTime.now().toIso8601String(),
      'is_read': false,
    });

    print('Notification saved: $title - $body');
  }

  String _notificationTypeFromTitle(String title, String body) {
    final value = '$title $body'.toLowerCase();
    if (value.contains('application update') || value.contains('status')) {
      return 'status_update';
    }
    if (value.contains('new') && value.contains('job')) {
      return 'new_job';
    }
    return 'general';
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
    if (FirebaseAuth.instance.currentUser == null) {
      return SplashPage(child: OnBoardingScreen());
    }
    return FutureBuilder(
      future: AuthService.instance.syncProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          // Profile sync failed — send to onboarding / sign-in
          return SplashPage(child: OnBoardingScreen());
        }
        final profile = snapshot.data!;
        if (needsOnboarding(profile)) {
          return SplashPage(child: OnBoardingScreen());
        }
        return homePageForProfile(profile);
      },
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');

  final title =
      message.notification?.title ?? (message.data['title']?.toString() ?? '');
  final body =
      message.notification?.body ?? (message.data['body']?.toString() ?? '');

  if (title.isNotEmpty || body.isNotEmpty) {
    if (!Hive.isBoxOpen('notifications')) {
      if (kIsWeb) {
        await Hive.initFlutter();
      } else {
        final appDocumentDir = await getApplicationDocumentsDirectory();
        await Hive.initFlutter(appDocumentDir.path);
      }
      await Hive.openBox('notifications');
    }

    final box = Hive.box('notifications');
    final messageId = message.messageId;
    var alreadySaved = false;
    if (messageId != null) {
      for (var i = 0; i < box.length; i++) {
        final dynamic raw = box.getAt(i);
        if (raw is Map && raw['message_id'] == messageId) {
          alreadySaved = true;
          break;
        }
      }
    }

    if (!alreadySaved) {
      await box.add({
        'message_id': messageId,
        'title': title,
        'body': body,
        'type': 'general',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      });
    }
  }

  final notification = message.notification;
  if (notification != null && !kIsWeb) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      _jobPostingsChannelId,
      _jobPostingsChannelName,
      channelDescription: _jobPostingsChannelDescription,
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
      payload: _openJobsPayload,
    );
    print(
        'Background notification shown: ${notification.title} - ${notification.body}');
  } else {
    print('No background notification to show');
  }
}
