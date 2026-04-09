// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:cjb/pages/main/admin/admin_dashboard_page.dart';
import 'package:cjb/pages/main/admin/admin_users_page.dart';
import 'package:cjb/pages/main/create/add_job.dart';
import 'package:cjb/pages/main/main_page/joblist.dart';
import 'package:cjb/pages/main/user_profile/profile_page.dart';
import 'package:flutter/material.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    AdminDashboardPage(),
    AdminUsersPage(),
    AddAjob(onSuccess: () => setState(() => _currentIndex = 0)),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromRGBO(0, 96, 243, 1),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post Job'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
