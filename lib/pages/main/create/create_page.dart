// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_super_parameters, library_private_types_in_public_api, unused_local_variable, use_build_context_synchronously, unnecessary_string_interpolations, prefer_const_literals_to_create_immutables

import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/main/create/add_job.dart';
//import 'package:cjb/pages/main/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'global_variables.dart';

class AddPostScreen extends StatefulWidget {
  final VoidCallback? onCloneClickListener;
  const AddPostScreen({Key? key, required this.onCloneClickListener})
      : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _image;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _submitPost() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (_image == null || description.isEmpty) {
      // Display a message if the image or description is missing
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please provide an image and a description.'),
      ));
      return;
    }

    try {
      // Upload image to Firebase Storage
      String fileName = 'posts/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot storageSnapshot = await uploadTask;

      // Get image download URL
      String imageUrl = await storageSnapshot.ref.getDownloadURL();

      // Get user data from global variables
      String username = GlobalVariables().username ?? 'Unknown User';
      String email = GlobalVariables().email ?? 'Unknown Email';

      // Add post details to Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'username': username,
        'email': email,
        'imageUrl': imageUrl,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the input fields
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _image = null;
      });

      // Display a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Post submitted successfully!'),
        // on suceesfull posting it should navigate the user to the homepage
      ));
    } catch (e) {
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to submit post: $e'),
      ));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: SingleChildScrollView(
          child: Container(
            height: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Add Post',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF150B3D),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18.0, vertical: 20.0),
                  child: Row(
                    children: [
                      Container(
                          width: 30,
                          height: 30,
                          // decoration: BoxDecoration(
                          // borderRadius: BorderRadius.circular(28),
                          // image: DecorationImage(
                          //   fit: BoxFit.cover,
                          //   image: AssetImage('assets/holder.jpeg'),

                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: GlobalVariables().profileImageUrl.isNotEmpty
                                ? Image.network(
                                    GlobalVariables().profileImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/holder.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                          )),
                      SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${GlobalVariables().username}',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF150B3D),
                            ),
                          ),
                          Text(
                            '${GlobalVariables().email}',
                            style: GoogleFonts.dmSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: Color(0xFF524B6B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: Color(0xFF150B3D),
                        ),
                      ),
                      SizedBox(height: 5),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        minLines: 2,
                        decoration: InputDecoration(
                          hintText: 'What do you want to talk about?',
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 5),
                Center(
                  child: Container(
                    width: 350,
                    height: 400,
                    color: Colors.white,
                    child: _image != null
                        ? Image.file(_image!)
                        : Center(child: Text('No image selected')),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x26ACC8D3),
                        offset: Offset(0, 4),
                        blurRadius: 79.5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20.6, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.business_center_rounded),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddAjob(),
                                      ),
                                    );
                                  },
                                ),
                                Text('Job'),
                              ],
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Icon(
                                      Icons.photo_size_select_actual_rounded),
                                  onPressed: _pickImage,
                                ),
                                Text('Media'),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap:
                              _submitPost, // add functionality to take usr to hpme page
                          child: Container(
                            width: 100,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF9228),
                              borderRadius: BorderRadius.circular(23),
                            ),
                            child: Center(
                              child: Text(
                                'Post',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                //Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
