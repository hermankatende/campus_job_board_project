import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NoNotifications extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.8, 42, 22.8, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 137.5),
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Color(0xFF524B6B)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MainPage(
                            firstName: '',
                            first_Name: '',
                          ),
                        ));
                    ;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 21),
                      child: Text(
                        'No notifications',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF150B3D),
                        ),
                      ),
                    ),
                    Text(
                      'You have no notifications at this time, thank you',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: Color(0xFF524B6B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: SvgPicture.asset(
                  'assets/vectors/illustration_3_x2.svg',
                  width: 219.9,
                  height: 208,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
