// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cjb/pages/auth/auth_service.dart';
import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/auth/preferences.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cjb/pages/auth/sign_in_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool rememberMe = false;
  bool obscurePassword = true;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.fromLTRB(29, 102, 28, 90),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/logo_icon.png')),
              Container(
                margin: EdgeInsets.fromLTRB(1.7, 0, 0, 10),
                child: Text(
                  'Create an Account',
                  style: GoogleFonts.getFont(
                    'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Color(0xFF0D0140),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 1, 10),
                child: Text(
                  'Welcome to our job board app',
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
                margin: EdgeInsets.fromLTRB(0, 0, 1, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full name',
                      style: GoogleFonts.getFont(
                        'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF0D0140),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter your full name',
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
                margin: EdgeInsets.fromLTRB(0, 0, 1, 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: GoogleFonts.getFont(
                        'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF0D0140),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                margin: EdgeInsets.fromLTRB(1, 0, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: GoogleFonts.getFont(
                        'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: Color(0xFF150B3D),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(
                          color: Color(0x990D0140),
                          fontSize: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 2.9, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (bool? value) {
                            setState(() {
                              rememberMe = value!;
                            });
                          },
                        ),
                        Text(
                          'Remember me',
                          style: GoogleFonts.getFont(
                            'DM Sans',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFFAAA6B9),
                          ),
                        ),
                      ],
                    ),
                    // Text(
                    //   'Forgot Password?',
                    //   style: GoogleFonts.getFont(
                    //     'DM Sans',
                    //     fontWeight: FontWeight.w400,
                    //     fontSize: 12,
                    //     color: Color(0xFF0D0140),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 2, 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Color.fromRGBO(0, 96, 243, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2E99ABC6),
                      offset: Offset(0, 4),
                      blurRadius: 31,
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    // Call signupUser and await the result
                    bool success = await AuthServices.signupUser(
                      emailController.text,
                      passwordController.text,
                      fullNameController.text,
                      context,
                    );

                    if (success) {
                      // If signup is successful, navigate to MainPage
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoleSelectionPage(),
                        ),
                        (route) => false,
                      );
                    } else {
                      // Clear the text fields or keep them for user to try again
                      emailController.clear();
                      passwordController.clear();
                      fullNameController.clear();
                    }
                  },
                  style: TextButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 17, horizontal: 100),
                  ),
                  child: Text(
                    'SIGN UP',
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
                margin: EdgeInsets.fromLTRB(0, 0, 2.9, 0),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.getFont(
                      'Open Sans',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF524B6B),
                    ),
                    children: [
                      TextSpan(
                        text: 'You have an account? ',
                        style: GoogleFonts.getFont(
                          'DM Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign in',
                        style: GoogleFonts.getFont(
                          'DM Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          height: 1.3,
                          color: Color.fromRGBO(0, 96, 243, 1),
                          decorationColor: Color.fromRGBO(0, 96, 243, 1),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignInPage(),
                              ),
                            );
                          },
                      ),
                    ],
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
