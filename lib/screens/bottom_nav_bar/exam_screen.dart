import 'dart:convert';
import 'package:bulleted_list/bulleted_list.dart';
import 'package:engage_360/models/user_model.dart';
import 'package:engage_360/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamScreen extends StatefulWidget {
  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f6fb),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Engage 360",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.only(bottom: 60),
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final userStr = prefs.getString("current_user");
                  final user = UserModel.fromJson(jsonDecode(userStr!));

                  Get.offAll(
                    () => CameraScreen(
                      purpose: "exam",
                      user: user,
                    ),
                  );
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Join a meeting",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "Exam Proctoring System",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 10),
              Image.asset(
                'assets/images/scan.png',
                height: 220,
                width: 220,
              ),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: const Text(
                  "Exam Guidelines :",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              BulletedList(
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  fontFamily: GoogleFonts.robotoSlab().fontFamily,
                ),
                bullet: const Icon(
                  FontAwesomeIcons.circleDot,
                  size: 15,
                ),
                listItems: const [
                  "Make sure during the entire duration of the exam, your Camera is Turned ON.",
                  "If at any point, your face is not detected, you'll be disqualified immediately.",
                  "You should only look at the screen of your laptop. If you look anywhere else, you'll receive a penalty.",
                  "Your head should only be pointed towards the screen. If you move your head left or right, you'll receive a penalty.",
                  "Three [3] penalty points and you'll be disqualified from the exam. Be careful!",
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
