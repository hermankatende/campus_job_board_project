// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cjb/pages/main/main_page/apply_page.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:cjb/services/subscriptions_service.dart';

class JobDescription extends StatefulWidget {
  final int jobId;
  final String jobTitle;
  final String company;
  final String location;
  final String employmentType;
  final String description;
  final String requirements;
  final String postedByName;
  final String postedByRole;
  final String imageUrl;
  // Recruiter contact — populated when a lecturer posts on behalf of a recruiter
  final String recruiterContactName;
  final String recruiterContactEmail;
  final String recruiterContactPhone;
  final String recruiterContactCompany;
  final String category;

  const JobDescription({
    required this.jobId,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.description,
    required this.requirements,
    required this.postedByName,
    this.postedByRole = '',
    required this.imageUrl,
    this.recruiterContactName = '',
    this.recruiterContactEmail = '',
    this.recruiterContactPhone = '',
    this.recruiterContactCompany = '',
    this.category = '',
  });

  @override
  State<JobDescription> createState() => _JobDescriptionState();
}

class _JobDescriptionState extends State<JobDescription> {
  bool _isSaved = false;
  bool _isSaving = false;
  bool _isSubscribed = false;
  bool _isTogglingSubscription = false;
  bool _isStudent = false;

  @override
  void initState() {
    super.initState();
    _loadSavedState();
    _loadSubscriptionState();
  }

  Future<void> _loadSavedState() async {
    try {
      final savedJobs = await JobsService.instance.fetchSavedJobs();
      if (!mounted) return;
      setState(() {
        _isSaved = savedJobs.any((job) => job.id == widget.jobId);
      });
    } catch (_) {
      // Ignore initial saved-state errors and keep the page usable.
    }
  }

  Future<void> _loadSubscriptionState() async {
    final profile = AuthService.instance.currentProfile;
    if (profile == null || !profile.isStudent || widget.category.isEmpty) return;
    setState(() => _isStudent = true);
    try {
      final cats = await SubscriptionsService.instance.getSubscriptions();
      if (!mounted) return;
      setState(() {
        _isSubscribed =
            cats.any((c) => c.toLowerCase() == widget.category.toLowerCase());
      });
    } catch (_) {}
  }

  Future<void> _toggleSubscription() async {
    if (_isTogglingSubscription || widget.category.isEmpty) return;
    setState(() => _isTogglingSubscription = true);
    try {
      final (nowSubscribed, _) =
          await SubscriptionsService.instance.toggle(widget.category);
      if (!mounted) return;
      setState(() => _isSubscribed = nowSubscribed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nowSubscribed
                ? 'Subscribed to "${widget.category}" jobs'
                : 'Unsubscribed from "${widget.category}" jobs',
            style: GoogleFonts.poppins(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not update subscription: $e',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isTogglingSubscription = false);
    }
  }

  Future<void> _toggleSavedState() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      if (_isSaved) {
        await JobsService.instance.unsaveJob(widget.jobId);
      } else {
        await JobsService.instance.saveJob(widget.jobId);
      }

      if (!mounted) return;
      setState(() => _isSaved = !_isSaved);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isSaved ? 'Job removed from saved jobs' : 'Job saved',
            style: GoogleFonts.poppins(),
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update saved jobs: $error',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

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
            onPressed: _isSaving ? null : _toggleSavedState,
          ),
          // Subscribe bell — only shown for students
          if (_isStudent && widget.category.isNotEmpty)
            _isTogglingSubscription
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    tooltip: _isSubscribed
                        ? 'Unsubscribe from ${widget.category} jobs'
                        : 'Subscribe to ${widget.category} jobs',
                    icon: Icon(
                      _isSubscribed
                          ? Icons.notifications_active
                          : Icons.notifications_none,
                      color: _isSubscribed ? Colors.orange : Colors.black,
                    ),
                    onPressed: _toggleSubscription,
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

                  // Recruiter contact card — shown for lecturer-brokered jobs
                  if (widget.postedByRole == 'lecturer' &&
                      widget.recruiterContactName.trim().isNotEmpty) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.business_center,
                                  size: 16, color: Colors.blue.shade700),
                              SizedBox(width: 6),
                              Text(
                                'Recruiter Contact',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          if (widget.recruiterContactName.trim().isNotEmpty)
                            _contactRow(
                                Icons.person, widget.recruiterContactName),
                          if (widget.recruiterContactCompany.trim().isNotEmpty)
                            _contactRow(
                                Icons.business, widget.recruiterContactCompany),
                          if (widget.recruiterContactEmail.trim().isNotEmpty)
                            _contactRow(
                                Icons.email, widget.recruiterContactEmail),
                          if (widget.recruiterContactPhone.trim().isNotEmpty)
                            _contactRow(
                                Icons.phone, widget.recruiterContactPhone),
                        ],
                      ),
                    ),
                  ],
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

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        ],
      ),
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
      category: '',
      location: location,
      employmentType: employmentType,
      description: description,
      requirements: '',
      postedByName: '',
      imageUrl: '',
    );
  }
}
