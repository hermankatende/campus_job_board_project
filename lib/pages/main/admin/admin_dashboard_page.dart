// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/auth/sign_in_page.dart';
import 'package:cjb/pages/main/admin/admin_users_page.dart';
import 'package:cjb/pages/main/create/add_job.dart';
import 'package:cjb/pages/main/user_profile/profile_page.dart';
import 'package:cjb/services/admin_service.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<DashboardMetrics> _metricsFuture;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _metricsFuture = AdminService.instance.getMetrics();
    AuthService.instance.syncProfile().then((profile) {
      if (mounted) {
        setState(() => _profile = profile);
      }
    });
  }

  void _refresh() {
    setState(() {
      _metricsFuture = AdminService.instance.getMetrics();
    });
  }

  void _openAllJobPostsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const _AdminAllJobPostsPage()),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SignInPage()),
        (route) => false,
      );
    }
  }

  Widget _buildDrawer() {
    final displayName =
        _profile?.fullName.isNotEmpty == true ? _profile!.fullName : 'Admin';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(displayName),
              accountEmail: Text(_profile?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Color.fromRGBO(0, 96, 243, 1),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 96, 243, 1),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.work_outline),
              title: Text('All Job Posts'),
              onTap: () {
                Navigator.pop(context);
                _openAllJobPostsPage();
              },
            ),
            ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminUsersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
            ),
            Spacer(),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: FutureBuilder<DashboardMetrics>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final metrics = snapshot.data;
          if (metrics == null) {
            return Center(child: Text('No data available'));
          }

          final displayName = _profile?.fullName.isNotEmpty == true
              ? _profile!.fullName
              : 'Admin';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.admin_panel_settings,
                              color: Color.fromRGBO(0, 96, 243, 1),
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Welcome, $displayName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D0140),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Review all platform users, monitor system metrics, and manage any recruiter or lecturer job post from one dashboard.',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                _buildSectionHeader('System Overview'),
                SizedBox(height: 16),
                _buildMetricsGrid(metrics),
                SizedBox(height: 32),
                _buildSectionHeader('Quick Actions'),
                SizedBox(height: 16),
                _buildQuickActions(),
                SizedBox(height: 32),
                _buildSectionHeader('All Job Posts'),
                SizedBox(height: 16),
                _buildJobsOverviewCard(metrics),
                SizedBox(height: 32),
                _buildSectionHeader('User Management Summary'),
                SizedBox(height: 16),
                _buildUserManagementSummary(metrics),
                SizedBox(height: 32),
                _buildSectionHeader('System Health'),
                SizedBox(height: 16),
                _buildSystemHealthIndicators(metrics),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D0140),
      ),
    );
  }

  Widget _buildMetricsGrid(DashboardMetrics metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _metricCard('Total Users', metrics.users, Icons.people, Colors.blue),
        _metricCard(
            'Active Users', metrics.activeUsers, Icons.person, Colors.green),
        _metricCard('Students', metrics.students, Icons.school, Colors.orange),
        _metricCard(
            'Recruiters', metrics.recruiters, Icons.business, Colors.purple),
        _metricCard('Lecturers', metrics.lecturers, Icons.work, Colors.teal),
        _metricCard(
          'Pending Verifications',
          metrics.pendingLecturerVerifications,
          Icons.pending,
          Colors.amber,
        ),
        _metricCard(
            'Total Jobs', metrics.jobs, Icons.work_outline, Colors.indigo),
        _metricCard(
            'Open Jobs', metrics.openJobs, Icons.assignment, Colors.cyan),
        _metricCard('Applications', metrics.applications, Icons.description,
            Colors.pink),
      ],
    );
  }

  Widget _metricCard(String title, int value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _actionCard(
          'Manage Users',
          Icons.people,
          Colors.blue,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AdminUsersPage()),
          ),
        ),
        _actionCard(
          'All Job Posts',
          Icons.work_outline,
          Colors.green,
          _openAllJobPostsPage,
        ),
        _actionCard(
          'Post System Job',
          Icons.add_box,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddAjob(
                onSuccess: () => _refresh(),
              ),
            ),
          ),
        ),
        _actionCard(
          'Profile',
          Icons.person,
          Colors.purple,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          ),
        ),
      ],
    );
  }

  Widget _actionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D0140),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobsOverviewCard(DashboardMetrics metrics) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admins can review and delete any job post created by recruiters or lecturers.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child:
                      _adminStatPill('Total Jobs', metrics.jobs, Colors.indigo),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _adminStatPill(
                      'Open Jobs', metrics.openJobs, Colors.green),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAllJobPostsPage,
              icon: Icon(Icons.delete_outline),
              label: Text('Manage All Job Posts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminStatPill(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementSummary(DashboardMetrics metrics) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'User Management',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D0140),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildUserStatRow('Students', metrics.students, Colors.orange),
            _buildUserStatRow('Recruiters', metrics.recruiters, Colors.purple),
            _buildUserStatRow('Lecturers', metrics.lecturers, Colors.teal),
            Divider(height: 24),
            _buildUserStatRow(
              'Pending Lecturer Verifications',
              metrics.pendingLecturerVerifications,
              Colors.amber,
              isWarning: true,
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.manage_accounts),
                label: Text('Manage All Users'),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminUsersPage()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatRow(String label, int count, Color color,
      {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isWarning ? Colors.amber[800] : Colors.grey[700],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealthIndicators(DashboardMetrics metrics) {
    final healthScore = _calculateHealthScore(metrics);
    final healthColor = healthScore >= 80
        ? Colors.green
        : healthScore >= 60
            ? Colors.orange
            : Colors.red;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: healthColor),
                SizedBox(width: 8),
                Text(
                  'System Health',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D0140),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: healthScore / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(healthColor),
            ),
            SizedBox(height: 8),
            Text(
              'Health Score: ${healthScore.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: healthColor,
              ),
            ),
            SizedBox(height: 12),
            _buildHealthIndicator(
              'User Activity',
              metrics.users == 0 ? 0 : metrics.activeUsers / metrics.users,
              metrics.activeUsers > 0 ? 'Good' : 'Low',
            ),
            _buildHealthIndicator(
              'Job Availability',
              metrics.jobs == 0 ? 0 : metrics.openJobs / metrics.jobs,
              metrics.openJobs > 0 ? 'Good' : 'Low',
            ),
            _buildHealthIndicator(
              'Verification Backlog',
              1 -
                  (metrics.pendingLecturerVerifications /
                      (metrics.lecturers + 1)),
              metrics.pendingLecturerVerifications == 0 ? 'Clear' : 'Pending',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, double value, String status) {
    final color = value > 0.5
        ? Colors.green
        : value > 0.2
            ? Colors.orange
            : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateHealthScore(DashboardMetrics metrics) {
    double score = 0;

    if (metrics.users > 0) {
      score += 30 * (metrics.activeUsers / metrics.users);
    }
    if (metrics.jobs > 0) {
      score += 30 * (metrics.openJobs / metrics.jobs);
    }
    if (metrics.lecturers > 0) {
      score += 20 *
          (1 -
              (metrics.pendingLecturerVerifications / (metrics.lecturers + 1)));
    } else {
      score += 20;
    }
    if (metrics.jobs > 0) {
      score += 20 * (metrics.applications / (metrics.jobs * 5)).clamp(0, 1);
    }

    return score.clamp(0, 100);
  }
}

class _AdminAllJobPostsPage extends StatefulWidget {
  const _AdminAllJobPostsPage();

  @override
  State<_AdminAllJobPostsPage> createState() => _AdminAllJobPostsPageState();
}

class _AdminAllJobPostsPageState extends State<_AdminAllJobPostsPage> {
  late Future<List<AppJob>> _jobsFuture;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _jobsFuture = JobsService.instance.fetchJobs();
    AuthService.instance.syncProfile().then((profile) {
      if (mounted) {
        setState(() => _profile = profile);
      }
    });
  }

  void _refresh() {
    setState(() {
      _jobsFuture = JobsService.instance.fetchJobs();
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => SignInPage()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteJob(AppJob job) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Job Post'),
        content: Text('Delete "${job.title}" posted by ${job.postedByName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await JobsService.instance.deleteJob(job.id);
      if (!mounted) return;
      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job deleted. You can undo within 1 minute.'),
          duration: Duration(seconds: 60),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () async {
              try {
                await JobsService.instance.restoreJob(result.jobId);
                if (!mounted) return;
                _refresh();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Job restored successfully.')),
                );
              } catch (error) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Undo failed: $error')),
                );
              }
            },
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    }
  }

  Widget _buildDrawer() {
    final displayName =
        _profile?.fullName.isNotEmpty == true ? _profile!.fullName : 'Admin';

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(displayName),
              accountEmail: Text(_profile?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Color.fromRGBO(0, 96, 243, 1),
                ),
              ),
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 96, 243, 1),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.work_outline),
              title: Text('All Job Posts'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.people_outline),
              title: Text('Users'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminUsersPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                );
              },
            ),
            Spacer(),
            Divider(height: 1),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: FutureBuilder<List<AppJob>>(
        future: _jobsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 12),
                  Text('Failed to load job posts'),
                  SizedBox(height: 8),
                  Text('${snapshot.error}', textAlign: TextAlign.center),
                  SizedBox(height: 12),
                  ElevatedButton(onPressed: _refresh, child: Text('Retry')),
                ],
              ),
            );
          }

          final jobs = snapshot.data ?? [];
          if (jobs.isEmpty) {
            return Center(child: Text('No jobs available.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            separatorBuilder: (_, __) => SizedBox(height: 8),
            itemBuilder: (context, index) {
              final job = jobs[index];
              final postedBy = job.postedByName.isNotEmpty
                  ? job.postedByName
                  : job.postedByRole;
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    job.title,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${job.company} • ${job.location}\nPosted by $postedBy (${job.postedByRole})',
                  ),
                  isThreeLine: true,
                  trailing: SizedBox(
                    width: 132,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: job.status == 'open'
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            job.status == 'open' ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: job.status == 'open'
                                  ? Colors.green
                                  : Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Delete job post',
                          onPressed: () => _deleteJob(job),
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
