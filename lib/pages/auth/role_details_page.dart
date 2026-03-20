// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/auth/preferences.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:flutter/material.dart';

class RoleDetailsPage extends StatefulWidget {
  final String role;

  const RoleDetailsPage({super.key, required this.role});

  @override
  State<RoleDetailsPage> createState() => _RoleDetailsPageState();
}

class _RoleDetailsPageState extends State<RoleDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _collegeController = TextEditingController();
  final _programController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _jobPreferenceController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _companyWebsiteController = TextEditingController();
  final _companyLocationController = TextEditingController();
  final _departmentController = TextEditingController();
  bool _saving = false;

  bool get _isStudent => widget.role == 'student';
  bool get _isRecruiter => widget.role == 'recruiter';
  bool get _isLecturer => widget.role == 'lecturer';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final profile = await AuthService.instance.completeOnboarding(
        role: widget.role,
        profileData: {
          'phone': _phoneController.text.trim(),
          'college': _collegeController.text.trim(),
          'program': _programController.text.trim(),
          'student_number': _studentNumberController.text.trim(),
          'job_preference': _jobPreferenceController.text.trim(),
          'company_name': _companyNameController.text.trim(),
          'company_description': _companyDescriptionController.text.trim(),
          'company_website': _companyWebsiteController.text.trim(),
          'company_location': _companyLocationController.text.trim(),
          'department': _departmentController.text.trim(),
        },
      );

      if (!mounted) return;

      if (_isLecturer) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Lecturer profile submitted. Verification email has been sent to the HOD.'),
          ),
        );
      }

      if (profile.isStudent) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SubscriptionScreen()),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainPage(
              firstName: profile.fullName,
              first_Name: profile.fullName,
            ),
          ),
          (route) => false,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _collegeController.dispose();
    _programController.dispose();
    _studentNumberController.dispose();
    _jobPreferenceController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _companyWebsiteController.dispose();
    _companyLocationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete ${widget.role} profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _input(_phoneController, 'Phone number'),
              if (_isStudent) ...[
                _input(_collegeController, 'College', required: true),
                _input(_programController, 'Program', required: true),
                _input(_studentNumberController, 'Student number',
                    required: true),
                _input(_jobPreferenceController, 'Job preference'),
              ],
              if (_isRecruiter) ...[
                _input(_companyNameController, 'Company name', required: true),
                _input(_companyDescriptionController, 'Company description',
                    maxLines: 4),
                _input(_companyWebsiteController, 'Company website'),
                _input(_companyLocationController, 'Company location'),
              ],
              if (_isLecturer) ...[
                _input(_departmentController, 'Department', required: true),
              ],
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
