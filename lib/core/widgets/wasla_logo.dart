import 'package:flutter/material.dart';
import 'dart:math' as math;

class WaslaLogo extends StatelessWidget {
  final double fontSize;
  final Color? color;
  final bool showText;

  const WaslaLogo({
    super.key,
    this.fontSize = 48,
    this.color,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(fontSize * 3, fontSize * 1.5),
          painter: _LogoPainter(color: logoColor),
          child: showText
              ? Text(
                  'Wasla',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w900,
                    color: logoColor,
                    letterSpacing: -1,
                  ),
                )
              : SizedBox(width: fontSize * 3, height: fontSize),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  final Color color;

  _LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // This is a simplified representation.
    // In a real custom logo, we would use paths.
    // Here we draw a curved arrow from the 'W' area to the 'l' area.

    final paint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.08
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Starting point (near bottom of W area)
    double startX = size.width * 0.12;
    double startY = size.height * 0.85;

    // Ending point (near top of l area)
    double endX = size.width * 0.70;
    double endY = size.height * 0.25;

    path.moveTo(startX, startY);

    // Control point for a nice elegant curve
    double controlX = size.width * 0.35;
    double controlY = size.height * -0.1; // Go above the text for an arc

    path.quadraticBezierTo(controlX, controlY, endX, endY);

    canvas.drawPath(path, paint);

    // Draw Arrowhead at the end of the path
    final arrowPaint = Paint()
      ..color = color.withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    double arrowSize = size.height * 0.18;

    // Calculate angle for arrowhead
    // At the end of quadraticBezierTo, the direction is roughly end - control
    double angle = math.atan2(endY - controlY, endX - controlX);

    arrowPath.moveTo(endX, endY);
    arrowPath.lineTo(
      endX - arrowSize * math.cos(angle - math.pi / 6),
      endY - arrowSize * math.sin(angle - math.pi / 6),
    );
    arrowPath.lineTo(
      endX - arrowSize * math.cos(angle + math.pi / 6),
      endY - arrowSize * math.sin(angle + math.pi / 6),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
