// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors, use_build_context_synchronously

// // // ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_brace_in_string_interps, non_constant_identifier_names
import 'package:cjb/pages/auth/identity.dart';
//import 'package:cjb/pages/main/home/home_page.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<String> categories = ['IT', 'Finance', 'Health', 'Education'];
  Map<String, bool> selectedCategories = {
    'IT': false,
    'Finance': false,
    'Health': false,
    'Education': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await GlobalVariables().loadUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscribe to Job Categories')),
      body: ListView(
        children: categories.map((category) {
          return CheckboxListTile(
            title: Text(category),
            value: selectedCategories[category],
            onChanged: (bool? value) {
              setState(() {
                selectedCategories[category] = value!;
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveSubscriptions,
        child: Icon(Icons.save),
      ),
    );
  }

  void _saveSubscriptions() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Retrieve FCM token
    String? fcmToken = await FirebaseMessaging.instance.getToken();

    // Prepare data to save
    Map<String, dynamic> data = {
      'subscriptions': selectedCategories.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
    };

    if (fcmToken != null) {
      data['fcmToken'] = fcmToken;
    }

    // Save data to Firestore
    await firestore
        .collection('users')
        .doc(userId)
        .set(data, SetOptions(merge: true));

    // Show a confirmation message and navigate to MainPage
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const MainPage(
          firstName: '',
          first_Name: '',
        ),
      ),
      (route) => false,
    );
  }
}
