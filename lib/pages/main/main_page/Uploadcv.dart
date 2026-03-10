// ignore_for_file: file_names, camel_case_types, use_super_parameters, use_build_context_synchronously, prefer_const_constructors, unused_local_variable, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:cjb/pages/main/main_page/joblist.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class CV_page extends StatefulWidget {
  final String email;
  const CV_page({Key? key, required this.email}) : super(key: key);

  @override
  State<CV_page> createState() => _CV_pageState();
}

class _CV_pageState extends State<CV_page> {
  File? selectedFile;
  String? fileName;
  bool isUploading = false;
  String downloadUrl = '';

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      // Upload file to Firebase Storage
      String filePath =
          'uploads/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      UploadTask uploadTask =
          FirebaseStorage.instance.ref(filePath).putFile(selectedFile!);
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      downloadUrl = await snapshot.ref.getDownloadURL();

      // Save the URL in Firestore
      await FirebaseFirestore.instance.collection('uploaded_cvs').add({
        'file_name': fileName,
        'download_url': downloadUrl,
        'uploaded_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('File uploaded successfully')));

      // Send email with the uploaded file as attachment
      await sendEmailWithAttachment();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to upload file: $e')));
    } finally {
      setState(() {
        isUploading = false;
        selectedFile = null;
        fileName = null;
      });
    }
  }

  Future<void> sendEmailWithAttachment() async {
    final user = FirebaseAuth.instance.currentUser;
    final senderEmail = user?.email;

    if (senderEmail == null || downloadUrl.isEmpty) return;

    final smtpServer = gmail('cjbapp2024@gmail.com',
        'zbsu pkgj ghep msyn'); // Update with your SMTP server details

    final message = Message()
      ..from = Address(senderEmail)
      ..recipients.add(widget.email) // recipient's email
      ..subject = 'CV from CJB job Applicant'
      ..text = 'Please find the CV attached.'
      ..attachments = [
        FileAttachment(File(selectedFile!.path))
          ..location = Location.inline
          ..cid = '<myimg@3.141>'
      ];

    try {
      final sendReport = await send(message, smtpServer);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Email sent successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to send email: $e')));
    }
  }

  void removeFile() {
    setState(() {
      selectedFile = null;
      fileName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 42, 20, 90),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(2.8, 0, 2.8, 50.5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => JobsList()));
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 29),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: Text(
                        'Add Resume',
                        style: GoogleFonts.getFont(
                          'Open Sans',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF150A33),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 15, 0, 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 15, 0),
                                      child: SizedBox(
                                        width: 44,
                                        height: 44,
                                        child: Image(
                                          image: AssetImage(
                                            'assets/pdf.png',
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                child: Text(fileName ??
                                                    'No file selected'),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                  onPressed: pickFile,
                                                  child: Text('Pick file'))
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            if (selectedFile != null)
                              Container(
                                margin: EdgeInsets.fromLTRB(6, 0, 6, 0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin:
                                            EdgeInsets.fromLTRB(0, 0, 10, 0),
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: ClipRect(
                                            child: Align(
                                              widthFactor: 1000,
                                              heightFactor: 1000,
                                              child: Icon(Icons
                                                  .delete_forever_outlined),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: TextButton(
                                            onPressed: removeFile,
                                            child: Text('Remove file'),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            if (selectedFile != null)
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: ElevatedButton(
                                    onPressed: isUploading ? null : uploadFile,
                                    child: isUploading
                                        ? CircularProgressIndicator()
                                        : Text('Upload and Send Email'),
                                  ),
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
        ),
      ),
    );
  }
}
