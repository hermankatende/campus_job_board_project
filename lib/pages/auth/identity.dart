// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/auth/role_details_page.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:flutter/material.dart';

class GlobalVariables {
  static final GlobalVariables _instance = GlobalVariables._internal();

  factory GlobalVariables() => _instance;

  GlobalVariables._internal();

  String username = '';
  String email = '';
  String profileImageUrl = '';
  String jobPreference = '';
  String role = '';
  String aboutMe = '';
  String workExperience = '';
  String education = '';
  String skills = '';
  String hobbiesInterests = '';
  String portfolioUrl = '';

  Future<void> loadUserData() async {
    try {
      final profile = await AuthService.instance.syncProfile();
      username = profile.fullName;
      email = profile.email;
      profileImageUrl = profile.imageUrl;
      jobPreference = profile.jobPreference;
      role = profile.role;
      aboutMe = profile.aboutMe;
      workExperience = profile.workExperience;
      education = profile.education;
      skills = profile.skills;
      hobbiesInterests = profile.hobbiesInterests;
      portfolioUrl = profile.portfolioUrl;
    } catch (_) {
      // Keep previous values if profile sync fails.
    }
  }
}

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  void _selectRole(String role) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoleDetailsPage(role: role)),
    );
  }

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
              onPressed: () => _selectRole('student'),
              child: Text('I am a Student'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole('recruiter'),
              child: Text('I am a Recruiter'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole('lecturer'),
              child: Text('I am a Lecturer'),
            ),
          ],
        ),
      ),
    );
  }
}
