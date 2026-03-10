// ignore_for_file: avoid_print, prefer_const_constructors, unnecessary_brace_in_string_interps, use_build_context_synchronously, avoid_function_literals_in_foreach_calls, no_leading_underscores_for_local_identifiers, use_key_in_widget_constructors, library_private_types_in_public_api, depend_on_referenced_packages

import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final Map<String, TextEditingController> _controllers = {
    'About me': TextEditingController(),
    'Work experience': TextEditingController(),
    'Education': TextEditingController(),
    'Skills': TextEditingController(),
    'Hobbies/interests': TextEditingController(),
    'Portfolio url': TextEditingController(),
    'job preference': TextEditingController(),
  };

  File? _profileImage;
  bool _isUploading = false;

  String? _selectedGender;
  String? _selectedAgeRange;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    print('Initializing profile...');
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      print('User ID is empty');
      return;
    }

    print('User ID: $userId');
    await _fetchProfileData(userId);
  }

  Future<void> _fetchProfileData(String userId) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final snapshot = await userDoc.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        _controllers['About me']?.text = data?['about_me'] ?? '';
        _controllers['Work experience']?.text = data?['work_experience'] ?? '';
        _controllers['Education']?.text = data?['education'] ?? '';
        _controllers['Skills']?.text = data?['skills'] ?? '';
        _controllers['Hobbies/interests']?.text =
            data?['hobbies_interests'] ?? '';
        _controllers['Portfolio url']?.text = data?['portfolio_url'] ?? '';
        _controllers['job preference']?.text = data?['job_preference'] ?? '';
        _selectedGender = data?['gender'] ?? '';
        _selectedAgeRange = data?['age_range'] ?? '';
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  Future<void> _uploadProfile() async {
    setState(() {
      _isUploading = true;
    });

    try {
      String? downloadURL;
      if (_profileImage != null) {
        print('Uploading profile image...');
        // Compress image
        final compressedImage = await FlutterImageCompress.compressWithFile(
          _profileImage!.path,
          minWidth: 800,
          minHeight: 600,
          quality: 85,
          format: CompressFormat.jpeg,
        );

        if (compressedImage != null) {
          final tempFile =
              File('${(await getTemporaryDirectory()).path}/temp_image.jpg');
          await tempFile.writeAsBytes(compressedImage);

          // Get the current user's ID
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
          if (userId.isEmpty) {
            print('User ID is empty');
            setState(() {
              _isUploading = false;
            });
            return;
          }

          // Upload image to Firebase Storage with user ID in the file name
          final fileName = '${userId}${path.basename(tempFile.path)}';
          final storageReference =
              FirebaseStorage.instance.ref().child('profile_images/$fileName');
          final uploadTask = storageReference.putFile(tempFile);
          await uploadTask.whenComplete(() => null);
          downloadURL = await storageReference.getDownloadURL();
        }
      }

      print('Uploading profile data...');
      // Save profile data to Firestore
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);

      await userDoc.set({
        if (downloadURL != null) 'image_path': downloadURL,
        'about_me': _controllers['About me']?.text,
        'work_experience': _controllers['Work experience']?.text,
        'education': _controllers['Education']?.text,
        'skills': _controllers['Skills']?.text,
        'hobbies_interests': _controllers['Hobbies/interests']?.text,
        'portfolio_url': _controllers['Portfolio url']?.text,
        'job_preference': _controllers['job preference']?.text,
        'gender': _selectedGender,
        'age_range': _selectedAgeRange,
      }, SetOptions(merge: true)); // Use merge to update existing document

      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile Uploaded Successfully')));
    } catch (e) {
      print('Error uploading profile: $e');
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Upload Profile')));
    }
  }

  Future<void> _pickImage() async {
    print('Picking image...');
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _profileImage = File(pickedFile.path);
        print('Image picked: ${_profileImage!.path}');
      }
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.fromLTRB(0, 10, 0, 22),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : NetworkImage('https://via.placeholder.com/150')
                          as ImageProvider,
                ),
              ),
              _buildProfileListTile(
                context,
                'About me',
                Icon(Icons.account_circle_outlined),
              ),
              _buildProfileListTile(
                context,
                'Work experience',
                Icon(Icons.business_center_rounded),
              ),
              _buildProfileListTile(
                context,
                'Education',
                Icon(Icons.school_outlined),
              ),
              _buildProfileListTile(
                context,
                'Skills',
                Icon(Icons.ac_unit_outlined),
              ),
              _buildProfileListTile(
                context,
                'Hobbies/interests',
                Icon(Icons.favorite_outline),
              ),
              _buildProfileListTile(
                context,
                'Gender',
                Icon(Icons.person),
                onTap: _showGenderBottomSheet,
              ),
              _buildProfileListTile(
                context,
                'Age',
                Icon(Icons.cake),
                onTap: _showAgeBottomSheet,
              ),
              _buildProfileListTile(
                context,
                'Portfolio url',
                Icon(Icons.workspaces_outline),
              ),
              _buildProfileListTile(
                context,
                'job preference',
                Icon(Icons.workspaces_outline),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadProfile,
                child: Text('Upload Profile'),
              ),
              if (_isUploading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileListTile(BuildContext context, String title, Icon icon,
      {VoidCallback? onTap}) {
    return Column(
      children: [
        ListTile(
          leading: icon,
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: onTap ??
              () {
                _showEditDialog(
                    context, title, _controllers[title]?.text ?? '');
              },
        ),
        if ((_controllers[title]?.text ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
            child: Text(
              _controllers[title]?.text ?? '',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        Divider(
          color: Colors.grey[300],
          height: 1,
        ),
      ],
    );
  }

  void _showEditDialog(
      BuildContext context, String title, String currentValue) {
    TextEditingController _dialogController = TextEditingController();
    _dialogController.text = currentValue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: _dialogController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter your $title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _controllers[title]?.text = _dialogController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showGenderBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<String>(
                value: 'Male',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
              title: Text('Male'),
              onTap: () {
                setState(() {
                  _selectedGender = 'Male';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Radio<String>(
                value: 'Female',
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
              title: Text('Female'),
              onTap: () {
                setState(() {
                  _selectedGender = 'Female';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAgeBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Radio<String>(
                value: '20-35',
                groupValue: _selectedAgeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedAgeRange = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
              title: Text('20-35'),
              onTap: () {
                setState(() {
                  _selectedAgeRange = '20-35';
                });
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: Radio<String>(
                value: '35-50',
                groupValue: _selectedAgeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedAgeRange = value;
                  });
                  Navigator.of(context).pop();
                },
              ),
              title: Text('35-50'),
              onTap: () {
                setState(() {
                  _selectedAgeRange = '35-50';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
