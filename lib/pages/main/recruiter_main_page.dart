// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cjb/pages/main/create/add_job.dart';
import 'package:cjb/pages/main/main_page/job_applications_page.dart';
import 'package:cjb/pages/main/user_profile/profile_page.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class RecruiterMainPage extends StatefulWidget {
  const RecruiterMainPage({super.key});

  @override
  State<RecruiterMainPage> createState() => _RecruiterMainPageState();
}

class _RecruiterMainPageState extends State<RecruiterMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    _RecruiterDashboard(),
    AddAjob(onSuccess: () => setState(() => _currentIndex = 0)),
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

class _RecruiterDashboard extends StatefulWidget {
  @override
  State<_RecruiterDashboard> createState() => _RecruiterDashboardState();
}

class _RecruiterDashboardState extends State<_RecruiterDashboard> {
  late Future<List<AppJob>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = JobsService.instance.fetchMyJobs();
  }

  void _refresh() => setState(() {
        _jobsFuture = JobsService.instance.fetchMyJobs();
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Job Postings'),
        backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: FutureBuilder<List<AppJob>>(
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Post a Job'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
                        foregroundColor: Colors.white),
                  ),
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
                return _JobCard(job: job, onRefresh: _refresh);
              },
            ),
          );
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final AppJob job;
  final VoidCallback onRefresh;

  const _JobCard({required this.job, required this.onRefresh});

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
