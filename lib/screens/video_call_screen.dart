import 'dart:convert';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:engage_360/constants.dart';
import './screens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoCallScreen extends StatefulWidget {
  String token;
  String channelName;

  VideoCallScreen({required this.token, required this.channelName});

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final users = <int>[];
  RtcEngine? _engine;
  bool _muteAudio = false;

  @override
  void initState() {
    super.initState();
    initForAgora();
  }

  Future<void> initForAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine = await RtcEngine.create(kAgoraAppId);

    await _engine!.enableVideo();
    await _engine!.enableAudio();
    await _engine!.enableFaceDetection(true);

    _engine!.setEventHandler(
      RtcEngineEventHandler(
        userJoined: (uid, elapsed) {
          setState(() {
            users.add(uid);
          });
        },
        userOffline: (uid, reason) {
          setState(() {
            users.remove(uid);
          });
        },
        facePositionChanged: (width, height, faces) {
          if (faces.isNotEmpty) {
            String out = jsonEncode(faces[0]);
            print("FACE DETECTED =>  $out");
          } else {
            print("NO FACE DETECTED!");
          }
        },
      ),
    );

    await _engine!.joinChannel(widget.token, widget.channelName, null, 0);
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
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _viewRows(),
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
