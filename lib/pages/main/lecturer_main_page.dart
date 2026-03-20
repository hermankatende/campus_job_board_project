// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cjb/pages/main/create/add_job.dart';
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

  final List<Widget> _pages = [
    _LecturerDashboard(),
    AddAjob(),
    ProfilePage(),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: Column(
        children: [
          // Verification status banner
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
            child: FutureBuilder<List<AppJob>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text('${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _refresh, child: const Text('Retry')),
                      ],
                    ),
                  );
                }
                final jobs = snapshot.data ?? [];
                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.work_off_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No jobs posted yet.',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return _LecturerJobCard(job: job, onRefresh: _refresh);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LecturerJobCard extends StatelessWidget {
  final AppJob job;
  final VoidCallback onRefresh;

  const _LecturerJobCard({required this.job, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(job.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: job.status == 'open'
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    job.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: job.status == 'open'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${job.company} • ${job.location}',
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(job.employmentType,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.people_outline),
                label: const Text('View Applicants'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobApplicationsPage(
                          jobId: job.id, jobTitle: job.title),
                    ),
                  ).then((_) => onRefresh());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
