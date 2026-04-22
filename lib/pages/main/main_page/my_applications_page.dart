// ignore_for_file: prefer_const_constructors

import 'package:cjb/services/applications_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  late Future<List<JobApplication>> _appsFuture;
  String _selectedFilter =
      'all'; // all, applied, reviewed, shortlisted, accepted, rejected

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  void _loadApplications() {
    _appsFuture = _selectedFilter == 'all'
        ? ApplicationsService.instance.listMyApplications()
        : ApplicationsService.instance
            .listMyApplications(status: _selectedFilter);
  }

  Future<void> _openResume(String url) async {
    final candidates = _resumeUrlCandidates(url);

    for (final candidate in candidates) {
      final uri = Uri.tryParse(candidate);
      if (uri == null) continue;

      final isReachable = await _isReachable(uri);
      if (!isReachable) continue;

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (opened) return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to open this resume URL')),
    );
  }

  List<String> _resumeUrlCandidates(String url) {
    final trimmed = url.trim();
    final candidates = <String>[trimmed];
    final lower = trimmed.toLowerCase();

    final isCloudinary = lower.contains('res.cloudinary.com');
    final isDocument = lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx');

    if (isCloudinary && isDocument) {
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

  Future<bool> _isReachable(Uri uri) async {
    try {
      final response = await http.get(uri,
          headers: {'Range': 'bytes=0-0'}).timeout(const Duration(seconds: 12));
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Colors.blue;
      case 'reviewed':
        return Colors.orange;
      case 'shortlisted':
        return Colors.purple;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'applied':
        return Icons.assignment_turned_in;
      case 'reviewed':
        return Icons.fact_check;
      case 'shortlisted':
        return Icons.star;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'My Applications',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Status Filter Chips
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('all', 'All'),
                  _buildFilterChip('applied', 'Applied'),
                  _buildFilterChip('reviewed', 'Reviewed'),
                  _buildFilterChip('shortlisted', 'Shortlisted'),
                  _buildFilterChip('accepted', 'Accepted'),
                  _buildFilterChip('rejected', 'Rejected'),
                ],
              ),
            ),
          ),
          Divider(height: 1),

          // Applications List
          Expanded(
            child: FutureBuilder<List<JobApplication>>(
              future: _appsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Failed to load applications',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final apps = snapshot.data ?? [];
                if (apps.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_ind,
                            size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No applications yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Apply to jobs to track your applications here',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _loadApplications());
                    await _appsFuture;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: apps.length,
                    itemBuilder: (context, index) {
                      final app = apps[index];
                      return _buildApplicationCard(app);
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

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = value;
            _loadApplications();
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildApplicationCard(JobApplication app) {
    final statusColor = _getStatusColor(app.status);
    final statusIcon = _getStatusIcon(app.status);
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate =
        app.createdAt != null ? dateFormat.format(app.createdAt!) : 'Recently';

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showApplicationDetails(app),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Title and Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.jobTitle,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            app.applicantProgram,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          SizedBox(width: 4),
                          Text(
                            app.status.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Meta Info
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      'Applied $formattedDate',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),

                if (app.coverLetter.isNotEmpty) ...[
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      app.coverLetter,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],

                // Action Buttons
                SizedBox(height: 12),
                Row(
                  children: [
                    if (app.resumeUrl.isNotEmpty) ...[
                      TextButton.icon(
                        onPressed: () => _openResume(app.resumeUrl),
                        icon: Icon(Icons.download, size: 16),
                        label: Text(
                          'Resume',
                          style: GoogleFonts.poppins(fontSize: 11),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                    TextButton.icon(
                      onPressed: () => _showApplicationDetails(app),
                      icon: Icon(Icons.info_outline, size: 16),
                      label: Text(
                        'Details',
                        style: GoogleFonts.poppins(fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        padding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showApplicationDetails(JobApplication app) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Application Details',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            Divider(height: 20),
            _buildDetailRow('Job Title', app.jobTitle),
            _buildDetailRow(
              'Status',
              app.status,
              valueColor: _getStatusColor(app.status),
            ),
            _buildDetailRow(
              'Applied On',
              app.createdAt != null
                  ? DateFormat('MMM d, yyyy - hh:mm a').format(app.createdAt!)
                  : 'Unknown',
            ),
            _buildDetailRow('Program', app.applicantProgram),
            _buildDetailRow('Email', app.applicantEmail),
            if (app.coverLetter.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Cover Letter',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                app.coverLetter,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
