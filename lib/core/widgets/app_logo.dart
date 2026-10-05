import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Placeholder until the real logo is chosen: replace the icon with the logo asset here and everywhere updates.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      child: Icon(Icons.sports_soccer, color: AppColors.white, size: size * 0.55),
    );
  }
}
