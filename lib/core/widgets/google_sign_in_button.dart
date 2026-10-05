import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// The "G" of Google, drawn in its four colors. Swap for the official asset when the brand files are added.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed, this.isLoading = false});

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: isLoading ? null : onPressed,
      radius: 32,
      child: SizedBox.square(
        dimension: 48,
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
              )
            : const CustomPaint(painter: _GoogleGPainter()),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);
  static const _blue = Color(0xFF4285F4);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.17;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: size.width * 0.33);
    Paint ring(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double rad(double degrees) => degrees * math.pi / 180;
    canvas.drawArc(rect, rad(-45), rad(-90), false, ring(_red));
    canvas.drawArc(rect, rad(-135), rad(-90), false, ring(_yellow));
    canvas.drawArc(rect, rad(135), rad(-90), false, ring(_green));
    canvas.drawArc(rect, rad(45), rad(-45), false, ring(_blue));

    final barY = size.center(Offset.zero).dy;
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.5, barY - stroke / 2, size.width * 0.84, barY + stroke / 2),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
