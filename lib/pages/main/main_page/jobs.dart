// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:flutter/material.dart';

class Jobs extends StatelessWidget {
  const Jobs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              width: 400,
              height: 200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                        // want to put a circular image here
                        ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          'Job title', // job title goes here
                          style: GoogleFonts.getFont(
                            'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF232D3A),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons
                            .more_vert)) // icon should all display details about the job
                  ]),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, 10), // Reduced bottom margin
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Company inc', // company  name goes here
                          style: GoogleFonts.getFont(
                            'DM Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF524B6B),
                          ),
                        ),
                        SizedBox(width: 5.6),
                        Container(
                          margin: EdgeInsets.only(top: 9),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF524B6B),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            width: 2,
                            height: 2,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Location, UG', // location goes here
                          style: GoogleFonts.getFont(
                            'DM Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFF524B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0, 0, 0, 10), // Reduced bottom margin
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFCBC9D4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.fromLTRB(0.3, 6, 0, 7),
                              child: Center(
                                child: Text(
                                  'Part Time',
                                  style: GoogleFonts.getFont(
                                    'DM Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Color(0xFF524B6B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFCBC9D4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.fromLTRB(0, 6, 0.9, 7),
                              child: Center(
                                child: Text(
                                  'OnSite',
                                  style: GoogleFonts.getFont(
                                    'DM Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Color(0xFF524B6B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFCBC9D4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.fromLTRB(0, 6, 0, 7),
                              child: Center(
                                child: Text(
                                  'Remote',
                                  style: GoogleFonts.getFont(
                                    'DM Sans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: Color(0xFF524B6B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 2.9, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 66,
                          child: Text(
                            '25 minute ago', // i want time stamp here
                            style: GoogleFonts.getFont(
                              'DM Sans',
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: Color(0xFFAAA6B9),
                            ),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.getFont(
                              'Open Sans',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Color(0xFF232D3A),
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'UGx: 312K', //salary goes here if provided else
                                style: GoogleFonts.getFont(
                                  'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  height: 1.3,
                                  color: Color(0xFF000000),
                                ),
                              ),
                              TextSpan(
                                text: '/',
                                style: GoogleFonts.getFont(
                                  'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFFAAA6B9),
                                ),
                              ),
                              TextSpan(
                                text: 'Mo',
                                style: GoogleFonts.getFont(
                                  'DM Sans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFFAAA6B9),
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
            )));
  }
}
