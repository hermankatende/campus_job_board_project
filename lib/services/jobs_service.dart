import 'package:cjb/services/api_client.dart';

class JobDeleteResult {
  final int jobId;
  final DateTime? undoExpiresAt;

  const JobDeleteResult({
    required this.jobId,
    required this.undoExpiresAt,
  });

  factory JobDeleteResult.fromJson(Map<String, dynamic> json) {
    return JobDeleteResult(
      jobId: json['job_id'] ?? 0,
      undoExpiresAt: json['undo_expires_at'] != null
          ? DateTime.tryParse(json['undo_expires_at'])
          : null,
    );
  }
}

class AppJob {
  final int id;
  final String title;
  final String company;
  final String location;
  final String category;
  final String description;
  final String requirements;
  final String employmentType;
  final String status;
  final String postedByName;
  final String postedByUid;
  final String postedByRole;
  final DateTime? createdAt;

  const AppJob({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.category,
    required this.description,
    required this.requirements,
    required this.employmentType,
    required this.status,
    required this.postedByName,
    required this.postedByUid,
    required this.postedByRole,
    this.createdAt,
  });

  factory AppJob.fromJson(Map<String, dynamic> json) {
    return AppJob(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      employmentType: json['employment_type'] ?? '',
      status: json['status'] ?? 'open',
      postedByName: json['posted_by_name'] ?? '',
      postedByUid: json['posted_by_uid'] ?? '',
      postedByRole: json['posted_by_role'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class JobsFilter {
  final String search;
  final String category;
  final String status;
  final String location;
  final String employmentType;
  final String postedByRole;
  final bool remoteOnly;

  const JobsFilter({
    this.search = '',
    this.category = '',
    this.status = '',
    this.location = '',
    this.employmentType = '',
    this.postedByRole = '',
    this.remoteOnly = false,
  });

  String toQueryString() {
    final params = <String>[];
    if (search.trim().isNotEmpty)
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    if (category.trim().isNotEmpty)
      params.add('category=${Uri.encodeQueryComponent(category.trim())}');
    if (status.trim().isNotEmpty)
      params.add('status=${Uri.encodeQueryComponent(status.trim())}');
    if (location.trim().isNotEmpty)
      params.add('location=${Uri.encodeQueryComponent(location.trim())}');
    if (employmentType.trim().isNotEmpty) {
      params.add(
          'employment_type=${Uri.encodeQueryComponent(employmentType.trim())}');
    }
    if (postedByRole.trim().isNotEmpty) {
      params.add(
          'posted_by_role=${Uri.encodeQueryComponent(postedByRole.trim())}');
    }
    if (remoteOnly) params.add('remote=true');

    if (params.isEmpty) return '';
    return '?${params.join('&')}';
  }
}

class JobsService {
  JobsService._();
  static final JobsService instance = JobsService._();

  final _api = ApiClient.instance;

  Future<List<AppJob>> fetchJobs(
      {JobsFilter filter = const JobsFilter()}) async {
    final data = await _api.get('/api/jobs/${filter.toQueryString()}');

    if (data is Map<String, dynamic> && data['results'] is List) {
      final items = data['results'] as List;
      return items
          .map((e) => AppJob.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (data is List) {
      return data
          .map((e) => AppJob.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<List<AppJob>> fetchMyJobs() async {
    final data = await _api.get('/api/jobs/mine/');
    if (data is! List) return [];
    return data.map((e) => AppJob.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AppJob> createJob({
    required String title,
    required String company,
    required String location,
    required String category,
    required String description,
    required String employmentType,
    String requirements = '',
  }) async {
    final data = await _api.post('/api/jobs/', {
      'title': title,
      'company': company,
      'location': location,
      'category': category,
      'description': description,
      'requirements': requirements,
      'employment_type': employmentType,
      'status': 'open',
    });

    return AppJob.fromJson(data as Map<String, dynamic>);
  }

  Future<JobDeleteResult> deleteJob(int id) async {
    final data = await _api.delete('/api/jobs/$id/');
    if (data is Map<String, dynamic>) {
      return JobDeleteResult.fromJson(data);
    }
    return JobDeleteResult(jobId: id, undoExpiresAt: null);
  }

  Future<AppJob> restoreJob(int id) async {
    final data = await _api.post('/api/jobs/$id/restore/', {});
    return AppJob.fromJson(data as Map<String, dynamic>);
  }
}
