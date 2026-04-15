// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cjb/pages/main/main_page/apply_page.dart';

class JobDescription extends StatefulWidget {
  final int jobId;
  final String jobTitle;
  final String company;
  final String location;
  final String employmentType;
  final String description;
  final String requirements;
  final String postedByName;
  final String imageUrl;

  const JobDescription({
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.description,
    required this.requirements,
    required this.postedByName,
    required this.imageUrl,
  });

  @override
  State<JobDescription> createState() => _JobDescriptionState();
}

class _JobDescriptionState extends State<JobDescription> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: _isSaved ? Colors.blue : Colors.black,
            ),
            onPressed: () {
              setState(() => _isSaved = !_isSaved);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isSaved ? 'Job saved' : 'Job removed from saved',
                    style: GoogleFonts.poppins(),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Header Section
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo/Image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[200],
                    ),
                    child: widget.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(Icons.business,
                                size: 40, color: Colors.grey),
                          )
                        : Icon(Icons.business, size: 40, color: Colors.grey),
                  ),
                  SizedBox(height: 16),

                  // Job Title
                  Text(
                    widget.jobTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Company Name
                  Text(
                    widget.company,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),

                  // Job Meta Info
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.employmentType,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 12, color: Colors.green[700]),
                            SizedBox(width: 4),
                            Text(
                              widget.location,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),
            Divider(height: 1),

            // Job Details
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About the Job Section
                  if (widget.description.isNotEmpty) ...[
                    _buildSection(
                      title: 'About This Job',
                      content: widget.description,
                    ),
                    SizedBox(height: 24),
                  ],

                  // Requirements Section
                  if (widget.requirements.isNotEmpty) ...[
                    _buildSection(
                      title: 'Requirements',
                      content: widget.requirements,
                    ),
                    SizedBox(height: 24),
                  ],

                  // Posted By
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Posted by',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          widget.postedByName,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16) +
            EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ApplyPage(jobId: widget.jobId),
              ),
            );
          },
          icon: Icon(Icons.send, size: 18),
          label: Text(
            'Apply Now',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 12),
        Text(
          content,
          style: GoogleFonts.poppins(
            fontSize: 14,
            height: 1.6,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

// Deprecated class for backwards compatibility
class Description extends StatelessWidget {
  final int jobId;
  final String jobTitle;
  final String company;
  final String location;
  final String employmentType;
  final String description;

  Description({
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return JobDescription(
      jobId: jobId,
      jobTitle: jobTitle,
      company: company,
      location: location,
      employmentType: employmentType,
      description: description,
      requirements: '',
      postedByName: '',
      imageUrl: '',
    );
  }
}
