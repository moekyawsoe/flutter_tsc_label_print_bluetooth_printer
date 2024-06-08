import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

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
    this.fontSize = 23,
    this.fontWeight = FontWeight.w700,
    this.textAlign = TextAlign.left,
    this.textDirection = TextDirection.ltr,
    this.color = Colors.black,
  });
}

const double width = 570;
const double height = 670;

Future<Uint8List> generateData(List<TextParam> textParams) async {

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  /// Background
  final backgroundPaint = Paint()..color = Colors.white;
  // const backgroundRect = Rect.fromLTRB(372, 500, 0, 0);
  const backgroundRect = Rect.fromLTRB(0, 0, width, height);
  final backgroundPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(backgroundRect, const Radius.circular(0)),
    )
    ..close();
  canvas.drawPath(backgroundPath, backgroundPaint);

  // Border
  final borderPaint = Paint()
    ..color = Colors.black // Set border color
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0; // Set border width
  const borderRect = Rect.fromLTRB(0, 0, width-10, height-10);
  final borderPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(borderRect, const Radius.circular(0)),
    )
    ..close();
  canvas.drawPath(borderPath, borderPaint);

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

    // If the text is the separator line, draw a dashed line
    if (param.text == "") {
      drawDashedLine(canvas, Offset(0, param.offset.dy + 5), width-10); // Adjust y position as needed
    }
  }

  canvas.restore();
  final picture = recorder.endRecording();
  final pngBytes =
  await (await picture.toImage(width.toInt(), height.toInt())) // Adjust height as needed
      .toByteData(format: ImageByteFormat.png);
  return pngBytes!.buffer.asUint8List();
}

void drawText(Canvas canvas, String text, Offset offset,
    {double fontSize = 14, FontWeight fontWeight = FontWeight.normal, TextAlign textAlign = TextAlign.left, TextDirection textDirection = TextDirection.ltr, Color color = Colors.black}) {
  final textStyle = TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
  final textSpan = TextSpan(
    text: text,
    style: textStyle,
  );
  final textPainter = TextPainter(
    text: textSpan,
    textAlign: textAlign,
    textDirection: textDirection,
  );
  textPainter.layout();
  textPainter.paint(canvas, offset);
}

void drawDashedLine(Canvas canvas, Offset start, double width) {
  final paint = Paint()
    ..color = Colors.black
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke;

  const double dashWidth = 10.0;
  const double dashSpace = 5.0;
  double startX = start.dx;

  final path = Path();
  while (startX < width) {
    path.moveTo(startX, start.dy);
    startX += dashWidth;
    if (startX > width) {
      startX = width;
    }
    path.lineTo(startX, start.dy);
    startX += dashSpace;
  }

  canvas.drawPath(path, paint);
}

String formatPrice(int price) {
  final formatter = intl.NumberFormat('#,##0');
  String formattedPrice = formatter.format(price);
  return formattedPrice;
}