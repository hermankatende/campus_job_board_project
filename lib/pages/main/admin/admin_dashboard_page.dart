// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/main/admin/admin_users_page.dart';
import 'package:cjb/services/admin_service.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late Future<DashboardMetrics> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _metricsFuture = AdminService.instance.getMetrics();
  }

  void _refresh() {
    setState(() {
      _metricsFuture = AdminService.instance.getMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(onPressed: _refresh, icon: Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<DashboardMetrics>(
        future: _metricsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load metrics: ${snapshot.error}'));
          }

          final m = snapshot.data;
          if (m == null) return Center(child: Text('No metrics available'));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _metricCard('Total Users', m.users),
                    _metricCard('Active Users', m.activeUsers),
                    _metricCard('Students', m.students),
                    _metricCard('Recruiters', m.recruiters),
                    _metricCard('Lecturers', m.lecturers),
                    _metricCard('Pending Lecturer Verifications',
                        m.pendingLecturerVerifications),
                    _metricCard('Total Jobs', m.jobs),
                    _metricCard('Open Jobs', m.openJobs),
                    _metricCard('Applications', m.applications),
                  ],
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.group),
                    label: Text('Open Users Pane'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminUsersPage()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _metricCard(String title, int value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            SizedBox(height: 8),
            Text('$value',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
