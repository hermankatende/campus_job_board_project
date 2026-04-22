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

  Future<void> _openResume(String url) async {
    final candidates = _resumeUrlCandidates(url);

    for (final candidate in candidates) {
      final uri = Uri.tryParse(candidate);
      if (uri == null) continue;

      final openedInApp = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (openedInApp) return;

      final openedExternal =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (openedExternal) return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unable to open this resume link. Please ask the applicant to re-upload the CV.',
        ),
      ),
    );
  }

  List<String> _resumeUrlCandidates(String url) {
    final trimmed = url.trim();
    final candidates = <String>[trimmed];
    final lower = trimmed.toLowerCase();

    final isCloudinary = lower.contains('res.cloudinary.com');

    if (isCloudinary) {
      if (trimmed.contains('/image/upload/')) {
        candidates.add(trimmed.replaceFirst('/image/upload/', '/raw/upload/'));
      }
      if (trimmed.contains('/raw/upload/')) {
        candidates.add(trimmed.replaceFirst('/raw/upload/', '/image/upload/'));
      }
      if (trimmed.contains('/upload/')) {
        candidates
            .add(trimmed.replaceFirst('/upload/', '/upload/fl_attachment/'));
      }
    }

    return candidates.toSet().toList();
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
                      final hasResume = app.resumeUrl.trim().isNotEmpty;

                      return ListTile(
                        title: Text(app.applicantName.isEmpty
                            ? 'Unnamed Applicant'
                            : app.applicantName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Program: ${app.applicantProgram.isEmpty ? 'N/A' : app.applicantProgram} • Status: ${app.status}',
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app.applicantEmail.isEmpty
                                  ? 'Email: N/A'
                                  : 'Email: ${app.applicantEmail}',
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  hasResume ? 'CV uploaded' : 'No CV uploaded',
                                  style: TextStyle(
                                    color:
                                        hasResume ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (hasResume)
                                  TextButton.icon(
                                    onPressed: () => _openResume(app.resumeUrl),
                                    icon:
                                        const Icon(Icons.attach_file, size: 16),
                                    label: const Text('View CV'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 0,
                                      ),
                                      minimumSize: const Size(0, 32),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            _changeStatus(app, value);
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
                          ],
                        ),
                        onTap:
                            hasResume ? () => _openResume(app.resumeUrl) : null,
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
