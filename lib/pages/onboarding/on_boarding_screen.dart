// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
import 'package:cjb/pages/auth/sign_in_page.dart';
import 'package:cjb/pages/auth/sign_up_page.dart';
import 'package:cjb/pages/onboarding/on_boarding_entity.dart';
import 'package:cjb/theme/styles.dart';
import 'package:cjb/widgets/button_container_widget.dart';
//import 'package:cjb/widgets/google_button_container_widget.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  List<OnBoardingEntity> onBoardingData = OnBoardingEntity.onBoardingData;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PageView.builder(
          itemCount: onBoardingData.length,
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SvgPicture.asset(
                  //   "assets/logo.jpg",
                  //   width: 50,
                  //   height: 50,
                  // ),
                  const SizedBox(
                    height: 20,
                  ),
                  Image.asset("assets/${onBoardingData[index].image}"),
                  Center(
                    child: Text(
                      "${onBoardingData[index].title}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color:
                                index == 0 ? cjbDarkGrey313335 : cjbWhiteFFFFFF,
                            border: Border.all(width: 1),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color:
                                index == 1 ? cjbDarkGrey313335 : cjbWhiteFFFFFF,
                            border: Border.all(width: 1),
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color:
                                index == 2 ? cjbDarkGrey313335 : cjbWhiteFFFFFF,
                            border: Border.all(width: 1),
                            shape: BoxShape.circle),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: ButtonContainerWidget(
                      title: "Join now",
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => SignUp()),
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => SignInPage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: cjb_blu),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
