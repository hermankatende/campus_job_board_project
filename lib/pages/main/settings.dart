// ignore_for_file: prefer_const_constructors

import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 42, 20, 91),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    child: IconButton(
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
                  icon: Icon(Icons.arrow_back),
                )),
                SizedBox(
                  height: 8,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 26),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Settings',
                      style: GoogleFonts.getFont(
                        'DM Sans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF150A33),
                      ),
                    ),
                  ),
                ),
                _buildSettingOption(
                  iconPath: Icon(Icons.notifications_active),
                  title: 'Notifications',
                  trailingIcon: 'assets/vectors/group_441_x2.svg',
                ),
                _buildSettingOption(
                  iconPath: Icon(Icons.dark_mode),
                  title: 'Dark mode',
                  trailingIcon: 'assets/vectors/group_43_x2.svg',
                ),
                _buildSettingOption(
                  iconPath: Icon(Icons.lock_outline),
                  title: 'Password',
                  trailingIcon: 'assets/vectors/icon_7_x2.svg',
                ),
                _buildSettingOption(
                  iconPath: Icon(Icons.logout),
                  title: 'Logout',
                  trailingIcon: 'assets/vectors/icon_33_x2.svg',
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
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
                    child: Container(
                      width: 213,
                      padding: EdgeInsets.fromLTRB(6.7, 16, 0, 16),
                      child: Text(
                        'SAVE',
                        style: GoogleFonts.getFont(
                          'DM Sans',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.8,
                          color: Color(0xFFFFFFFF),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingOption({
    required Widget iconPath,
    required String title,
    required String trailingIcon,
  }) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        child: Stack(children: [
          Positioned(
            left: -90,
            right: -20,
            top: -13,
            bottom: -13,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                  width: 335,
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x2E99ABC6),
                        offset: Offset(0, 4),
                        blurRadius: 31,
                      ),
                    ],
                  ),
                  child: iconPath),
            ),
          ),
          SizedBox(
            width: 335,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 13, 23, 13),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 4, 0, 4),
                      child: Text(
                        title,
                        style: GoogleFonts.getFont(
                          'DM Sans',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF150B3D),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 6, 0, 6),
                      child: SizedBox(
                        width: 38,
                        height: 19,
                        child: SvgPicture.asset(
                          trailingIcon,
                        ),
                      ),
                    )
                  ]),
            ),
          ),
        ]));
  }
}
