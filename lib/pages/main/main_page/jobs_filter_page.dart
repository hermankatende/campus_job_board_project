// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobsFilterPage extends StatefulWidget {
  const JobsFilterPage({super.key});

  @override
  State<JobsFilterPage> createState() => _JobsFilterPageState();
}

class _JobsFilterPageState extends State<JobsFilterPage> {
  final _jobsService = JobsService.instance;
  final TextEditingController _searchController = TextEditingController();

  String _employmentType = '';
  String _postedByRole = '';
  bool _remoteOnly = false;

  late Future<List<AppJob>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
  }

  Future<List<AppJob>> _loadJobs() {
    return _jobsService.fetchJobs(
      filter: JobsFilter(
        search: _searchController.text,
        employmentType: _employmentType,
        postedByRole: _postedByRole,
        remoteOnly: _remoteOnly,
      ),
    );
  }

  void _applyFilters() {
    setState(() {
      _jobsFuture = _loadJobs();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _employmentType = '';
      _postedByRole = '';
      _remoteOnly = false;
      _jobsFuture = _loadJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Browse Jobs',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  decoration: InputDecoration(
                    hintText: 'Search jobs by title...',
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                SizedBox(height: 16),

                // Filter Row 1: Employment Type and Posted By
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _employmentType.isEmpty ? null : _employmentType,
                        decoration: InputDecoration(
                          labelText: 'Employment Type',
                          labelStyle: GoogleFonts.poppins(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['full-time', 'part-time', 'internship']
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v, style: GoogleFonts.poppins()),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _employmentType = v ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _postedByRole.isEmpty ? null : _postedByRole,
                        decoration: InputDecoration(
                          labelText: 'Posted By',
                          labelStyle: GoogleFonts.poppins(fontSize: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: ['recruiter', 'lecturer']
                            .map((v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v, style: GoogleFonts.poppins()),
                                ))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _postedByRole = v ?? '');
                          _applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Remote Filter and Clear Button
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _remoteOnly,
                            onChanged: (v) {
                              setState(() => _remoteOnly = v ?? false);
                              _applyFilters();
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          Text(
                            'Remote Only',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    if (_employmentType.isNotEmpty ||
                        _postedByRole.isNotEmpty ||
                        _remoteOnly ||
                        _searchController.text.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: _clearFilters,
                        icon: Icon(Icons.clear, size: 16),
                        label: Text('Clear', style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: FutureBuilder<List<AppJob>>(
              future: _jobsFuture,
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
                          'Error loading jobs',
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

                final jobs = snapshot.data ?? [];
                if (jobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No jobs found',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _jobsFuture = _loadJobs());
                    await _jobsFuture;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(12),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return JobCard(
                        jobId: job.id.toString(),
                        timestamp: job.createdAt?.toIso8601String() ?? '',
                        jobTitle: job.title,
                        company: job.company,
                        location: job.location,
                        employmentType: job.employmentType,
                        description: job.description,
                        posterId: job.postedByUid,
                        email: '',
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
}
