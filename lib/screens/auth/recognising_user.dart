import 'dart:convert';
import 'dart:io';
import 'package:engage_360/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants.dart';
import '../../services/multipart_request_service.dart';
import 'package:http/http.dart' as http;
import '../screens.dart';

class RecognisingUser extends StatefulWidget {
  String purpose;
  File userImageFile;
  UserModel user;
  RecognisingUser(this.purpose, this.userImageFile, this.user);

  @override
  _RecognisingUserState createState() => _RecognisingUserState();
}

class _RecognisingUserState extends State<RecognisingUser> {
  void detectFaceFromImage() async {
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
      if (widget.purpose == "exam") {
        Get.offAll(() => TabsScreen());
      } else {
        Get.offAll(() => Welcome());
      }
    } else {
      final faceId = data[0]["faceId"];

      verifyFaceMatch(faceId);
    }
  }

  void verifyFaceMatch(String faceId) async {
    final prevFaceId = widget.user.faceId;

    final body = {"faceId1": faceId, "faceId2": prevFaceId};

    final response = await http.post(
      Uri.parse(kVerifyUrl),
      headers: {
        "Ocp-Apim-Subscription-Key": "51bbe14a2e9f4bf5b2f50c6d2f61a270",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (data["isIdentical"] == true) {
      if (widget.purpose == "exam") {
        Get.offAll(() => ProctoringScreen());
      } else {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("user_exist", true);
        final user = UserModel(
          name: widget.user.name,
          phone: widget.user.phone,
          image: widget.user.image,
          faceId: widget.user.faceId,
        );
        final userJson = jsonEncode(user);
        prefs.setString("current_user", userJson);

        Get.offAll(() => TabsScreen());
      }
    } else {
      if (widget.purpose == "exam") {
        Get.snackbar(
          "Face Didn't Match",
          "Try clicking the picture with a better lighting.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        Get.offAll(() => TabsScreen());
      } else {
        Get.snackbar(
          "Login Failed! Face Didn't Match",
          "Try clicking the picture with a better lighting.",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        Get.offAll(() => Welcome());
      }
    }
  }

  @override
  void initState() {
    super.initState();
    detectFaceFromImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f6fb),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CupertinoActivityIndicator(radius: 16),
            SizedBox(height: 14),
            Text(
              "Verifying Face...",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
