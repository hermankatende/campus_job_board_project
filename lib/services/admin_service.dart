import 'package:cjb/services/api_client.dart';

class DashboardMetrics {
  final int users;
  final int activeUsers;
  final int students;
  final int recruiters;
  final int lecturers;
  final int pendingLecturerVerifications;
  final int jobs;
  final int openJobs;
  final int applications;

  const DashboardMetrics({
    required this.users,
    required this.activeUsers,
    required this.students,
    required this.recruiters,
    required this.lecturers,
    required this.pendingLecturerVerifications,
    required this.jobs,
    required this.openJobs,
    required this.applications,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      users: json['users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      students: json['students'] ?? 0,
      recruiters: json['recruiters'] ?? 0,
      lecturers: json['lecturers'] ?? 0,
      pendingLecturerVerifications: json['pending_lecturer_verifications'] ?? 0,
      jobs: json['jobs'] ?? 0,
      openJobs: json['open_jobs'] ?? 0,
      applications: json['applications'] ?? 0,
    );
  }
}

class AdminUserRecord {
  final int id;
  final String name;
  final String role;
  final String email;
  final String status;
  final bool isVerified;
  final bool isSuspended;

  const AdminUserRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.status,
    required this.isVerified,
    required this.isSuspended,
  });

  factory AdminUserRecord.fromJson(Map<String, dynamic> json) {
    return AdminUserRecord(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'offline',
      isVerified: json['is_verified'] ?? false,
      isSuspended: json['is_suspended'] ?? false,
    );
  }
}

class AdminService {
  AdminService._();
  static final AdminService instance = AdminService._();

  final _api = ApiClient.instance;

  Future<DashboardMetrics> getMetrics() async {
    final data = await _api.get('/api/common/stats/');
    return DashboardMetrics.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AdminUserRecord>> listUsers({
    String search = '',
    String role = '',
    String status = '',
  }) async {
    final params = <String>[];
    if (search.trim().isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search.trim())}');
    }
    if (role.trim().isNotEmpty) {
      params.add('role=${Uri.encodeQueryComponent(role.trim())}');
    }
    if (status.trim().isNotEmpty) {
      params.add('status=${Uri.encodeQueryComponent(status.trim())}');
    }

    final suffix = params.isEmpty ? '' : '?${params.join('&')}';
    final data = await _api.get('/api/users/admin/users/$suffix');

    if (data is! List) return [];
    return data
        .map((item) => AdminUserRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> setUserRole({required int userId, required String role}) async {
    await _api.patch('/api/users/admin/users/$userId/role/', {'role': role});
  }

  Future<void> setUserSuspended(
      {required int userId, required bool suspend}) async {
    await _api
        .patch('/api/users/admin/users/$userId/suspend/', {'suspend': suspend});
  }

  Future<void> verifyLecturer(
      {required int userId, required bool verify}) async {
    await _api.patch(
        '/api/users/admin/users/$userId/verify-lecturer/', {'verify': verify});
  }

  Future<void> deleteUser(int userId) async {
    await _api.delete('/api/users/admin/users/$userId/');
  }
}
