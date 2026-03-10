import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobSearchResults extends StatelessWidget {
  final String query;

  JobSearchResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _searchJobs(query),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final jobs = snapshot.data!;

          if (jobs.isEmpty) {
            return Center(child: Text('No jobs found'));
          }

          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              var job = jobs[index];
              return JobCard(
                jobId: job.id, // Document ID as jobId
                timestamp: job['timestamp'].toDate().toString(),
                jobTitle: job['title'],
                company: job['company'],
                location: job['location'],
                employmentType: job['employmentType'],
                description: job['description'],
                posterId: job['posterId'],
                email: job['email'],
              );
            },
          );
        },
      ),
    );
  }

  Future<List<DocumentSnapshot>> _searchJobs(String query) async {
    final nameQuerySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final categoryQuerySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('category', isGreaterThanOrEqualTo: query)
        .where('category', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    final allResults = nameQuerySnapshot.docs + categoryQuerySnapshot.docs;

    // Remove duplicates
    final seen = Set<String>();
    final uniqueResults = allResults.where((doc) => seen.add(doc.id)).toList();

    return uniqueResults;
  }
}
