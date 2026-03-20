import 'package:cjb/services/api_client.dart';

class JobApplication {
  final int id;
  final int jobId;
  final String jobTitle;
  final String applicantUid;
  final String applicantName;
  final String applicantProgram;
  final String applicantEmail;
  final String coverLetter;
  final String resumeUrl;
  final String status;
  final DateTime? createdAt;

  const JobApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.applicantUid,
    required this.applicantName,
    required this.applicantProgram,
    required this.applicantEmail,
    required this.coverLetter,
    required this.resumeUrl,
    required this.status,
    this.createdAt,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      id: json['id'] ?? 0,
      jobId: json['job_id'] ?? json['job'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      applicantUid: json['applicant_uid'] ?? '',
      applicantName: json['applicant_name'] ?? '',
      applicantProgram: json['applicant_program'] ?? '',
      applicantEmail: json['applicant_email'] ?? '',
      coverLetter: json['cover_letter'] ?? '',
      resumeUrl: json['resume_url'] ?? '',
      status: json['status'] ?? 'applied',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

class JobApplicationStats {
  final int jobId;
  final String jobTitle;
  final int totalApplicants;
  final int newApplications;
  final int reviewed;
  final int shortlisted;
  final int rejected;
  final int hired;

  const JobApplicationStats({
    required this.jobId,
    required this.jobTitle,
    required this.totalApplicants,
    required this.newApplications,
    required this.reviewed,
    required this.shortlisted,
    required this.rejected,
    required this.hired,
  });

  factory JobApplicationStats.fromJson(Map<String, dynamic> json) {
    return JobApplicationStats(
      jobId: json['job_id'] ?? 0,
      jobTitle: json['job_title'] ?? '',
      totalApplicants: json['total_applicants'] ?? 0,
      newApplications: json['new_applications'] ?? 0,
      reviewed: json['reviewed'] ?? 0,
      shortlisted: json['shortlisted'] ?? 0,
      rejected: json['rejected'] ?? 0,
      hired: json['hired'] ?? 0,
    );
  }
}

class ApplicationsService {
  ApplicationsService._();
  static final ApplicationsService instance = ApplicationsService._();

  final _api = ApiClient.instance;

  Future<JobApplication> applyToJob({
    required int jobId,
    String coverLetter = '',
    String resumeUrl = '',
  }) async {
    final data = await _api.post('/api/applications/', {
      'job': jobId,
      'cover_letter': coverLetter,
      'resume_url': resumeUrl,
    });
    return JobApplication.fromJson(data as Map<String, dynamic>);
  }

  Future<List<JobApplication>> listMyApplications({String status = ''}) async {
    final suffix = status.trim().isNotEmpty
        ? '?role=applicant&status=${Uri.encodeQueryComponent(status.trim())}'
        : '?role=applicant';
    final data = await _api.get('/api/applications/$suffix');
    return _parseList(data);
  }

  Future<List<JobApplication>> listApplicationsForMyPostedJobs({
    String status = '',
    int? jobId,
  }) async {
    final params = <String>['role=poster'];
    if (status.trim().isNotEmpty) {
      params.add('status=${Uri.encodeQueryComponent(status.trim())}');
    }
    if (jobId != null) {
      params.add('job=$jobId');
    }
    final data = await _api.get('/api/applications/?${params.join('&')}');
    return _parseList(data);
  }

  Future<List<JobApplication>> listApplicationsForJob(int jobId) async {
    final data = await _api.get('/api/applications/job/$jobId/');
    return _parseList(data);
  }

  Future<JobApplicationStats> getJobApplicationStats(int jobId) async {
    final data = await _api.get('/api/applications/job/$jobId/stats/');
    return JobApplicationStats.fromJson(data as Map<String, dynamic>);
  }

  Future<JobApplication> updateStatus({
    required int applicationId,
    required String status,
  }) async {
    final data = await _api.patch('/api/applications/$applicationId/', {
      'status': status,
    });
    return JobApplication.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteApplication(int applicationId) async {
    await _api.delete('/api/applications/$applicationId/');
  }

  List<JobApplication> _parseList(dynamic data) {
    if (data is Map<String, dynamic> && data['results'] is List) {
      final list = data['results'] as List;
      return list
          .map((item) => JobApplication.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    if (data is List) {
      return data
          .map((item) => JobApplication.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
