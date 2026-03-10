// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_super_parameters, unnecessary_string_interpolations

import 'package:cjb/pages/auth/auth_service.dart';
import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/main/main_page/employer/s.dart';
import 'package:cjb/pages/main/main_page/savedjobs.dart';
import 'package:cjb/pages/main/settings.dart';
import 'package:cjb/pages/main/user_profile/profile_page.dart';
import 'package:cjb/pages/main/user_profile/user_surport.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cjb/theme/styles.dart';
//import 'package:cjb/pages/onboarding/on_boarding_screen.dart';
//import 'package:flutter/widgets.dart'; // Ensure this import

class DrawerWidget extends StatefulWidget {
  final String firstName;

  const DrawerWidget({required this.firstName, Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await GlobalVariables().loadUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // * TOP AREA DRAWER - EXPANDED
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(45),
                            child: GlobalVariables().profileImageUrl.isNotEmpty
                                ? Image.network(
                                    GlobalVariables().profileImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/holder.jpeg',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${GlobalVariables().username}",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        GestureDetector(
                          child: const Text(
                            "View profile",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: cjbMediumGrey86888A),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => ProfilePage()));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: cjbLightGreyCACCCE,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.bookmark, color: Colors.blueGrey),
                        SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Example navigation from a button or menu
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SavedJobsPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Saved jobs",
                            style: TextStyle(
                                color: cjbMediumGrey86888A,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                        Icon(Icons.question_answer_sharp,
                            color: Colors.blueGrey),
                        SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          onTap: () {
                            // Example navigation from a button or menu
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SupportPage(),
                              ),
                            );
                          },
                          child: Text(
                            "surport",
                            style: TextStyle(
                                color: cjbMediumGrey86888A,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EmployeeSearchPage()));
                      },
                      child: Row(
                        children: [
                          Icon(Icons.emoji_people_rounded,
                              color: Colors.blueGrey),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "find employee",
                            style: TextStyle(
                                color: cjbMediumGrey86888A,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: GestureDetector(
                      onTap: () {
                        AuthServices.logoutUser(context);
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: Colors.blueGrey,
                          ),
                          Text(
                            "Log Out",
                            style: TextStyle(
                                color: cjbMediumGrey86888A,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // * BOTTOM AREA DRAWER
          Container(
            width: double.infinity,
            height: 1,
            color: cjbLightGreyCACCCE,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 30.0, left: 20),
            child: Column(
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.settings,
                      size: 35,
                      color: cjbMediumGrey86888A,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => Settings()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        "Settings",
                        style: TextStyle(
                            color: cjbMediumGrey86888A,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
