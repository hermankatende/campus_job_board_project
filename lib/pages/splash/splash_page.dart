import 'package:flutter/material.dart';
import 'package:cjb/theme/styles.dart';

class SplashPage extends StatefulWidget {
  final Widget child;
  const SplashPage({Key? key, required this.child}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 3000)).then((value) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => widget.child),
        (route) => false,
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cjbWhiteFFFFFF,
      body: Container(child: Center(child: Image.asset("assets/logo.jpg"))),
    );
  }
}
