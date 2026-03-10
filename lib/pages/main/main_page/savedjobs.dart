import 'package:cjb/pages/main/main_page/jobcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SavedJobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text('No user logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Jobs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('saved_jobs')
            .doc(currentUser.uid)
            .collection('user_saved_jobs')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No saved jobs found'));
          }

          final savedJobs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedJobs.length,
            itemBuilder: (context, index) {
              final jobDoc = savedJobs[index];
              final job = jobDoc.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(jobDoc.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  // Delete the job from the user's saved jobs list
                  FirebaseFirestore.instance
                      .collection('saved_jobs')
                      .doc(currentUser.uid)
                      .collection('user_saved_jobs')
                      .doc(jobDoc.id)
                      .delete();

                  // Show a snackbar to confirm deletion
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Job removed from saved list')),
                  );
                },
                child: JobCard(
                  jobId: job['jobId'],
                  jobTitle: job['jobTitle'],
                  company: job['company'],
                  location: job['location'],
                  employmentType: job['employmentType'],
                  timestamp: job['timestamp'],
                  description: job['description'],
                  posterId: job['posterId'],
                  email: job['email'],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
