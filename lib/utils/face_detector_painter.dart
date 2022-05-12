import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

class FaceDetectorPainter extends CustomPainter {
  final Size absoluteImageSize;
  final List<Face> faces;
  CameraLensDirection cameraLensDirection;

  FaceDetectorPainter(
      this.absoluteImageSize, this.faces, this.cameraLensDirection);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    for (Face face in faces) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          cameraLensDirection == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.right) * scaleX
              : face.boundingBox.left * scaleX,
          face.boundingBox.top * scaleY,
          cameraLensDirection == CameraLensDirection.front
              ? (absoluteImageSize.width - face.boundingBox.left) * scaleX
              : face.boundingBox.right * scaleX,
          face.boundingBox.bottom * scaleY,
          const Radius.circular(10),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
