import 'package:flutter/material.dart';

class BatteryIcon extends StatelessWidget {
  final double batteryPercentage;
  final Color fillColor;
  final Color backgroundColor;

  BatteryIcon({
    required this.batteryPercentage,
    this.fillColor = Colors.green,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 16,
      child: CustomPaint(
        painter: BatteryPainter(
          batteryPercentage: batteryPercentage,
          fillColor: fillColor,
          backgroundColor: backgroundColor,
        ),
      ),
    );
  }
}

class BatteryPainter extends CustomPainter {
  final double batteryPercentage;
  final Color fillColor;
  final Color backgroundColor;

  BatteryPainter({
    required this.batteryPercentage,
    required this.fillColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double borderWidth = 1.5;
    final double batteryWidth = size.width - 2 * borderWidth;
    final double batteryHeight = size.height - 2 * borderWidth;

    // Draw background
    final backgroundRect = Rect.fromLTRB(
      borderWidth,
      borderWidth,
      borderWidth + batteryWidth,
      borderWidth + batteryHeight,
    );
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(backgroundRect, backgroundPaint);

    // Calculate fill width
    final double fillWidth = (batteryWidth - 2 * borderWidth) * batteryPercentage;
    final fillRect = Rect.fromLTRB(
      borderWidth + borderWidth / 2 - borderWidth % 2,
      borderWidth + borderWidth / 2 - borderWidth % 2,
      borderWidth + borderWidth / 2 + fillWidth,
      size.height - borderWidth / 2 - - borderWidth % 2,
    );
    final fillPaint = Paint()..color = fillColor;
    canvas.drawRect(fillRect, fillPaint);
  }

  @override
  bool shouldRepaint(BatteryPainter oldDelegate) {
    return oldDelegate.batteryPercentage != batteryPercentage ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
