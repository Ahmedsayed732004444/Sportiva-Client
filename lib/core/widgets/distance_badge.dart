import 'package:flutter/material.dart';

import '../localization/l10n_extension.dart';
import '../location/distance.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// "3.2 km" in a solid pill: how far a club is, meant to sit on top of its picture so it is the first thing seen.
class DistanceBadge extends StatelessWidget {
  const DistanceBadge({super.key, required this.km});

  final double? km;

  @override
  Widget build(BuildContext context) {
    final value = km;
    if (value == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.near_me, size: 14, color: AppColors.onBrand),
          const SizedBox(width: 4),
          Text(
            context.l10n.kmShort(kmLabel(value)),
            style: AppTextStyles.caption.copyWith(color: AppColors.onBrand, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
