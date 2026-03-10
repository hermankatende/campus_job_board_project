// ignore_for_file: depend_on_referenced_packages, use_super_parameters, unused_field, use_build_context_synchronously, prefer_const_constructors, avoid_print

import 'dart:io';
import 'package:cjb/pages/auth/identity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;

class ProfileWidget extends StatefulWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  File? _profileImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
    _uploadImage;
  }

  Future<void> _uploadImage() async {
    if (_profileImage == null) return;
    setState(() {
      _isUploading = true;
    });
    try {
      // Use path.basename to extract the file name
      final fileName = path.basename(_profileImage!.path);
      final storageReference =
          FirebaseStorage.instance.ref().child('images/$fileName');
      final uploadTask = storageReference.putFile(_profileImage!);
      await uploadTask.whenComplete(() => null); // Ensures task completion
      final downloadURL = await storageReference.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').add({
        'url': downloadURL,
        //'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Image Uploaded Successfully')));
    } catch (e) {
      print(e);
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to Upload Image')));
    }
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
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final ImageProvider imageProvider = _profileImage != null
        ? FileImage(_profileImage!)
        : AssetImage(widget.imagePath) as ImageProvider;

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: imageProvider,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: widget.onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: GestureDetector(
            onTap: _pickImage,
            child: Icon(
              Icons.edit,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
