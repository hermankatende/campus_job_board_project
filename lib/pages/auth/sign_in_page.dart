// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously
import 'package:cjb/pages/app_router.dart';
import 'package:cjb/pages/auth/forgot_password.dart';
import 'package:cjb/pages/auth/sign_up_page.dart';
import 'package:cjb/services/auth_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  static const String _adminEmail = 'hermankats16@gmail.com';
  static const String _adminPassword = '12345herman';
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final profile = await AuthService.instance.signIn(email, password);
      if (!mounted) return;
      navigateToHome(context, profile);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginAsSystemAdmin() async {
    _emailController.text = _adminEmail;
    _passwordController.text = _adminPassword;
    await _login();
  }

  @override
  void dispose() {
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
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(29, 102, 20.9, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo_icon.png', width: 100, height: 100),
                const SizedBox(height: 16),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: const Color(0xFF0D0140),
                  ),
                ),
                const Text(
                  'Login to your CJB account',
                  style: TextStyle(color: Color(0xFF524B6B), fontSize: 13),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email',
                      style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: const Color(0xFF0D0140))),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password',
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: const Color(0xFF0D0140))),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ForgotPassword())),
                    child: Text(
                      'Forgot Password?',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: const Color(0xFF0D0140)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 96, 243, 1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Text('LOGIN',
                            style: GoogleFonts.dmSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.white,
                                letterSpacing: 0.8)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _loginAsSystemAdmin,
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('SIGN IN AS SYSTEM ADMIN'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(0, 96, 243, 1),
                      side: const BorderSide(
                        color: Color.fromRGBO(0, 96, 243, 1),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: const Color(0xFF524B6B)),
                    children: [
                      const TextSpan(text: "Don't have an account yet?  "),
                      TextSpan(
                        text: 'Sign up',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: const Color.fromRGBO(0, 96, 243, 1),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => SignUp()),
                              (route) => false),
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
