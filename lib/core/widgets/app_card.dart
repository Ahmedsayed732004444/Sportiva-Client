import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';

// The design system's card: white (or [color]), rounded, with the drop shadow, and a ripple when it can be tapped.
// The shadow sits on the outside container: drawn on the Material it would darken the card itself.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap, this.color, this.radius = 16});

  final Widget child;
  final VoidCallback? onTap;
  // The card's colour; the surface colour when left out.
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    return Container(
      decoration: BoxDecoration(color: color ?? AppColors.surface, borderRadius: shape, boxShadow: AppShadows.drop),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: child),
      ),
    );
  }
}
