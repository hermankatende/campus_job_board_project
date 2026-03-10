// ignore_for_file: library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_constructors, avoid_unnecessary_containers, use_super_parameters

import 'package:cjb/pages/auth/identity.dart';
import 'package:cjb/pages/main/home/home_page.dart';
import 'package:cjb/pages/main/user_profile/edit_profile_page.dart';

import 'package:cjb/pages/main/user_profile/widget/appbar_widget.dart';
import 'package:cjb/pages/main/user_profile/widget/button_widget.dart';
//import 'package:cjb/pages/main/user_profile/widget/profile_widget.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:path/path.dart' as path;

// import '../../auth/user_pref.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
    return Scaffold(
      appBar: buildAppBar(context),
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath: GlobalVariables().profileImageUrl.isNotEmpty
                ? GlobalVariables().profileImageUrl
                : 'assets/holder.jpeg',
            onClicked: () async {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false);
            },
          ),
          const SizedBox(height: 24),
          buildName(),
          const SizedBox(height: 24),
          Center(child: buildUpgradeButton()),
          const SizedBox(height: 24),
          buildAbout(),
        ],
      ),
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            GlobalVariables().username,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            GlobalVariables().email,
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text: 'Edit profile',
        onClicked: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Profile()),
          );
        },
      );

  Widget buildAbout() => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'About',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            buildInfoRow('About me: ', GlobalVariables().aboutMe),
            const SizedBox(height: 16),
            buildInfoRow('Work experience: ', GlobalVariables().workExperience),
            const SizedBox(height: 16),
            buildInfoRow('Education: ', GlobalVariables().education),
            const SizedBox(height: 16),
            buildInfoRow('Skills: ', GlobalVariables().skills),
            const SizedBox(height: 16),
            buildInfoRow(
                'Hobbies/interests: ', GlobalVariables().hobbiesInterests),
            const SizedBox(height: 16),
            buildInfoRow('Portfolio: ', GlobalVariables().portfolioUrl),
            const SizedBox(height: 16),
            buildInfoRow('Job preference: ', GlobalVariables().jobPreference),
          ],
        ),
      );

  Widget buildInfoRow(String label, String value) => Row(
        children: [
          Text(
            label,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16, height: 1.4),
          ),
          Expanded(
            child: Container(
              child:
                  Text(value.isNotEmpty ? value : 'Information not available'),
            ),
          ),
        ],
      );
}

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final VoidCallback onClicked;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Center(
      child: Stack(
        children: [
          buildImage(),
          Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(color),
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    final image = imagePath.contains('http')
        ? NetworkImage(imagePath)
        : AssetImage(imagePath) as ImageProvider;

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.edit,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}
