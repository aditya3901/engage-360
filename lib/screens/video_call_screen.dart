import 'dart:convert';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:engage_360/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:engage_360/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoCallScreen extends StatefulWidget {
  String clientRole;
  String token;
  String channelName;

  VideoCallScreen({
    required this.clientRole,
    required this.token,
    required this.channelName,
  });

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final users = <int>[];
  int hostUid = 0;
  RtcEngine? _engine;
  bool _muteAudio = false;
  bool isInitialized = false;
  bool inCooldown = false, faceDetected = false;
  int violationPoint = 0;

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  void getHostUid(int uid) async {
    final ref = FirebaseDatabase.instance
        .ref("Channel-Name")
        .child(widget.channelName)
        .child("host_uid");
    if (widget.clientRole == "host") {
      hostUid = uid;
      await ref.set(hostUid);
    } else {
      final snapshot = await ref.get();
      hostUid = int.parse("${snapshot.value}");
    }
  }

  void markAttendance(String attdn) async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString("current_user");
    final user = UserModel.fromJson(jsonDecode(userStr!));

    final ref = FirebaseDatabase.instance
        .ref("Attendance")
        .child(widget.channelName)
        .child(user.name!);
    if (attdn == "present") {
      await ref.set("Present");
    } else {
      await ref.set("Absent");
    }
  }

  Future<void> initForAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.create(kAgoraAppId);

    await _engine!.enableVideo();
    await _engine!.enableAudio();
    await _engine!.enableFaceDetection(true);

    _engine!.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (channel, uid, elapsed) {
          getHostUid(uid);
        },
        userJoined: (uid, elapsed) {
          setState(() {
            users.add(uid);
          });
        },
        userOffline: (uid, reason) {
          if (uid == hostUid) {
            markAttendance("present");
            _engine!.leaveChannel();

            Get.snackbar(
              "Host Left. Meet is now over.",
              "You've been marked Present!",
              snackPosition: SnackPosition.TOP,
              duration: const Duration(seconds: 4),
            );

            Get.offAll(() => TabsScreen());
          } else {
            setState(() {
              users.remove(uid);
            });
          }
        },
        facePositionChanged: (width, height, faces) {
          // Face Detected
          if (faces.isNotEmpty) {
            setState(() {
              faceDetected = true;
            });
          }
          // No Face Detected
          else {
            if (inCooldown == false) {
              violationPoint++;
              if (violationPoint == 3) {
                markAttendance("absent");

                _engine!.leaveChannel();
                Get.snackbar(
                  "No Face Detected",
                  "You've been marked Absent!",
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 4),
                );

                Get.offAll(() => TabsScreen());
              }
              inCooldown = true;

              Future.delayed(
                const Duration(seconds: 10),
                () {
                  inCooldown = false;
                },
              );
            }
            if (mounted) {
              setState(() {
                faceDetected = false;
              });
            }
          }
        },
      ),
    );

    await _engine!.joinChannel(widget.token, widget.channelName, null, 0);

    setState(() {
      isInitialized = true;
    });
  }

  // Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid)));
    return list;
  }

  // Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  // Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return SizedBox(
          child: Column(
            children: <Widget>[_videoView(views[0])],
          ),
        );
      case 2:
        return SizedBox(
          child: Column(
            children: <Widget>[
              _expandedVideoRow([views[0]]),
              _expandedVideoRow([views[1]])
            ],
          ),
        );
      case 3:
        return SizedBox(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 3))
            ],
          ),
        );
      case 4:
        return SizedBox(
          child: Column(
            children: <Widget>[
              _expandedVideoRow(views.sublist(0, 2)),
              _expandedVideoRow(views.sublist(2, 4))
            ],
          ),
        );
      default:
    }
    return Container();
  }

  @override
  void dispose() {
    _engine!.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                isInitialized ? _viewRows() : Container(),
                faceDetected
                    ? Container()
                    : Center(
                        child: Text(
                          "NO FACE DETECTED\nViolation Point: $violationPoint/3",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await _engine!.switchCamera();
                    },
                    child: const Icon(
                      Icons.cameraswitch,
                      size: 24,
                      color: Colors.deepPurple,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                      primary: Colors.white,
                      onPrimary: Colors.deepPurple,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _engine!.leaveChannel();
                      Get.offAll(() => TabsScreen());
                    },
                    child:
                        const Icon(Icons.call, size: 24, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                      primary: Colors.red,
                      onPrimary: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _muteAudio = !_muteAudio;
                      await _engine!.muteLocalAudioStream(_muteAudio);
                      setState(() {});
                    },
                    child: Icon(
                      _muteAudio ? Icons.mic_off : Icons.mic,
                      size: 24,
                      color: Colors.deepPurple,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                      primary: Colors.white,
                      onPrimary: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
