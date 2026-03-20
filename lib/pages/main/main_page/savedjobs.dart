import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class SavedJobsPage extends StatefulWidget {
  @override
  State<SavedJobsPage> createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  late Future<List<AppJob>> _future;

  @override
  void initState() {
    super.initState();
    _future = JobsService.instance.fetchSavedJobs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Jobs'),
      ),
      body: FutureBuilder<List<AppJob>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Failed to load saved jobs'));
          }

          final savedJobs = snapshot.data ?? [];

          if (savedJobs.isEmpty) {
            return Center(child: Text('No saved jobs found'));
          }

          return ListView.builder(
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              final job = savedJobs[index];

              return Dismissible(
                key: Key(job.id.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) async {
                  try {
                    await JobsService.instance.unsaveJob(job.id);
                  } catch (_) {}
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job removed from saved list')),
                  );
                },
                child: JobCard(
                  jobId: job.id.toString(),
                  jobTitle: job.title,
                  company: job.company,
                  location: job.location,
                  employmentType: job.employmentType,
                  timestamp: job.createdAt?.toLocal().toString() ?? '',
                  description: job.description,
                  posterId: job.postedByUid,
                  email: job.postedByName,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
