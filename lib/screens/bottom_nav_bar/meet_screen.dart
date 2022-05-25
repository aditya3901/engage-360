import 'dart:convert';
import 'package:engage_360/models/user_model.dart';
import 'package:engage_360/screens/screens.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../constants.dart';

class MeetScreen extends StatefulWidget {
  @override
  _MeetScreenState createState() => _MeetScreenState();
}

class _MeetScreenState extends State<MeetScreen> {
  bool _gettingToken = false;
  final _joinCode = TextEditingController();
  bool gettingAttdn = false;
  int present = 0, absent = 0;
  List<PieChartSectionData> pieData = [];
  UserModel? user;

  void getAgoraToken(String channelName, String purpose) async {
    setState(() {
      _gettingToken = true;
    });

    if (channelName == "") {
      const uuid = Uuid();
      channelName = uuid.v1().substring(0, 8);
    }

    final response = await http.get(Uri.parse(kTokenServerUrl + channelName));
    final data = jsonDecode(response.body);
    final token = data["token"];

    if (mounted) {
      setState(() {
        _gettingToken = false;
      });
    }

    if (token != null && token != "") {
      if (purpose == "create") {
        createMeet(token, channelName);
      } else {
        Get.offAll(
          () => VideoCallScreen(
            clientRole: "attendee",
            token: token,
            channelName: channelName,
          ),
        );
      }
    } else {
      Get.snackbar(
        "Unable to get token..",
        "We had some problem. Please try again",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void createMeet(String token, String channelName) {
    Get.defaultDialog(
      onWillPop: () => Future.value(false),
      barrierDismissible: false,
      radius: 10,
      titlePadding: const EdgeInsets.only(bottom: 10, top: 20),
      title: "Invite Others",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      content: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Text(
              "Share this code with others to allow them into your session",
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Room Id : ${channelName.substring(0, 2)}-${channelName.substring(2, 6)}-${channelName.substring(6, 8)}",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: channelName),
                  );
                },
                icon: const Icon(
                  Icons.copy,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () {
                  Get.offAll(
                    () => VideoCallScreen(
                      clientRole: "host",
                      token: token,
                      channelName: channelName,
                    ),
                  );
                },
                child: const Text(
                  "Join",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget myBottomSheet() {
    return Container(
      padding: MediaQuery.of(context).viewInsets,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _joinCode,
              decoration: const InputDecoration(
                labelText: "Enter Room Code",
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    final id = _joinCode.text.trim();
                    if (id.isEmpty) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      getAgoraToken(id, "join");
                    }
                  },
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String userStr = prefs.getString("current_user") ?? "";
    user = UserModel.fromJson(jsonDecode(userStr));
  }

  void getAttendance() async {
    if (mounted) {
      setState(() {
        gettingAttdn = true;
      });
    }

    final ref = FirebaseDatabase.instance.ref("Attendance");
    await ref.once().then((event) {
      for (var room in event.snapshot.children) {
        for (var person in room.children) {
          if (person.key == user!.name) {
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

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

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
      body: ModalProgressHUD(
        inAsyncCall: _gettingToken,
        child: Container(
          margin: const EdgeInsets.only(bottom: 60),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () {
                                getAgoraToken("", "create");
                              },
                              icon: const Icon(
                                Icons.video_camera_front,
                                size: 40,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Create",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.bottomSheet(
                                  myBottomSheet(),
                                  backgroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  enableDrag: true,
                                );
                              },
                              icon: const Icon(
                                Icons.add_a_photo,
                                size: 36,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Join",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 243, 238, 249),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  child: ExpansionTile(
                    onExpansionChanged: (val) {
                      if (val == true) {
                        getAttendance();
                      }
                    },
                    tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                    leading: const Icon(
                      FontAwesomeIcons.chartLine,
                      color: Colors.deepPurple,
                    ),
                    title: const Text(
                      "Show Attendance",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    children: [
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: gettingAttdn
                            ? const CupertinoActivityIndicator(radius: 16)
                            : (present == 0 && absent == 0)
                                ? const Center(
                                    child: Text(
                                      "No Data Available",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  )
                                : PieChart(
                                    PieChartData(
                                      sections: pieData,
                                      sectionsSpace: 3,
                                    ),
                                  ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const SizedBox(width: 20),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: GoogleFonts.robotoSlab().fontFamily,
                              ),
                              children: const [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                TextSpan(
                                  text: "  Present",
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontFamily: GoogleFonts.robotoSlab().fontFamily,
                              ),
                              children: const [
                                WidgetSpan(
                                  child: Icon(
                                    Icons.circle,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                TextSpan(
                                  text: "  Absent",
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Scheduled Meetings",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 35),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/illustration-3.png',
                  ),
                ),
                const SizedBox(height: 26),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    "Your meeting is safe",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 50),
                  child: const Text(
                    "No one outside of your organisation can join a meeting unless invited or admitted by the host",
                    textAlign: TextAlign.center,
                    style: TextStyle(),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
