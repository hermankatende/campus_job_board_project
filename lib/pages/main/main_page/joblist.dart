// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class JobsList extends StatefulWidget {
  @override
  State<JobsList> createState() => _JobsListState();
}

class _JobsListState extends State<JobsList> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MainPage(firstName: '', first_Name: ''),
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
        ),
        title: Center(child: Text('Job Listings')),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search jobs',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: _applyFilters,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _employmentType.isEmpty ? null : _employmentType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: ['full-time', 'part-time', 'internship']
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _employmentType = v ?? ''),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _postedByRole.isEmpty ? null : _postedByRole,
                        decoration: InputDecoration(
                          labelText: 'Posted by',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        items: ['recruiter', 'lecturer']
                            .map((v) =>
                                DropdownMenuItem(value: v, child: Text(v)))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _postedByRole = v ?? ''),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _remoteOnly,
                      onChanged: (v) =>
                          setState(() => _remoteOnly = v ?? false),
                    ),
                    Text('Remote only'),
                    Spacer(),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: Text('Apply'),
                    ),
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AppJob>>(
              future: _jobsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final jobs = snapshot.data ?? [];
                if (jobs.isEmpty) {
                  return Center(child: Text('No job postings available.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _jobsFuture = _loadJobs());
                    await _jobsFuture;
                  },
                  child: ListView.builder(
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
