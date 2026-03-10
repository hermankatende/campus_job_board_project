// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, unnecessary_string_interpolations, unnecessary_brace_in_string_interps

//import 'package:cjb/pages/main/home/home_page.dart';
import 'package:cjb/pages/main/main_page/Uploadcv.dart';
//import 'package:cjb/pages/main/main_page/jobcard.dart';
//import 'package:cjb/pages/main/main_page/joblist.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:flutter/material.dart';
//import 'dart:ui';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:googleapis/homegraph/v1.dart';
//import 'package:intl/intl.dart';

class Description extends StatelessWidget {
  final String timestamp;
  final String jobTitle;
  final String company;
  final String location;
  final String employmentType;
  final String email;

  final String description;

  Description({
    required this.timestamp,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.employmentType,
    required this.email,
    required this.description,
  });

  // Convert Firestore Timestamp to DateTime
  // DateTime date = location.toDate();
  // // Format DateTime to display only the date
  // String formattedDate = DateFormat.yMMMd().format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.fromLTRB(0, 33, 0, 27),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Positioned Image
              Container(
                margin: EdgeInsets.fromLTRB(22.8, 0, 30, 0.5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MainPage(
                                firstName: '',
                                first_Name: '',
                              ),
                            ));
                      },
                    ),
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFAFECFE),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.all(14.7),
                        child: CircleAvatar(
                          backgroundImage: AssetImage('assets/holder.jpeg'),
                          radius: 30,
                        ),
                      ),
                    ),
                    Icon(Icons.more_vert, color: Colors.black),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 62),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F2F2),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(29, 20, 31.3, 21),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(2.3, 0, 0, 16),
                              child: Text(
                                "${jobTitle}",
                                style: GoogleFonts.getFont(
                                  'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Color(0xFF150B3D),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('lctn:'),
                                _buildTag(location),
                                Text(' Pstd:'),
                                _buildTag(timestamp)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [Text('Company Name: '), _buildTag(company)],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [Text('WorkType: '), _buildTag(employmentType)],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text('Employment Type: '),
                  _buildTag(employmentType)
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 20, 25),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 15),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Job Description',
                            style: GoogleFonts.getFont(
                              'Open Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF150B3D),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                        child: Text(
                          '${description} ...',
                          style: GoogleFonts.getFont(
                            'Open Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF524B6B),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF7551FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 7, 14.8, 7),
                            child: Text(
                              'Read more',
                              style: GoogleFonts.getFont(
                                'Open Sans',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: Color(0xFF0D0140),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF7551FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                margin: EdgeInsets.fromLTRB(26, 0, 25, 0),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CV_page(email: email),
                          ),
                          (route) => false);
                    },
                    style: TextButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 100),
                    ),
                    child: Text(
                      'Apply Now',
                      style: GoogleFonts.getFont(
                        'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Opacity(
      opacity: 0.8,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFCBC9D4),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 10,
              color: Color(0xFF524B6B),
            ),
          ),
        ),
      ),
    );
  }
}
