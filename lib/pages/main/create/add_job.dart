// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_null_comparison, prefer_const_constructors, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, use_build_context_synchronously, avoid_unnecessary_containers

import 'dart:io';

import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/main/notifications/notification_services.dart';
import 'package:cjb/services/cloudinary_upload_service.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAjob extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddAjob({Key? key, this.onSuccess}) : super(key: key);

  @override
  _AddAjobState createState() => _AddAjobState();
}

class _AddAjobState extends State<AddAjob> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController employmentTypeController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();

  String selectedCategory = '';
  String selectedEmploymentType = '';
  String selectedWorkType = '';

  final NotificationService _notificationService = NotificationService();
  final JobsService _jobsService = JobsService.instance;
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isPosting = false;

  Future<void> _notifyUsers(String jobCategory) async {
    // Notification fan-out is now handled server-side.
    // Keep this method to preserve current call flow.
    await _notificationService.sendNotificationsToSubscribers(jobCategory, []);
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await GlobalVariables().loadUserData();
    setState(() {});
  }

  Future<void> _pickPostImage() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null || !mounted) {
        return;
      }

      setState(() {
        _selectedImage = File(file.path);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $error')),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    locationController.dispose();
    companyController.dispose();
    employmentTypeController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (Navigator.of(context).canPop())
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                else
                  const SizedBox(width: 48),
                Text(
                  'Post',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFFFF9228),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Text(
              'Add a job',
              style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF150B3D),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                buildInputField(
                  context,
                  'Job title',
                  'rectangle_5928_x2.svg',
                  titleController,
                ),
                SizedBox(height: 30),
                buildCategoryInputField(context),
                SizedBox(height: 30),
                buildInputField(
                  context,
                  'Job location',
                  'rectangle_16229_x2.svg',
                  locationController,
                ),
                SizedBox(height: 30),
                buildInputField(
                  context,
                  'Company',
                  'rectangle_16224_x2.svg',
                  companyController,
                ),
                SizedBox(height: 30),
                buildEmploymentTypeInputField(context),
                SizedBox(height: 30),
                buildInputField(
                  context,
                  'Description',
                  'rectangle_5928_x2.svg',
                  descriptionController,
                ),
                SizedBox(height: 30),
                _buildImagePicker(),
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isPosting
                  ? null
                  : () async {
                      final bool posted = await postJob();
                      if (posted) {
                        await _notifyUsers(selectedCategory);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9228),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              ),
              child: _isPosting
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Post Job',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<bool> postJob() async {
    if (_isPosting) return false;

    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        companyController.text.isEmpty ||
        employmentTypeController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        categoryController.text.isEmpty) {
      // Show an error message if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return false;
    }

    setState(() => _isPosting = true);

    try {
      String imageUrl = '';
      if (_selectedImage != null) {
        imageUrl = await CloudinaryUploadService.uploadFile(
          filePath: _selectedImage!.path,
          resourceType: 'image',
          folder: 'job-posts',
        );
      }

      await _jobsService.createJob(
        title: titleController.text,
        location: locationController.text,
        company: companyController.text,
        employmentType: employmentTypeController.text,
        description: descriptionController.text,
        category: categoryController.text,
        imageUrl: imageUrl,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to post job: $e')),
      );
      setState(() => _isPosting = false);
      return false;
    }

    // Clear the text fields
    titleController.clear();
    locationController.clear();
    companyController.clear();
    employmentTypeController.clear();
    descriptionController.clear();
    categoryController.clear();
    setState(() {
      _selectedImage = null;
      _isPosting = false;
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job posted successfully!'),
      ),
    );

    if (widget.onSuccess != null) {
      widget.onSuccess!();
      return true;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    return true;
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post image',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: Color(0xFF150B3D),
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: _isPosting ? null : _pickPostImage,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _selectedImage!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Row(
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: Colors.grey.shade700),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tap to add an optional image to the job post.',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_selectedImage != null) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedImage!.path.split('\\').last,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: _isPosting
                            ? null
                            : () {
                                setState(() => _selectedImage = null);
                              },
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInputField(BuildContext context, String labelText,
      String svgAsset, TextEditingController controller) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                labelText,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF150B3D),
                ),
              ),
              Spacer(),
              GestureDetector(
                child: Icon(Icons.add),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Enter $labelText',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF150B3D),
                                  ),
                                ),
                                SizedBox(height: 20),
                                buildGrowingTextField(
                                  labelText,
                                  controller,
                                  (value) {
                                    setState(() {
                                      controller.text = value;
                                    });
                                  },
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        // Save the input data and close the dialog
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 200,
                  height: 50,
                  color: Colors.white,
                  child: Text(controller.text),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildCategoryInputField(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Job category',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF150B3D),
                ),
              ),
              Spacer(),
              GestureDetector(
                child: Icon(Icons.add),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Select Job Category',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF150B3D),
                                ),
                              ),
                              SizedBox(height: 20),
                              DropdownButton<String>(
                                value: selectedCategory.isNotEmpty
                                    ? selectedCategory
                                    : null,
                                items: <String>[
                                  'IT',
                                  'Finance',
                                  'Health',
                                  'Education'
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedCategory = newValue!;
                                    categoryController.text = selectedCategory;
                                  });
                                },
                                hint: Text('Select a category'),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        categoryController.text =
                                            selectedCategory;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Save'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 200,
                  height: 50,
                  color: Colors.white,
                  child: Text(categoryController.text),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildEmploymentTypeInputField(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Employment type',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF150B3D),
                ),
              ),
              Spacer(),
              GestureDetector(
                child: Icon(Icons.add),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      String localSelectedRadioValue = selectedEmploymentType;
                      String localSelectedCheckboxValue = selectedWorkType;
                      return StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setModalState) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Select Employment Type and Work Type',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Color(0xFF150B3D),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Part-time'),
                                        Radio<String>(
                                          value: 'Part-time',
                                          groupValue: localSelectedRadioValue,
                                          onChanged: (String? value) {
                                            setModalState(() {
                                              localSelectedRadioValue = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Full-time'),
                                        Radio<String>(
                                          value: 'Full-time',
                                          groupValue: localSelectedRadioValue,
                                          onChanged: (String? value) {
                                            setModalState(() {
                                              localSelectedRadioValue = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Internship'),
                                        Radio<String>(
                                          value: 'Internship',
                                          groupValue: localSelectedRadioValue,
                                          onChanged: (String? value) {
                                            setModalState(() {
                                              localSelectedRadioValue = value!;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Onsite'),
                                        Checkbox(
                                          value: localSelectedCheckboxValue ==
                                              'Onsite',
                                          onChanged: (bool? value) {
                                            setModalState(() {
                                              if (value == true) {
                                                localSelectedCheckboxValue =
                                                    'Onsite';
                                              } else {
                                                localSelectedCheckboxValue = '';
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Remote'),
                                        Checkbox(
                                          value: localSelectedCheckboxValue ==
                                              'Remote',
                                          onChanged: (bool? value) {
                                            setModalState(() {
                                              if (value == true) {
                                                localSelectedCheckboxValue =
                                                    'Remote';
                                              } else {
                                                localSelectedCheckboxValue = '';
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedEmploymentType =
                                              localSelectedRadioValue;
                                          selectedWorkType =
                                              localSelectedCheckboxValue;
                                          employmentTypeController.text =
                                              '$selectedEmploymentType, $selectedWorkType';
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Save'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  width: 200,
                  height: 50,
                  color: Colors.white,
                  child: Text(employmentTypeController.text),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildGrowingTextField(String hintText,
      TextEditingController controller, Function(String) onSave) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 200, // Adjust the max height as needed
      ),
      child: SingleChildScrollView(
        child: TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(
            hintText: 'Enter $hintText here',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onChanged: (value) {
            onSave(value);
          },
        ),
      ),
    );
  }
}
