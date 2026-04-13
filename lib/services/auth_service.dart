// ignore_for_file: avoid_print

import 'package:cjb/services/api_client.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Represents the full user profile returned by the Django backend.
class UserProfile {
  final int id;
  final String firebaseUid;
  final String email;
  final String fullName;
  final String role; // student | recruiter | lecturer | admin
  final String phone;
  final String imageUrl;
  final String gender;
  final String ageRange;

  // Shared
  final String aboutMe;
  final String skills;
  final String portfolioUrl;

  // Student
  final String college;
  final String program;
  final String studentNumber;
  final String workExperience;
  final String education;
  final String hobbiesInterests;
  final String jobPreference;
  final String resumeUrl;
  final bool notificationsEnabled;

  // Recruiter
  final String companyName;
  final String companyDescription;
  final String companyWebsite;
  final String companyLocation;

  // Lecturer
  final String department;
  final bool isVerified;
  final bool isSuspended;

  const UserProfile({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone = '',
    this.imageUrl = '',
    this.gender = '',
    this.ageRange = '',
    this.aboutMe = '',
    this.skills = '',
    this.portfolioUrl = '',
    this.college = '',
    this.program = '',
    this.studentNumber = '',
    this.workExperience = '',
    this.education = '',
    this.hobbiesInterests = '',
    this.jobPreference = '',
    this.resumeUrl = '',
    this.notificationsEnabled = true,
    this.companyName = '',
    this.companyDescription = '',
    this.companyWebsite = '',
    this.companyLocation = '',
    this.department = '',
    this.isVerified = false,
    this.isSuspended = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      firebaseUid: json['firebase_uid'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'student',
      phone: json['phone'] ?? '',
      imageUrl: json['image_url'] ?? '',
      gender: json['gender'] ?? '',
      ageRange: json['age_range'] ?? '',
      aboutMe: json['about_me'] ?? '',
      skills: json['skills'] ?? '',
      portfolioUrl: json['portfolio_url'] ?? '',
      college: json['college'] ?? '',
      program: json['program'] ?? '',
      studentNumber: json['student_number'] ?? '',
      workExperience: json['work_experience'] ?? '',
      education: json['education'] ?? '',
      hobbiesInterests: json['hobbies_interests'] ?? '',
      jobPreference: json['job_preference'] ?? '',
      resumeUrl: json['resume_url'] ?? '',
      notificationsEnabled: json['notifications_enabled'] ?? true,
      companyName: json['company_name'] ?? '',
      companyDescription: json['company_description'] ?? '',
      companyWebsite: json['company_website'] ?? '',
      companyLocation: json['company_location'] ?? '',
      department: json['department'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isSuspended: json['is_suspended'] ?? false,
    );
  }

  UserProfile copyWith({
    int? id,
    String? firebaseUid,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? imageUrl,
    String? gender,
    String? ageRange,
    String? aboutMe,
    String? skills,
    String? portfolioUrl,
    String? college,
    String? program,
    String? studentNumber,
    String? workExperience,
    String? education,
    String? hobbiesInterests,
    String? jobPreference,
    String? resumeUrl,
    bool? notificationsEnabled,
    String? companyName,
    String? companyDescription,
    String? companyWebsite,
    String? companyLocation,
    String? department,
    bool? isVerified,
    bool? isSuspended,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      gender: gender ?? this.gender,
      ageRange: ageRange ?? this.ageRange,
      aboutMe: aboutMe ?? this.aboutMe,
      skills: skills ?? this.skills,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      college: college ?? this.college,
      program: program ?? this.program,
      studentNumber: studentNumber ?? this.studentNumber,
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      hobbiesInterests: hobbiesInterests ?? this.hobbiesInterests,
      jobPreference: jobPreference ?? this.jobPreference,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      companyName: companyName ?? this.companyName,
      companyDescription: companyDescription ?? this.companyDescription,
      companyWebsite: companyWebsite ?? this.companyWebsite,
      companyLocation: companyLocation ?? this.companyLocation,
      department: department ?? this.department,
      isVerified: isVerified ?? this.isVerified,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'image_url': imageUrl,
        'gender': gender,
        'age_range': ageRange,
        'about_me': aboutMe,
        'skills': skills,
        'portfolio_url': portfolioUrl,
        'college': college,
        'program': program,
        'student_number': studentNumber,
        'work_experience': workExperience,
        'education': education,
        'hobbies_interests': hobbiesInterests,
        'job_preference': jobPreference,
        'resume_url': resumeUrl,
        'notifications_enabled': notificationsEnabled,
        'company_name': companyName,
        'company_description': companyDescription,
        'company_website': companyWebsite,
        'company_location': companyLocation,
        'department': department,
      };

  bool get isStudent => role == 'student';
  bool get isRecruiter => role == 'recruiter';
  bool get isLecturer => role == 'lecturer';
  bool get isAdmin => role == 'admin';
}

/// Combines Firebase Authentication with the Django backend.
///
/// After every sign-in / sign-up, it calls `GET /api/users/me/` to sync
/// the profile from the backend — this returns the user's role so the app
/// can navigate to the correct dashboard.
///
/// Usage:
///   final profile = await AuthService.instance.signIn(email, password);
///   if (profile?.isStudent == true) navigator.pushNamed('/student/home');
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String systemAdminEmail = 'hermankats16@gmail.com';

  final _firebase = FirebaseAuth.instance;
  final _api = ApiClient.instance;

  UserProfile? _profile;

  /// The cached profile for the currently signed-in user.
  UserProfile? get currentProfile => _profile;

  /// Whether a Firebase user is currently signed in.
  bool get isSignedIn => _firebase.currentUser != null;

  // ── Sign In ───────────────────────────────────────────────────────────────

  /// Signs in with email + password, then syncs profile from the backend.
  /// Returns the [UserProfile] or throws a human-readable error [String].
  Future<UserProfile> signIn(String email, String password) async {
    try {
      await _firebase.signInWithEmailAndPassword(
          email: email.trim(), password: password);
      return await _syncProfile();
    } on FirebaseAuthException catch (e) {
      throw _friendlyError(e);
    } on ApiException catch (e) {
      throw 'Backend error: ${e.message}';
    }
  }

  /// Creates Firebase account, syncs profile to backend and stores full name.
  Future<UserProfile> registerAccount({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final cred = await _firebase.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (fullName.trim().isNotEmpty) {
        await cred.user?.updateDisplayName(fullName.trim());
      }

      await _syncProfile();
      return await updateProfile({'full_name': fullName.trim()});
    } on FirebaseAuthException catch (e) {
      throw _friendlyError(e);
    } on ApiException catch (e) {
      throw 'Backend error: ${e.message}';
    }
  }

  // ── Register ──────────────────────────────────────────────────────────────

  /// Creates a Firebase account, then pushes the initial profile to backend.
  ///
  /// [role] must be one of: student | recruiter | lecturer | admin
  /// [profileData] any extra profile fields to save immediately (college, company, etc.)
  Future<UserProfile> register({
    required String email,
    required String password,
    required String role,
    Map<String, dynamic> profileData = const {},
  }) async {
    try {
      await _firebase.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

      // First call to /me/ creates the backend profile record
      await _syncProfile();

      // Patch with role + any extra data
      final patchData = Map<String, dynamic>.from(profileData)..['role'] = role;
      final data = await _api.patch('/api/users/me/', patchData);
      _profile = UserProfile.fromJson(data as Map<String, dynamic>);
      return _profile!;
    } on FirebaseAuthException catch (e) {
      throw _friendlyError(e);
    } on ApiException catch (e) {
      throw 'Backend error: ${e.message}';
    }
  }

  // ── Profile sync & update ─────────────────────────────────────────────────

  /// Loads the profile from the backend and caches it locally.
  /// Call this on app launch when a Firebase user is already signed in.
  Future<UserProfile> syncProfile() async => await _syncProfile();

  Future<UserProfile> _syncProfile() async {
    final data = await _api.get('/api/users/me/');
    final values = Map<String, dynamic>.from(data as Map<String, dynamic>);
    final currentEmail = _firebase.currentUser?.email?.trim().toLowerCase();

    if ((values['role'] as String?)?.trim().isEmpty ?? true) {
      if (currentEmail == systemAdminEmail) {
        values['role'] = 'admin';
      } else if (currentEmail?.contains('recruiter') ?? false) {
        values['role'] = 'recruiter';
      } else if (currentEmail?.contains('lecturer') ?? false) {
        values['role'] = 'lecturer';
      } else if (currentEmail?.contains('admin') ?? false) {
        values['role'] = 'admin';
      } else {
        values['role'] = 'student';
      }
    }

    _profile = UserProfile.fromJson(values);
    return _profile!;
  }

  /// Patches the current user's profile and updates the local cache.
  Future<UserProfile> updateProfile(Map<String, dynamic> fields) async {
    final data = await _api.patch('/api/users/me/', fields);
    _profile = UserProfile.fromJson(data as Map<String, dynamic>);
    return _profile!;
  }

  /// Completes role-based onboarding on backend.
  Future<UserProfile> completeOnboarding({
    required String role,
    Map<String, dynamic> profileData = const {},
  }) async {
    final body = Map<String, dynamic>.from(profileData)..['role'] = role;
    try {
      await _syncProfile();
      final data = await _api.post('/api/users/onboarding/', body);
      _profile = UserProfile.fromJson(data as Map<String, dynamic>);
      return _profile!;
    } on ApiException catch (e) {
      // Some deployments require /me/ bootstrap before onboarding is allowed.
      if (e.statusCode == 403) {
        await _syncProfile();
        final retryData = await _api.post('/api/users/onboarding/', body);
        _profile = UserProfile.fromJson(retryData as Map<String, dynamic>);
        return _profile!;
      }
      if (e.statusCode == 0) {
        throw 'Network error. Check your internet connection and backend URL.';
      }
      throw 'Backend error (${e.statusCode}): ${e.message}';
    }
  }

  /// Saves or updates the FCM token on the backend so the user receives
  /// personalised push notifications.
  Future<void> saveFcmToken(String token) async {
    try {
      await _api.patch('/api/users/me/', {'fcm_token': token});
    } catch (e) {
      print('[AuthService] Could not save FCM token: $e');
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _profile = null;
    await _firebase.signOut();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been suspended.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
