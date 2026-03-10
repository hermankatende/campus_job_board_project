// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, unnecessary_null_comparison, prefer_const_constructors, unnecessary_string_interpolations, unnecessary_brace_in_string_interps, use_build_context_synchronously, avoid_unnecessary_containers

import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/main/notifications/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAjob extends StatefulWidget {
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

  Future<void> _notifyUsers(String jobCategory) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch all user documents
    QuerySnapshot userSnapshots = await firestore.collection('users').get();

    // Get the FCM tokens of users subscribed to the jobCategory
    List<String> tokens = [];
    for (var doc in userSnapshots.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<dynamic> subscriptions = data['subscriptions'] ?? [];

      if (subscriptions.contains(jobCategory)) {
        String token = data[
            'fcmToken']; // Assuming you store fcmToken in each user document
        if (token != null) {
          tokens.add(token);
        }
      }
    }

    // Notify all users with the collected tokens
    await _notificationService.sendNotificationsToSubscribers(
        jobCategory, tokens);
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
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
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
              ],
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                postJob();
                _notifyUsers('${selectedCategory}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFF9228),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
              ),
              child: Text(
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

  Future<void> postJob() async {
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
      return;
    }

    // Retrieve the current user's UID
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Show an error message if the user is not authenticated
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need to be logged in to post a job'),
        ),
      );
      return;
    }

    final posterId = user.uid;

    await FirebaseFirestore.instance.collection('jobs').add({
      'title': titleController.text,
      'location': locationController.text,
      'company': companyController.text,
      'employmentType': employmentTypeController.text,
      'description': descriptionController.text,
      'category': categoryController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'posterId': posterId,
      'email': GlobalVariables().email
    });

    // Clear the text fields
    titleController.clear();
    locationController.clear();
    companyController.clear();
    employmentTypeController.clear();
    descriptionController.clear();
    categoryController.clear();

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job posted successfully!'),
      ),
    );

    // Navigate back or show the list of jobs
    Navigator.of(context).pop();
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
