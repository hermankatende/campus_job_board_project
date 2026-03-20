import 'package:cjb/services/api_client.dart';

class EmployeeSearchService {
  final _api = ApiClient.instance;

  Future<List<Map<String, dynamic>>> searchEmployees({
    String? name,
    String? location,
    List<String>? gender,
    String? workingexperience,
    List<String>? skills,
    String? ageRange,
  }) async {
    try {
      final params = <String>[];

      if (name != null && name.trim().isNotEmpty) {
        params.add('name=${Uri.encodeQueryComponent(name.trim())}');
      }
      if (location != null && location.trim().isNotEmpty) {
        params.add('location=${Uri.encodeQueryComponent(location.trim())}');
      }
      if (gender != null && gender.isNotEmpty) {
        params.add('gender=${Uri.encodeQueryComponent(gender.join(','))}');
      }
      if (workingexperience != null && workingexperience.trim().isNotEmpty) {
        params.add(
            'work_experience=${Uri.encodeQueryComponent(workingexperience.trim())}');
      }
      if (skills != null && skills.isNotEmpty) {
        final nonEmpty = skills.where((s) => s.trim().isNotEmpty).toList();
        if (nonEmpty.isNotEmpty) {
          params.add('skills=${Uri.encodeQueryComponent(nonEmpty.join(','))}');
        }
      }
      if (ageRange != null && ageRange.trim().isNotEmpty) {
        params.add('age_range=${Uri.encodeQueryComponent(ageRange.trim())}');
      }

      final qs = params.isEmpty ? '' : '?${params.join('&')}';
      final data = await _api.get('/api/users/search/$qs');

      if (data is! List) return [];

      return data.map<Map<String, dynamic>>((e) {
        final m = e as Map<String, dynamic>;
        // Remap backend field names to the keys s.dart expects.
        return {
          'uid': m['firebase_uid'] ?? '',
          'name': m['full_name'] ?? '',
          'gender': m['gender'] ?? '',
          'work_experience': m['work_experience'] ?? '',
          'skills': m['skills'] ?? '',
          'age_range': m['age_range'] ?? '',
          'job_title': (m['job_preference'] as String?)?.isNotEmpty == true
              ? m['job_preference']
              : 'No job title',
          'image_url': m['image_url'] ?? '',
          'email': m['email'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error during search: $e');
      return [];
    }
  }
}
