import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';

class TextParam {
  final String text;
  final Offset offset;
  final double fontSize;
  final FontWeight fontWeight;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final Color color;

  TextParam({
    required this.text,
    required this.offset,
    this.fontSize = 26,
    this.fontWeight = FontWeight.w700,
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.color = Colors.black,
  });
}

Future<Uint8List> generateData(List<TextParam> textParams) async {
  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  /// Background
  final backgroundPaint = Paint()..color = Colors.white;
  const backgroundRect = Rect.fromLTRB(372, 500, 0, 0);
  final backgroundPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(0)),
    )
    ..close();
  canvas.drawPath(backgroundPath, backgroundPaint);

  // Draw each text parameter
  for (var param in textParams) {
    drawText(
      canvas,
      param.text,
      param.offset,
      fontSize: param.fontSize,
      fontWeight: param.fontWeight,
      textAlign: param.textAlign,
      textDirection: param.textDirection,
      color: param.color,
    );
  }

  canvas.restore();
  final picture = recorder.endRecording();
  final pngBytes =
  await (await picture.toImage(372.toInt(), 500)) // Adjust height as needed
      .toByteData(format: ImageByteFormat.png);
  return pngBytes!.buffer.asUint8List();
}

void drawText(
    Canvas canvas,
    String text,
    Offset offset, {
      double fontSize = 26,
      FontWeight fontWeight = FontWeight.w500,
      TextAlign textAlign = TextAlign.left,
      TextDirection textDirection = TextDirection.ltr,
      Color color = Colors.black,
    }) {
  final textPainter = TextPainter(
    textDirection: textDirection,
    textAlign: textAlign,
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    ),
  );

  textPainter
    ..layout(
      maxWidth: 372,
    )
    ..paint(
      canvas,
      offset,
    );
}
