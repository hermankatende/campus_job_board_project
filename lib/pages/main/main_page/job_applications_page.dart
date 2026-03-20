// ignore_for_file: prefer_const_constructors

import 'package:cjb/services/applications_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationsPage extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobApplicationsPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
  });

  @override
  State<JobApplicationsPage> createState() => _JobApplicationsPageState();
}

class _JobApplicationsPageState extends State<JobApplicationsPage> {
  late Future<List<JobApplication>> _applicationsFuture;
  late Future<JobApplicationStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _applicationsFuture =
        ApplicationsService.instance.listApplicationsForJob(widget.jobId);
    _statsFuture =
        ApplicationsService.instance.getJobApplicationStats(widget.jobId);
  }

  Future<void> _changeStatus(JobApplication app, String status) async {
    try {
      await ApplicationsService.instance.updateStatus(
        applicationId: app.id,
        status: status,
      );
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $status')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status update failed: $error')),
      );
    }
  }

  Future<void> _deleteApplication(JobApplication app) async {
    try {
      await ApplicationsService.instance.deleteApplication(app.id);
      if (!mounted) return;
      setState(_reload);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application deleted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $error')),
      );
    }
  }

  Future<void> _openResume(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Applicants • ${widget.jobTitle}')),
      body: Column(
        children: [
          FutureBuilder<JobApplicationStats>(
            future: _statsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SizedBox.shrink();
              }
              final stats = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(12.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('Total', stats.totalApplicants),
                    _chip('New', stats.newApplications),
                    _chip('Shortlisted', stats.shortlisted),
                    _chip('Reviewed', stats.reviewed),
                    _chip('Rejected', stats.rejected),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<JobApplication>>(
              future: _applicationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child:
                          Text('Failed to load applicants: ${snapshot.error}'));
                }

                final apps = snapshot.data ?? [];
                if (apps.isEmpty) {
                  return Center(child: Text('No applications yet.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_reload);
                    await _applicationsFuture;
                  },
                  child: ListView.separated(
                    itemCount: apps.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return ListTile(
                        title: Text(app.applicantName.isEmpty
                            ? 'Unnamed Applicant'
                            : app.applicantName),
                        subtitle: Text(
                            'Program: ${app.applicantProgram.isEmpty ? 'N/A' : app.applicantProgram} • Status: ${app.status}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteApplication(app);
                            } else {
                              _changeStatus(app, value);
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                                value: 'reviewed',
                                child: Text('Mark Reviewed')),
                            PopupMenuItem(
                                value: 'shortlisted', child: Text('Shortlist')),
                            PopupMenuItem(
                                value: 'rejected', child: Text('Reject')),
                            PopupMenuItem(
                                value: 'applied',
                                child: Text('Reset to Applied')),
                            PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Application')),
                          ],
                        ),
                        onTap: () {
                          if (app.resumeUrl.isNotEmpty) {
                            _openResume(app.resumeUrl);
                          }
                        },
                      );
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

  Widget _chip(String title, int count) {
    return Chip(label: Text('$title: $count'));
  }
}
