import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class JobSearchResults extends StatelessWidget {
  final String query;

  JobSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder<List<AppJob>>(
        future: JobsService.instance.fetchJobs(
          filter: JobsFilter(search: query),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load results'));
          }

          final jobs = snapshot.data ?? [];

          if (jobs.isEmpty) {
            return Center(child: Text('No jobs found'));
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return JobCard(
                jobId: job.id.toString(),
                timestamp: job.createdAt?.toLocal().toString() ?? '',
                jobTitle: job.title,
                company: job.company,
                location: job.location,
                employmentType: job.employmentType,
                description: job.description,
                posterId: job.postedByUid,
                email: job.postedByName,
              );
            },
          );
        },
      ),
    );
  }
}
