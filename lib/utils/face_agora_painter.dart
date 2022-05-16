import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

class FaceAgoraPainter extends CustomPainter {
  final List<FacePositionInfo> faces;
  final Size absoluteImageSize;

  FaceAgoraPainter(this.absoluteImageSize, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = absoluteImageSize.width;
    final double scaleY = absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    for (FacePositionInfo face in faces) {
      canvas.drawRRect(
        RRect.fromLTRBR(
          face.x * 1.0,
          face.y * 1.0,
          (face.x + face.width) * 1.0,
          (face.y + face.height) * 1.0,
          const Radius.circular(10),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceAgoraPainter oldDelegate) => true;
}
