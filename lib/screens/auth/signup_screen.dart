import 'dart:convert';
import 'dart:io';
import 'package:engage_360/constants.dart';
import 'package:engage_360/models/user_model.dart';
import 'package:engage_360/screens/screens.dart';
import 'package:engage_360/services/multipart_request_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  File userImageFile;
  SignUpScreen(this.userImageFile);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String userName = "Name";
  String phoneNum = "Phone Number";
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String faceId = "";
  String userImageUrl = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _detectFace();
  }

  void _detectFace() async {
    MultipartService service = MultipartService();

    final imageUrl = await service.submitSubscription(
      file: widget.userImageFile,
      filename: basename(widget.userImageFile.path),
    );
    final body = {
      "url": imageUrl,
    };

    final response = await http.post(
      Uri.parse(kDetectUrl),
      headers: {
        "Ocp-Apim-Subscription-Key": "51bbe14a2e9f4bf5b2f50c6d2f61a270",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    // No Face Detected in Image
    if (response.body == "[]") {
      Get.snackbar(
        "No Face Detected",
        "Try clicking the picture with a better lighting.",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      Get.offAll(() => Welcome());
    } else {
      userImageUrl = imageUrl;
      faceId = data[0]["faceId"];
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget formInput(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigoAccent),
            borderRadius: BorderRadius.circular(10)),
        hintText: label,
      ),
    );
  }

  void signUpUser() async {
    if (_nameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      userName = _nameController.text.trim();
      phoneNum = _phoneController.text.trim();

      final ref = FirebaseDatabase.instance.ref("Users").child(phoneNum);
      await ref.set({
        "name": userName,
        "phoneNum": phoneNum,
        "image": userImageUrl,
        "faceId": faceId,
      });

      final prefs = await SharedPreferences.getInstance();
      prefs.setBool("user_exist", true);
      final user = UserModel(
        name: userName,
        phone: phoneNum,
        image: userImageUrl,
        faceId: faceId,
      );
      final userJson = jsonEncode(user);
      prefs.setString("current_user", userJson);

      Get.offAll(() => TabsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xfff7f6fb),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(140)),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.black54,
                      backgroundImage: FileImage(widget.userImageFile),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: const Text(
                    "One last step! Enter your name and phone number so that we know who you are",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  margin: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          formInput(userName, _nameController),
                          const SizedBox(height: 10),
                          formInput(phoneNum, _phoneController),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: signUpUser,
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.deepPurple),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                  ),
                                ),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(14.0),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
