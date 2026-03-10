// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cjb/pages/auth/preferences.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:cjb/pages/main/home/home_page.dart';
//import 'package:cjb/pages/auth/subscription_screen.dart';

class GlobalVariables {
  static final GlobalVariables _instance = GlobalVariables._internal();

  factory GlobalVariables() => _instance;

  GlobalVariables._internal();

  // Define all the fields to store user information
  String username = '';
  String email = '';
  String profileImageUrl = '';
  String aboutMe = '';
  String workExperience = '';
  String education = '';
  String skills = '';
  String hobbiesInterests = '';
  String portfolioUrl = '';
  String jobPreference = '';

  // Method to load user data from Firestore
  Future<void> loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        username = userDoc['name'] ?? '';
        email = userDoc['email'] ?? '';
        profileImageUrl = userDoc['image_path'] ?? '';
        aboutMe = userDoc['about_me'] ?? '';
        workExperience = userDoc['work_experience'] ?? '';
        education = userDoc['education'] ?? '';
        skills = userDoc['skills'] ?? '';
        hobbiesInterests = userDoc['hobbies_interests'] ?? '';
        portfolioUrl = userDoc['portfolio_url'] ?? '';
        jobPreference = userDoc['job_preference'] ?? '';
      }
    }
  }
}

class RoleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Your Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to HomePage if the user selects Employee
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MainPage(
                      firstName: '',
                      first_Name: '',
                    ),
                  ),
                  (route) => false,
                );
              },
              child: Text('I am an Employee'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to SubscriptionScreen if the user selects Job Seeker
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => SubscriptionScreen()),
                  (route) => false,
                );
              },
              child: Text('I am a Job Seeker (Student)'),
            ),
          ],
        ),
      ),
    );
  }
}
