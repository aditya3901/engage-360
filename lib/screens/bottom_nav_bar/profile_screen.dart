import 'dart:convert';
import 'package:engage_360/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String username = "";
  String userDp = "https://cdn.wallpapersafari.com/57/23/O0wQMK.jpg";
  int present = 0, absent = 0;
  List<PieChartSectionData> pieData = [];
  bool gettingAttdn = true;

  void getAttendance() async {
    final ref = FirebaseDatabase.instance.ref("Attendance");
    await ref.once().then((event) {
      for (var room in event.snapshot.children) {
        for (var person in room.children) {
          if (person.key == username) {
            if (person.value == "Present") {
              present++;
            } else {
              absent++;
            }
          }
        }
      }
    });

    final presentPercent = (present / (present + absent)) * 100;
    final absentPercent = (absent / (present + absent)) * 100;
    pieData = [
      PieChartSectionData(
        title: "${presentPercent.toInt()}%",
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        color: Colors.deepPurple.shade400,
        value: presentPercent * 1.0,
      ),
      PieChartSectionData(
        title: "${absentPercent.toInt()}%",
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        color: Colors.red.shade400,
        value: absentPercent * 1.0,
      ),
    ];

    if (mounted) {
      setState(() {
        gettingAttdn = false;
      });
    }
  }

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("current_user");
    final json = jsonDecode(userStr!);
    final user = UserModel.fromJson(json);

    username = user.name!;
    userDp = user.image!;
    if (mounted) {
      setState(() {});
      getAttendance();
    }
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    Widget listItem(IconData icon, String item) {
      return Card(
        elevation: 3,
        color: const Color.fromARGB(255, 254, 254, 255),
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
            Card(
              elevation: 6,
              color: Colors.deepPurple,
              margin: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      FontAwesomeIcons.chartLine,
                      color: Color(0xfff7f6fb),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "Get Attendance",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xfff7f6fb),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            listItem(Icons.security, "Privacy"),
            listItem(Icons.help_outline_rounded, "Help & Support"),
            listItem(Icons.person_add_alt_outlined, "Invite a Friend"),
            listItem(Icons.star_border, "Rate Us"),
            const SizedBox(height: 80),
            // Padding(
            //   padding: const EdgeInsets.all(20),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     children: [
            //       const Divider(thickness: 1),
            //       const Text(
            //         "Meeting Attendance Details",
            //         style: TextStyle(
            //           fontSize: 16,
            //           color: Colors.black54,
            //         ),
            //       ),
            //       const Divider(thickness: 1),
            //       const SizedBox(height: 6),
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //         children: [
            //           SizedBox(
            //             height: 180,
            //             width: 180,
            //             child: gettingAttdn
            //                 ? const CupertinoActivityIndicator(radius: 16)
            //                 : (present == 0 && absent == 0)
            //                     ? const Center(
            //                         child: Text(
            //                           "No Data Available",
            //                           style: TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             color: Colors.black54,
            //                           ),
            //                         ),
            //                       )
            //                     : PieChart(
            //                         PieChartData(
            //                           sections: pieData,
            //                           sectionsSpace: 3,
            //                         ),
            //                       ),
            //           ),
            //           Column(
            //             children: [
            //               RichText(
            //                 text: TextSpan(
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 16,
            //                     fontFamily: GoogleFonts.robotoSlab().fontFamily,
            //                   ),
            //                   children: const [
            //                     WidgetSpan(
            //                       child: Icon(
            //                         Icons.circle,
            //                         size: 16,
            //                         color: Colors.deepPurple,
            //                       ),
            //                     ),
            //                     TextSpan(
            //                       text: "   Present",
            //                     ),
            //                   ],
            //                 ),
            //               ),
            //               const SizedBox(height: 6),
            //               RichText(
            //                 text: TextSpan(
            //                   style: TextStyle(
            //                     color: Colors.black,
            //                     fontSize: 16,
            //                     fontFamily: GoogleFonts.robotoSlab().fontFamily,
            //                   ),
            //                   children: const [
            //                     WidgetSpan(
            //                       child: Icon(
            //                         Icons.circle,
            //                         size: 16,
            //                         color: Colors.red,
            //                       ),
            //                     ),
            //                     TextSpan(
            //                       text: "   Absent ",
            //                     ),
            //                   ],
            //                 ),
            //               )
            //             ],
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 6),
            //       const Divider(thickness: 1),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
