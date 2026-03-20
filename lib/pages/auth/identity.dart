// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/auth/preferences.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
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

  Future<void> loadUserData() async {
    try {
      final profile = await AuthService.instance.syncProfile();
      username = profile.fullName;
      email = profile.email;
      profileImageUrl = profile.imageUrl;
      jobPreference = profile.jobPreference;
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
  bool _loading = false;

  Future<void> _selectRole(String role) async {
    setState(() => _loading = true);
    try {
      final profile = await AuthService.instance.completeOnboarding(role: role);
      if (!mounted) return;

      if (profile.isStudent) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SubscriptionScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(
              firstName: profile.fullName,
              first_Name: profile.fullName,
            ),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              onPressed: _loading ? null : () => _selectRole('student'),
              child: Text('I am a Student'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : () => _selectRole('recruiter'),
              child: Text('I am a Recruiter'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : () => _selectRole('lecturer'),
              child: Text('I am a Lecturer'),
            ),
            if (_loading) ...[
              SizedBox(height: 24),
              Center(child: CircularProgressIndicator()),
            ]
          ],
        ),
      ),
    );
  }
}
