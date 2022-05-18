import 'dart:convert';
import 'package:engage_360/models/attendance.dart';
import 'package:engage_360/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "";
  String userDp = "https://cdn.wallpapersafari.com/57/23/O0wQMK.jpg";
  String phoneNum = "";

  List<Attendance> data = [
    Attendance(attdn: "Present", percentage: 72),
    Attendance(attdn: "Absent", percentage: 28),
  ];

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("current_user");
    final json = jsonDecode(userStr!);
    final user = UserModel.fromJson(json);

    username = user.name!;
    userDp = user.image!;
    phoneNum = user.phone!;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Widget roundedButton(IconData icon) {
      return ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
        ),
        child: Icon(icon, size: 30),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff7f6fb),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.red,
                              Colors.deepPurple,
                            ],
                          ),
                        ),
                        width: double.infinity,
                        height: 260,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 50,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {},
                                child: const Text(
                                  "Settings",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const Text(
                                "Profile",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.clear();
                                  Get.offAll(() => Welcome());
                                },
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 130,
                        child: Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(140)),
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CircleAvatar(
                              backgroundColor: Colors.black12,
                              backgroundImage: NetworkImage(
                                userDp,
                              ),
                              radius: 80,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  Text(
                    username,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Welcome to Engage 360",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      roundedButton(Icons.phone),
                      roundedButton(FontAwesomeIcons.slack),
                      roundedButton(FontAwesomeIcons.github),
                      roundedButton(FontAwesomeIcons.linkedinIn),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
