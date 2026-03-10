// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously, unused_element, sized_box_for_whitespace
import 'package:cjb/pages/auth/firebase_auth_services.dart';
import 'package:cjb/pages/auth/forgot_password.dart';
import 'package:cjb/pages/auth/sign_up_page.dart';
import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;

  final FirebaseAuthServices _authServices = FirebaseAuthServices();

  void _toggleRememberMe(bool? value) {
    setState(() {
      _rememberMe = value ?? false;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    // Handle login logic here
    print('Email: $email');
    print('Password: $password');

    final user =
        await _authServices.signInWithEmailAndPassword(email, password);

    if (user != null) {
      // Navigate to home page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainPage(
            firstName: _emailController.text,
            first_Name: _emailController.text,
          ),
        ),
        (route) => false,
      );
    } else {
      // Show invalid login credentials message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid login credentials'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _loginWithGoogle() {
    // Handle Google login logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(29, 102, 20.9, 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/logo_icon.png')),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    color: Color(0xFF0D0140),
                  ),
                ),
                Text('login into ur cjb account',
                    style: TextStyle(color: Color(0xFF0D0140))),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Email',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Color(0xFF0D0140),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Password',
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF0D0140),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: _togglePasswordVisibility,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: _toggleRememberMe,
                        ),
                        Text(
                          'Remember me',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            color: Color(0xFFAAA6B9),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => ForgotPassword()),
                            (route) => false);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF0D0140),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(0, 96, 243, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  ),
                  child: Text(
                    'LOGIN',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                SizedBox(height: 19),
                //
                SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.openSans(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF524B6B),
                    ),
                    children: [
                      TextSpan(
                        text: 'You dont have an account yet?  ',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                      TextSpan(
                        text: 'Sign up',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          height: 1.3,
                          color: Color.fromRGBO(0, 96, 243, 1),
                          decorationColor: Color.fromRGBO(0, 96, 243, 1),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => SignUp()),
                                (route) => false);
                          },
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
