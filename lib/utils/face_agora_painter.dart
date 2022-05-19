import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

class FaceAgoraPainter extends CustomPainter {
  final List<FacePositionInfo> faces;
  final Size absoluteImageSize;

  FaceAgoraPainter(this.absoluteImageSize, this.faces);

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;

    for (FacePositionInfo face in faces) {
      canvas.drawCircle(Offset(face.x * scaleX, face.y * scaleY), 3, paint);

      canvas.drawRRect(
        RRect.fromLTRBR(
          (absoluteImageSize.width - (face.x + face.width)) * scaleX,
          face.y * scaleY,
          (absoluteImageSize.width - face.x) * scaleX,
          (face.y + face.height) * scaleY,
          const Radius.circular(10),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceAgoraPainter oldDelegate) => true;
}
