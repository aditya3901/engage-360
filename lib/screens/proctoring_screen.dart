import 'dart:io';
import 'package:camera/camera.dart';
import 'package:engage_360/screens/bottom_nav_bar/tabs_screen.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/utils.dart';

class ProctoringScreen extends StatefulWidget {
  @override
  _ProctoringScreenState createState() => _ProctoringScreenState();
}

class _ProctoringScreenState extends State<ProctoringScreen> {
  File? cameraImage;
  CameraController? cameraController;
  CameraLensDirection cameraDirection = CameraLensDirection.front;
  CameraDescription? description;
  List<Face>? faceList;
  FaceDetector? faceDetector;
  bool inCooldown = false;
  int violationCounter = 0;

  initCamera() async {
    description = await UtilsScanner.getCamera(cameraDirection);

    cameraController = CameraController(description!, ResolutionPreset.low);

    faceDetector = FirebaseVision.instance.faceDetector(
      const FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        mode: FaceDetectorMode.fast,
      ),
    );

    await cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      cameraController!.startImageStream((imageFromStream) => {
            performDetectionOnStreamFrames(imageFromStream),
          });
    });
  }

  performDetectionOnStreamFrames(CameraImage cameraImage) async {
    UtilsScanner.detect(
      image: cameraImage,
      detectInImage: faceDetector!.processImage,
      imageRotaion: description!.sensorOrientation,
    ).then((dynamic results) {
      faceList = results;
      if (faceList == null || faceList!.isEmpty) {
        if (inCooldown == false) {
          violationCounter++;
          inCooldown = true;
          Future.delayed(
            const Duration(seconds: 10),
            () {
              inCooldown = false;
            },
          );
        }
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    cameraController?.dispose();
    faceDetector!.close();
    super.dispose();
  }

  Widget _buildImage() {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: cameraController == null
          ? const Center(child: null)
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CameraPreview(cameraController!),
                _buildResults(),
              ],
            ),
    );
  }

  Widget _buildResults() {
    const defaultText = Text("");

    if (faceList == null ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      return defaultText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      cameraController!.value.previewSize!.height,
      cameraController!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, faceList!, cameraDirection);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              _buildImage(),
              Container(
                margin: const EdgeInsets.only(bottom: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
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
                      onPressed: () {
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
                      onPressed: () {},
                      child: const Icon(
                        Icons.mic,
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
              ),
            ],
          ),
          faceList == null || faceList!.isEmpty
              ? Center(
                  child: Text(
                    "NO FACE DETECTED\nViolation Count: $violationCounter/3",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
