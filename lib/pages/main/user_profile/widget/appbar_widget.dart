//import 'package:cjb/pages/main/home/home_page.dart';
// ignore_for_file: prefer_const_declarations, prefer_const_constructors

import 'package:cjb/pages/main/main_page/main_page.dart';
import 'package:cjb/pages/main/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

AppBar buildAppBar(BuildContext context) {
  final icon = CupertinoIcons.moon_stars;

  return AppBar(
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
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
    backgroundColor: Colors.transparent,
    elevation: 0,
    actions: [
      IconButton(
        icon: Icon(icon),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Settings(),
              ));
          //change theme
        },
      ),
    ],
  );
}
