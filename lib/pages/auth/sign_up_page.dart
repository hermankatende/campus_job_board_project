// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cjb/pages/app_router.dart';
import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/auth/sign_in_page.dart';
import 'package:cjb/services/api_client.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool obscurePassword = true;
  bool _loading = false;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _register() async {
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(fullName);
      await AuthService.instance.syncProfile();
      final profile = AuthService.instance.currentProfile;

      if (!mounted) return;
      if (profile?.isAdmin == true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => homePageForProfile(profile!)),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => RoleSelectionPage()),
          (route) => false,
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'An account with this email already exists.';
          break;
        case 'weak-password':
          msg = 'Password must be at least 6 characters.';
          break;
        case 'invalid-email':
          msg = 'Please enter a valid email address.';
          break;
        default:
          msg = e.message ?? 'Registration failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                child: Image.asset('assets/logo_icon.png'),
              ),
              SizedBox(height: 10),
              Text(
                'Create an Account',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: Color(0xFF0D0140),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Welcome to Campus Job Board',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  height: 1.6,
                  color: Color(0xFF524B6B),
                ),
              ),
              SizedBox(height: 20),
              _field('Full name', _fullNameController,
                  hint: 'Enter your full name'),
              SizedBox(height: 14),
              _field('Email', _emailController,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 14),
              _passwordField(),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 96, 243, 1),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: _loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          'SIGN UP',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: Color(0xFF524B6B),
                  ),
                  children: [
                    TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Sign in',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        color: Color.fromRGBO(0, 96, 243, 1),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SignInPage()),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {String hint = '', TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF0D0140))),
        SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: hint,
            hintStyle: TextStyle(color: Color(0x990D0140), fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  Widget _passwordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Password',
            style: GoogleFonts.dmSans(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF150B3D))),
        SizedBox(height: 5),
        TextField(
          controller: _passwordController,
          obscureText: obscurePassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter your password',
            hintStyle: TextStyle(color: Color(0x990D0140), fontSize: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            suffixIcon: IconButton(
              icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () =>
                  setState(() => obscurePassword = !obscurePassword),
            ),
          ),
        ),
      ],
    );
  }
}
