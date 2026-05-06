// ignore_for_file: prefer_const_constructors

import 'package:cjb/services/applications_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class JobApplicationsPage extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  /// When true the viewer is a lecturer: they can view CVs and endorse
  /// applicants, but cannot change application status.
  final bool isLecturer;

  const JobApplicationsPage({
    super.key,
    required this.jobId,
    required this.jobTitle,
    this.isLecturer = false,
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

  Future<void> _toggleEndorse(JobApplication app) async {
    try {
      final result =
          await ApplicationsService.instance.endorseApplication(app.id);
      if (!mounted) return;
      setState(_reload);
      final msg = result['message'] ?? 'Done';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$msg')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Endorse failed: $error')),
      );
    }
  }

  Future<void> _openResume(String url) async {
    final candidates = _resumeUrlCandidates(url);

    for (final candidate in candidates) {
      final uri = Uri.tryParse(candidate);
      if (uri == null) continue;

      final openedExternal =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (openedExternal) return;

      final openedDefault =
          await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (openedDefault) return;

      final openedInApp = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (openedInApp) return;
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
    if (trimmed.isEmpty) return const [];

    var normalized = trimmed;
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }

    final lower = normalized.toLowerCase();
    final candidates = <String>[];

    final isCloudinary = lower.contains('res.cloudinary.com');
    final isDocument =
        lower.endsWith('.pdf') || lower.endsWith('.doc') || lower.endsWith('.docx');

    if (isCloudinary) {
      // Some presets generate authenticated/private delivery URLs that return 401.
      normalized = normalized
          .replaceFirst('/authenticated/', '/upload/')
          .replaceFirst('/private/', '/upload/');

      if (isDocument && normalized.contains('/image/upload/')) {
        normalized = normalized.replaceFirst('/image/upload/', '/raw/upload/');
      }
      if (!isDocument && normalized.contains('/raw/upload/')) {
        normalized = normalized.replaceFirst('/raw/upload/', '/image/upload/');
      }

      candidates.add(normalized);

      if (normalized.contains('/upload/')) {
        candidates
            .add(normalized.replaceFirst('/upload/', '/upload/fl_attachment/'));
      }

      if (normalized.contains('/image/upload/')) {
        candidates.add(normalized.replaceFirst('/image/upload/', '/raw/upload/'));
      }
      if (normalized.contains('/raw/upload/')) {
        candidates.add(normalized.replaceFirst('/raw/upload/', '/image/upload/'));
      }
    } else {
      candidates.add(normalized);
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
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(app.applicantName.isEmpty
                                  ? 'Unnamed Applicant'
                                  : app.applicantName),
                            ),
                            if (app.lecturerEndorsed)
                              Tooltip(
                                message: app.endorsedByName.isNotEmpty
                                    ? 'Endorsed by ${app.endorsedByName}'
                                    : 'Lecturer endorsed',
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade400),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified,
                                          size: 12,
                                          color: Colors.green.shade700),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Endorsed',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
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
                                // Lecturer endorse button
                                if (widget.isLecturer)
                                  TextButton.icon(
                                    onPressed: () => _toggleEndorse(app),
                                    icon: Icon(
                                      app.lecturerEndorsed
                                          ? Icons.verified
                                          : Icons.verified_outlined,
                                      size: 16,
                                      color: app.lecturerEndorsed
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    label: Text(
                                      app.lecturerEndorsed
                                          ? 'Remove endorsement'
                                          : 'Endorse',
                                      style: TextStyle(
                                        color: app.lecturerEndorsed
                                            ? Colors.green
                                            : Colors.grey.shade700,
                                      ),
                                    ),
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
                        // Only recruiters/admins see the status-change menu
                        trailing: widget.isLecturer
                            ? null
                            : PopupMenuButton<String>(
                                onSelected: (value) {
                                  _changeStatus(app, value);
                                },
                                itemBuilder: (_) => [
                                  PopupMenuItem(
                                      value: 'reviewed',
                                      child: Text('Mark Reviewed')),
                                  PopupMenuItem(
                                      value: 'shortlisted',
                                      child: Text('Shortlist')),
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
