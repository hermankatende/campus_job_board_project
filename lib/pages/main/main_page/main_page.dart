// ignore_for_file: non_constant_identifier_names

import 'package:cjb/pages/main/main_page/job_results.dart';
import 'package:cjb/pages/main/main_page/joblist.dart';
//import 'package:cjb/pages/main/main_page/jobs.dart';
//import 'package:cjb/pages/main/notifications/no_notty.dart';
import 'package:cjb/pages/main/notifications/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cjb/pages/main/create/create_page.dart';
import 'package:cjb/pages/main/home/home_page.dart';
//import 'package:cjb/pages/main/user_profile/user_profile.dart';
import 'package:cjb/pages/main/main_page/widgets/drawer_widget.dart';
import 'package:cjb/theme/styles.dart';

import 'widgets/app_bar_widget.dart';
//import 'job_search_results.dart'; // Import the JobSearchResults page

class MainPage extends StatefulWidget {
  final String firstName;
  const MainPage(
      {required this.firstName, super.key, required String first_Name});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldState = GlobalKey<ScaffoldState>();
  int _currentPageIndex = 0;

  void _handleSearch(String query) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobSearchResults(query: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: DrawerWidget(
          firstName: widget.firstName,
        ),
        key: _scaffoldState,
        appBar: _currentPageIndex == 4
            ? appBarWidget(context, title: "Search Jobs", isJobsTab: true,
                onLeadingTapClickListener: () {
                setState(() {
                  _scaffoldState.currentState!.openDrawer();
                });
              }, onSearch: _handleSearch)
            : appBarWidget(context, title: "Search", isJobsTab: false,
                onLeadingTapClickListener: () {
                setState(() {
                  _scaffoldState.currentState!.openDrawer();
                });
              }, onSearch: _handleSearch),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          onTap: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          selectedItemColor: cjbBlack000000,
          selectedLabelStyle: const TextStyle(color: cjbBlack000000),
          unselectedItemColor: cjbMediumGrey86888A,
          unselectedLabelStyle: const TextStyle(color: cjbMediumGrey86888A),
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box),
              label: "Post",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications,
                size: 30,
              ),
              label: "Notifications",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.business_center,
                size: 30,
              ),
              label: "Jobs",
            ),
          ],
        ),
        body: _switchPages(_currentPageIndex));
  }

  _switchPages(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 3:
        return JobsList();
      case 1:
        return AddPostScreen(
          onCloneClickListener: () {
            Navigator.pop(context);
            setState(() {
              _currentPageIndex = 0;
            });
          },
        );
      case 2:
        return const Notification_Page();
      default:
        return const HomePage(); // Fallback to HomePage or a default page
    }
  }
}
