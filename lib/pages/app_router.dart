// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/main/admin/admin_main_page.dart';
import 'package:cjb/pages/main/lecturer_main_page.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:cjb/pages/main/recruiter_main_page.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:flutter/material.dart';

/// Returns the correct home page widget for the given [profile].
/// Centralises role-based routing in one place.
Widget homePageForProfile(UserProfile profile) {
  if (profile.isAdmin) return AdminMainPage();
  if (profile.isRecruiter) return RecruiterMainPage();
  if (profile.isLecturer) return LecturerMainPage();
  return MainPage(firstName: profile.fullName, first_Name: profile.fullName);
}

/// Determines whether the user still needs to complete onboarding.
bool needsOnboarding(UserProfile profile) {
  if (profile.role.isEmpty) return true;
  if (profile.isStudent) {
    return profile.college.isEmpty ||
        profile.program.isEmpty ||
        profile.studentNumber.isEmpty;
  }
  if (profile.isRecruiter) return profile.companyName.isEmpty;
  if (profile.isLecturer) return profile.department.isEmpty;
  return false;
}

/// Navigates to the correct destination, removing all prior routes.
void navigateToHome(BuildContext context, UserProfile profile) {
  if (needsOnboarding(profile)) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => RoleSelectionPage()),
      (route) => false,
    );
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => homePageForProfile(profile)),
      (route) => false,
    );
  }
}
