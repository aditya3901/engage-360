import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserExist();
  }

  void checkUserExist() async {
    Timer(
      const Duration(milliseconds: 600),
      () async {
        final prefs = await SharedPreferences.getInstance();
        final exist = prefs.getBool("user_exist");
        if (exist != null && exist == true) {
          Get.offAll(() => TabsScreen());
        } else {
          Get.offAll(() => Welcome());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          "assets/images/appicon.png",
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}
