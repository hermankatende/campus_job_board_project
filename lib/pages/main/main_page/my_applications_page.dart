// ignore_for_file: prefer_const_constructors

import 'package:cjb/services/applications_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  late Future<List<JobApplication>> _appsFuture;

  @override
  void initState() {
    super.initState();
    _appsFuture = ApplicationsService.instance.listMyApplications();
  }

  Future<void> _openResume(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Applications')),
      body: FutureBuilder<List<JobApplication>>(
        future: _appsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Failed to load applications: ${snapshot.error}'));
          }

          final apps = snapshot.data ?? [];
          if (apps.isEmpty) {
            return Center(child: Text('You have not applied to any jobs yet.'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _appsFuture = ApplicationsService.instance.listMyApplications();
              });
              await _appsFuture;
            },
            child: ListView.separated(
              itemCount: apps.length,
              separatorBuilder: (_, __) => Divider(height: 1),
              itemBuilder: (context, index) {
                final app = apps[index];
                return ListTile(
                  title: Text(app.jobTitle),
                  subtitle: Text('Status: ${app.status}'),
                  trailing: app.resumeUrl.isNotEmpty
                      ? TextButton(
                          onPressed: () => _openResume(app.resumeUrl),
                          child: Text('Resume'),
                        )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
