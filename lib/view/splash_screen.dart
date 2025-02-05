import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:gym_finder/view/login_sceen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Get.to(const LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [Colors.pinkAccent, Colors.amber],
        begin: FractionalOffset(0, 0),
        end: FractionalOffset(1, 0),
        stops: [0, 1],
        tileMode: TileMode.clamp,
      )),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset("lib/images/splash.png"),
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Text(
              "welcom to Gym Finder",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Colors.white,
              ),
            ),
          ),
        ]),
      ),
    ));
  }
}
