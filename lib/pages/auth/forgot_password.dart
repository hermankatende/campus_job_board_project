import 'package:cjb/pages/auth/sign_in_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.fromLTRB(20, 90, 29, 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(13.8, 0, 0, 11),
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.getFont(
                    'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Color(0xFF0D0140),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(17.1, 0, 7.1, 52),
                child: Text(
                  'To reset your password, you need your email or mobile number that can be authenticated',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.getFont(
                    'DM Sans',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.6,
                    color: Color(0xFF524B6B),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(8.2, 0, 0, 72.2),
                child: SizedBox(
                  width: 118.2,
                  height: 93.8,
                  child: SvgPicture.asset(
                    'assets/vectors/group_67_x2.svg',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 29),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.getFont(
                        'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF150B3D),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(
                          color: Color(0x990D0140),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(9, 0, 0, 29),
                width: double.infinity,
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
                child: TextButton(
                  onPressed: () {
                    // Implement reset password functionality here
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 17),
                  ),
                  child: Text(
                    'RESET PASSWORD',
                    style: GoogleFonts.getFont(
                      'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(9, 0, 0, 0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFD6CDFE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: TextButton(
                  onPressed: () {
                    // Navigate back to login
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignInPage(),
                        ));
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 17),
                  ),
                  child: Text(
                    'BACK TO LOGIN',
                    style: GoogleFonts.getFont(
                      'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: 0.8,
                      color: Color(0xFFFFFFFF),
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
}
