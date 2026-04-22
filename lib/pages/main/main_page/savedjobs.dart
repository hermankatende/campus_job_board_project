import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';

class SavedJobsPage extends StatefulWidget {
  @override
  State<SavedJobsPage> createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  late Future<List<AppJob>> _future;
  List<AppJob> _savedJobs = [];

  @override
  void initState() {
    super.initState();
    _future = _loadSavedJobs();
  }

  Future<List<AppJob>> _loadSavedJobs() async {
    final jobs = await JobsService.instance.fetchSavedJobs();
    _savedJobs = jobs;
    return jobs;
  }

  Future<void> _removeSavedJob(AppJob job) async {
    final previousJobs = List<AppJob>.from(_savedJobs);
    setState(() {
      _savedJobs.removeWhere((savedJob) => savedJob.id == job.id);
    });

    try {
      await JobsService.instance.unsaveJob(job.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job removed from saved list')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _savedJobs = previousJobs;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove saved job')),
      );
    }
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

          if (snapshot.hasData && _savedJobs.isEmpty) {
            _savedJobs = snapshot.data!;
          }

          if (_savedJobs.isEmpty) {
            return Center(child: Text('No saved jobs found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              final jobs = await _loadSavedJobs();
              if (!mounted) return;
              setState(() {
                _savedJobs = jobs;
              });
            },
            child: ListView.builder(
              itemCount: _savedJobs.length,
              itemBuilder: (context, index) {
                final job = _savedJobs[index];

                return Dismissible(
                  key: Key(job.id.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) => _removeSavedJob(job),
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
            ),
          );
        },
      ),
    );
  }
}
