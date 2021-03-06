import 'dart:io';
import 'package:camera/camera.dart';
import 'package:engage_360/models/user_model.dart';
import 'package:engage_360/screens/screens.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../utils/utils.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  String purpose;
  UserModel? user;
  CameraScreen({required this.purpose, this.user});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? cameraImage;
  CameraController? cameraController;
  CameraLensDirection cameraDirection = CameraLensDirection.front;
  CameraDescription? description;
  List<Face>? faceList;
  FaceDetector? faceDetector;
  dynamic scanResults;
  bool isWorking = false;

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
      if (mounted) {
        setState(() {
          scanResults = results;
          faceList = scanResults;
        });
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
    if (widget.purpose != "exam") {
      cameraController?.dispose();
      faceDetector!.close();
    }

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

    if (scanResults == null ||
        cameraController == null ||
        !cameraController!.value.isInitialized) {
      return defaultText;
    }

    CustomPainter painter;

    final Size imageSize = Size(
      cameraController!.value.previewSize!.height,
      cameraController!.value.previewSize!.width,
    );
    painter = FaceDetectorPainter(imageSize, scanResults, cameraDirection);
    return CustomPaint(
      painter: painter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: isWorking,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                _buildImage(),
                Container(
                  margin: const EdgeInsets.only(bottom: 26),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (cameraController != null &&
                          cameraController!.value.isInitialized) {
                        await cameraController!.initialize();
                        final image = await cameraController!.takePicture();
                        cameraImage = File(image.path);
                        if (widget.purpose == "signup") {
                          Get.offAll(() => SignUpScreen(cameraImage!));
                        } else if (widget.purpose == "login") {
                          Get.offAll(() => RecognisingUser(
                              "login", cameraImage!, widget.user!));
                        } else {
                          Get.offAll(() => RecognisingUser(
                              "exam", cameraImage!, widget.user!));
                        }
                      }
                    },
                    child: const Icon(Icons.camera_alt,
                        size: 30, color: Colors.white),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(18),
                      primary: Colors.deepPurple, // <-- Button color
                      onPrimary: Colors.white, // <-- Splash color
                    ),
                  ),
                )
              ],
            ),
            faceList == null || faceList!.isEmpty
                ? const Center(
                    child: Text(
                      "NO FACE DETECTED !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
