import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class YourApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 42, 20, 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(2.8, 0, 2.8, 37.5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(0xFF524B6B),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0.4, 0, 0, 39),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Your application',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Color(0xFF150B3D),
                      ),
                    ),
                  ),
                ),
                Stack(
                  children: [
                    Positioned(
                      top: -20,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          width: 335,
                          height: 523,
                          child: SvgPicture.asset(
                            'assets/vectors/rectangle_624_x2.svg',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(15, 20, 15, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 43),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(1, 0, 1, 20),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF5F5F5),
                                                borderRadius:
                                                    BorderRadius.circular(48),
                                              ),
                                              width: 40,
                                              height: 40,
                                              padding: EdgeInsets.all(7),
                                              child: Image.asset(
                                                'assets/images/google_1.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(1, 0, 1, 6),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'UI/UX Designer',
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: Color(0xFF150B3D),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(1, 0, 1, 20),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      right: 5.3),
                                                  child: Text(
                                                    'Google inc',
                                                    style: GoogleFonts.openSans(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xFF150B3D),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 9, 5, 5),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF150B3D),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1),
                                                  ),
                                                  width: 2,
                                                  height: 2,
                                                ),
                                                Text(
                                                  'California, USA',
                                                  style: GoogleFonts.openSans(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Color(0xFF150B3D),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 7, 10, 6),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFB5B6B7),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1.5),
                                                ),
                                                width: 3,
                                                height: 3,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  'Shipped on February 14, 2022 at 11:30 am',
                                                  style: GoogleFonts.openSans(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Color(0xFF524B6B),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    0, 7, 10, 6),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFB5B6B7),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1.5),
                                                ),
                                                width: 3,
                                                height: 3,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  'Updated by recruiter 8 hours ago',
                                                  style: GoogleFonts.openSans(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12,
                                                    color: Color(0xFF524B6B),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 30),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(1, 0, 1, 21),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Job details',
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: Color(0xFF150B3D),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 7, 10, 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFB5B6B7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.5),
                                                  ),
                                                  width: 3,
                                                  height: 3,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Senior designer',
                                                    style: GoogleFonts.dmSans(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xFF524B6B),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 7, 10, 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFB5B6B7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.5),
                                                  ),
                                                  width: 3,
                                                  height: 3,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'Full time',
                                                    style: GoogleFonts.dmSans(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xFF524B6B),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  0, 7, 10, 6),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFB5B6B7),
                                                borderRadius:
                                                    BorderRadius.circular(1.5),
                                              ),
                                              width: 3,
                                              height: 3,
                                            ),
                                            Flexible(
                                              child: Text(
                                                '1-3 Years work experience',
                                                style: GoogleFonts.dmSans(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12,
                                                  color: Color(0xFF524B6B),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(1, 0, 1, 20),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              'Application details',
                                              style: GoogleFonts.dmSans(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: Color(0xFF150B3D),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 7, 10, 6),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFB5B6B7),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            1.5),
                                                  ),
                                                  width: 3,
                                                  height: 3,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    'CV/Resume',
                                                    style: GoogleFonts.dmSans(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 12,
                                                      color: Color(0xFF524B6B),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Stack(
                                          children: [
                                            Positioned(
                                              left: -15,
                                              right: -9,
                                              top: -15,
                                              bottom: -15,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: SvgPicture.asset(
                                                  'assets/vectors/rectangle_581_x2.svg',
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  15, 15, 9, 15),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        0, 0, 15, 0),
                                                    child: SvgPicture.asset(
                                                      'assets/vectors/pdf_1_x2.svg',
                                                      width: 44,
                                                      height: 44,
                                                    ),
                                                  ),
                                                  Flexible(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 0, 0, 5),
                                                          child: Text(
                                                            'Jamet kudasi - CV - UI/UX Designer.PDF',
                                                            style: GoogleFonts
                                                                .dmSans(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xFF150A33),
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right: 5),
                                                              child: Text(
                                                                '867 Kb',
                                                                style:
                                                                    GoogleFonts
                                                                        .dmSans(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  fontSize: 10,
                                                                  color: Color(
                                                                      0xFFB5B6B7),
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .fromLTRB(0,
                                                                      5, 5, 0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xFFB5B6B7),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            1),
                                                              ),
                                                              width: 2,
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              '14 Feb 2022 at 11:30 am',
                                                              style: GoogleFonts
                                                                  .dmSans(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 10,
                                                                color: Color(
                                                                    0xFFB5B6B7),
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
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
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Color(0xFF130160),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x2E99ABC6),
                                  offset: Offset(0, 4),
                                  blurRadius: 31,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  'APPLY FOR MORE JOBS',
                                  style: GoogleFonts.dmSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    letterSpacing: 0.8,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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
        ),
      ),
    );
  }
}
