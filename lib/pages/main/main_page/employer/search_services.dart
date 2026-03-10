import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchEmployees({
    String? name,
    String? location,
    List<String>? gender,
    String? workingexperience,
    List<String>? skills,
    String? ageRange,
  }) async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      final users = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>
            ..['uid'] = doc.id) // Include user ID
          .toList();

      final matchedUsers = <Map<String, dynamic>>[];

      for (var user in users) {
        bool matches = true;

        final normalizedName = (user['name'] as String?)?.trim() ?? '';
        final normalizedGender = (user['gender'] as String?)?.trim() ?? '';
        final normalizedWorkingExperience =
            (user['work_experience'] as String?)?.trim() ?? '';
        final normalizedSkills = (user['skills'] as String?)?.trim() ?? '';
        final normalizedAgeRange = (user['age_range'] as String?)?.trim() ?? '';

        if (name != null && !normalizedName.contains(name.trim())) {
          matches = false;
        }

        if (gender != null && !gender.contains(normalizedGender)) {
          matches = false;
        }

        if (workingexperience != null &&
            !normalizedWorkingExperience.contains(workingexperience.trim())) {
          matches = false;
        }

        if (skills != null &&
            !skills.any((skill) => normalizedSkills.contains(skill.trim()))) {
          matches = false;
        }

        if (ageRange != null && normalizedAgeRange != ageRange.trim()) {
          matches = false;
        }

        if (matches) {
          matchedUsers.add(user);
        }
      }

      return matchedUsers;
    } catch (e) {
      print('Error during search: $e');
      return [];
    }
  }
}
