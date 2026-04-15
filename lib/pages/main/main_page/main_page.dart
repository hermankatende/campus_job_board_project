// ignore_for_file: non_constant_identifier_names, prefer_const_constructors

import 'package:cjb/pages/main/main_page/jobs_filter_page.dart';
import 'package:cjb/pages/main/main_page/my_applications_page.dart';
import 'package:cjb/pages/main/notifications/notification.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cjb/pages/main/home/home_page.dart';
import 'package:cjb/pages/main/main_page/widgets/drawer_widget.dart';
import 'package:cjb/theme/styles.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/app_bar_widget.dart';

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
    // Navigate to filtered jobs with search query
    // This could be implemented in JobsFilterPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobsFilterPage(),
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
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              _scaffoldState.currentState!.openDrawer();
            },
          ),
          title: Text(
            _currentPageIndex == 2 ? 'Browse Jobs' : 'Home',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          actions: [
            if (_currentPageIndex != 2)
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: () {
                  // Show search dialog
                  showSearch(
                    context: context,
                    delegate: JobSearchDelegate(),
                  );
                },
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentPageIndex,
          onTap: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
          selectedItemColor: Colors.blue,
          selectedLabelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
          unselectedItemColor: cjbMediumGrey86888A,
          unselectedLabelStyle: GoogleFonts.poppins(
            color: cjbMediumGrey86888A,
          ),
          showUnselectedLabels: true,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "Applications",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: "Browse Jobs",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: "Notifications",
            ),
          ],
        ),
        body: _switchPages(_currentPageIndex));
  }

  Widget _switchPages(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const MyApplicationsPage();
      case 2:
        return const JobsFilterPage();
      case 3:
        return const Notification_Page();
      default:
        return const HomePage();
    }
  }
}

class JobSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Search for: $query'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Text('Enter a job title or keyword'),
    );
  }
}
