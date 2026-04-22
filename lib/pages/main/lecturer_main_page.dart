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

  void _openMyJobPostingsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _LecturerMyJobPostingsPage(
          onPostJobTap: widget.onPostJobTap,
        ),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(),
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
                  _buildJobsOverviewCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_profile?.fullName ?? 'Lecturer'),
              accountEmail: Text(_profile?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, color: Color.fromRGBO(0, 96, 243, 1)),
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 96, 243, 1),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.work_outline),
              title: Text('My Job Postings'),
              onTap: () {
                Navigator.pop(context);
                _openMyJobPostingsPage();
              },
            ),
            ListTile(
              leading: Icon(Icons.add_box_outlined),
              title: Text('Post Job'),
              onTap: () {
                Navigator.pop(context);
                widget.onPostJobTap();
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
          'View Applications',
          Icons.people_outline,
          Colors.purple,
          _openMyJobPostingsPage,
        ),
      ],
    );
  }

  Widget _buildJobsOverviewCard() {
    return FutureBuilder<List<AppJob>>(
      future: _jobsFuture,
      builder: (context, snapshot) {
        final jobs = snapshot.data ?? [];
        final totalJobs = jobs.length;
        final activeJobs = jobs.where((job) => job.status == 'open').length;

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Open a dedicated page to review all lecturer job postings and applicants.',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _statItem('$totalJobs', 'Total Jobs')),
                    Expanded(child: _statItem('$activeJobs', 'Active')),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _openMyJobPostingsPage,
                  icon: Icon(Icons.open_in_new),
                  label: Text('Open My Job Postings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 96, 243, 1),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _LecturerMyJobPostingsPage extends StatefulWidget {
  final VoidCallback onPostJobTap;

  const _LecturerMyJobPostingsPage({required this.onPostJobTap});

  @override
  State<_LecturerMyJobPostingsPage> createState() =>
      _LecturerMyJobPostingsPageState();
}

class _LecturerMyJobPostingsPageState
    extends State<_LecturerMyJobPostingsPage> {
  late Future<List<AppJob>> _jobsFuture;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _refresh();
    AuthService.instance.syncProfile().then((profile) {
      if (mounted) {
        setState(() => _profile = profile);
      }
    });
  }

  void _refresh() {
    setState(() {
      _jobsFuture = JobsService.instance.fetchMyJobs();
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

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_profile?.fullName ?? 'Lecturer'),
              accountEmail: Text(_profile?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.school, color: Color.fromRGBO(0, 96, 243, 1)),
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 96, 243, 1),
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
              leading: Icon(Icons.work),
              title: Text('My Job Postings'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.add_box_outlined),
              title: Text('Post Job'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
                widget.onPostJobTap();
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
        title: const Text('My Job Postings'),
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
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 12),
                    Text('Failed to load jobs'),
                    SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    SizedBox(height: 12),
                    ElevatedButton(onPressed: _refresh, child: Text('Retry')),
                  ],
                ),
              ),
            );
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.work_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'No job postings yet',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your first job posting to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onPostJobTap();
                      },
                      icon: Icon(Icons.add),
                      label: Text('Post Job'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DashboardStat(
                          value: '${jobs.length}', label: 'Total Jobs'),
                      _DashboardStat(
                        value:
                            '${jobs.where((job) => job.status == 'open').length}',
                        label: 'Active',
                      ),
                      _DashboardStat(
                        value:
                            '${jobs.where((job) => job.status != 'open').length}',
                        label: 'Inactive',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...jobs.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: job.status == 'open'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          job.status == 'open' ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: job.status == 'open'
                                ? Colors.green
                                : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobApplicationsPage(
                              jobId: job.id,
                              jobTitle: job.title,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DashboardStat extends StatelessWidget {
  final String value;
  final String label;

  const _DashboardStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 96, 243, 1),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
