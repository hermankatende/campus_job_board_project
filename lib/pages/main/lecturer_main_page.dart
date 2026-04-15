import 'package:cjb/pages/auth/sign_in_page.dart';
import 'package:cjb/pages/main/create/add_job.dart';
import 'package:cjb/pages/main/create/picker.dart';
import 'package:cjb/pages/main/main_page/job_applications_page.dart';
import 'package:cjb/pages/main/user_profile/profile_page.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class LecturerMainPage extends StatefulWidget {
  const LecturerMainPage({super.key});

  @override
  State<LecturerMainPage> createState() => _LecturerMainPageState();
}

class _LecturerMainPageState extends State<LecturerMainPage> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      _LecturerDashboard(onPostJobTap: () => setState(() => _currentIndex = 1)),
      AddAjob(onSuccess: () => setState(() => _currentIndex = 0)),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(0, 96, 243, 1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post Job'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _LecturerDashboard extends StatefulWidget {
  final VoidCallback onPostJobTap;

  const _LecturerDashboard({required this.onPostJobTap});

  @override
  State<_LecturerDashboard> createState() => _LecturerDashboardState();
}

class _LecturerDashboardState extends State<_LecturerDashboard> {
  late Future<List<AppJob>> _jobsFuture;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _jobsFuture = JobsService.instance.fetchMyJobs();
    AuthService.instance.syncProfile().then((p) {
      if (mounted) setState(() => _profile = p);
    });
  }

  void _refresh() => setState(() {
        _jobsFuture = JobsService.instance.fetchMyJobs();
      });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Verification status banner - only for lecturers
          if (_profile != null && !_profile!.isVerified)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.pending_outlined,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Your account is pending verification by admin. '
                      'You can still post jobs.',
                      style: TextStyle(color: Colors.orange, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  _buildWelcomeSection(),

                  const SizedBox(height: 24),

                  // Quick Actions Section
                  _buildSectionHeader('Quick Actions'),
                  const SizedBox(height: 16),
                  _buildQuickActions(),

                  const SizedBox(height: 24),

                  // My Jobs Section
                  _buildSectionHeader('My Job Postings'),
                  const SizedBox(height: 16),
                  _buildJobsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
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
                Icon(Icons.school,
                    color: Color.fromRGBO(0, 96, 243, 1), size: 28),
                SizedBox(width: 12),
                Text(
                  'Welcome, ${_profile?.fullName ?? 'Lecturer'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D0140),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Manage your job postings and track applications from students.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0D0140),
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
          'Post New Job',
          Icons.add_box,
          Colors.blue,
          widget.onPostJobTap,
        ),
        _actionCard(
          'Create Post',
          Icons.post_add,
          Colors.green,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreatePostPage()),
          ),
        ),
        _actionCard(
          'My Profile',
          Icons.person,
          Colors.orange,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProfilePage()),
          ),
        ),
        _actionCard(
          'Job Analytics',
          Icons.analytics,
          Colors.purple,
          () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Analytics feature coming soon')),
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

  Widget _buildJobsSection() {
    return FutureBuilder<List<AppJob>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  SizedBox(height: 12),
                  Text(
                    'Failed to load jobs',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final jobs = snapshot.data ?? [];
        if (jobs.isEmpty) {
          return Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  Icon(Icons.work_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No job postings yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create your first job posting to get started',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Post Your First Job'),
                    onPressed: widget.onPostJobTap,
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

        return ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: jobs.length,
          separatorBuilder: (_, __) => SizedBox(height: 8),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                title: Text(
                  job.title,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${job.company} • ${job.location}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: job.status == 'open'
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    job.status == 'open' ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: job.status == 'open' ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () {
                  // Navigate to job details/applications
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => JobApplicationsPage(
                            jobId: job.id, jobTitle: job.title)),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
