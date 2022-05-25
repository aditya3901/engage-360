import 'dart:convert';
import 'package:engage_360/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../screens.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "";
  String userDp = "https://cdn.wallpapersafari.com/57/23/O0wQMK.jpg";

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("current_user") ?? "";
    final user = UserModel.fromJson(jsonDecode(userStr));

    username = user.name!;
    userDp = user.image!;
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
    Widget roundedButton(
        {required IconData icon, required VoidCallback onTap}) {
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(12),
        ),
        child: Icon(icon, size: 30),
      );
    }

    Widget listItem(IconData icon, String item) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 238, 249),
          border: Border.all(
            color: Colors.black12,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 15),
              Text(
                item,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              const Icon(
                CupertinoIcons.right_chevron,
                color: Colors.black54,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xfff7f6fb),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 260,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 45,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: const Icon(
                            Icons.settings,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const Text(
                          "Profile",
                          style: TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.clear();
                            Get.offAll(() => Welcome());
                          },
                          child: const Icon(
                            Icons.logout,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 100,
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
            const SizedBox(height: 30),
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
                roundedButton(
                  icon: Icons.phone,
                  onTap: () async {
                    final uri = Uri(
                      scheme: "tel",
                      path: "+917439687597",
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                roundedButton(
                  icon: FontAwesomeIcons.sms,
                  onTap: () async {
                    final uri = Uri(
                      scheme: "sms",
                      path: "+917439687597",
                    );
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                roundedButton(
                  icon: FontAwesomeIcons.github,
                  onTap: () async {
                    String url = "https://github.com/aditya3901";
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(
                        url,
                        mode: LaunchMode.platformDefault,
                        webViewConfiguration: const WebViewConfiguration(
                          enableDomStorage: true,
                          enableJavaScript: true,
                        ),
                        webOnlyWindowName: '_self',
                      );
                    }
                  },
                ),
                roundedButton(
                  icon: FontAwesomeIcons.linkedinIn,
                  onTap: () async {
                    String url =
                        "https://www.linkedin.com/in/aditya-das-86069b202/";
                    if (await canLaunchUrlString(url)) {
                      await launchUrlString(
                        url,
                        mode: LaunchMode.inAppWebView,
                        webViewConfiguration: const WebViewConfiguration(
                          enableDomStorage: true,
                          enableJavaScript: true,
                        ),
                        webOnlyWindowName: '_self',
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            listItem(Icons.security, "Privacy"),
            listItem(Icons.help_outline_rounded, "Help & Support"),
            listItem(Icons.person_add_alt_outlined, "Invite a Friend"),
            listItem(Icons.star_border, "Rate Us"),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
