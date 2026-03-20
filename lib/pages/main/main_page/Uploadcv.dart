// ignore_for_file: file_names, camel_case_types, use_super_parameters, prefer_const_constructors

import 'package:cjb/pages/main/main_page/joblist.dart';
import 'package:cjb/services/applications_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CV_page extends StatefulWidget {
  final int jobId;

  const CV_page({Key? key, required this.jobId}) : super(key: key);

  @override
  State<CV_page> createState() => _CV_pageState();
}

class _CV_pageState extends State<CV_page> {
  final _coverLetterController = TextEditingController();
  final _resumeUrlController = TextEditingController();
  bool _submitting = false;

  Future<void> _submitApplication() async {
    if (_submitting) return;

    setState(() => _submitting = true);
    try {
      await ApplicationsService.instance.applyToJob(
        jobId: widget.jobId,
        coverLetter: _coverLetterController.text.trim(),
        resumeUrl: _resumeUrlController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully.')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => JobsList()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit application: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _coverLetterController.dispose();
    _resumeUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Apply for Job'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Details',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF150B3D),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _resumeUrlController,
              decoration: InputDecoration(
                labelText: 'Resume URL (optional)',
                hintText: 'https://.../my-resume.pdf',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _coverLetterController,
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Cover Letter (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitApplication,
                child: _submitting
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('Submit Application'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
