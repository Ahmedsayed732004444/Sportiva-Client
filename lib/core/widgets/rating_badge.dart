import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.count});

  final double? rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    if (rating == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.primary),
        const SizedBox(width: 2),
        Text(rating!.toStringAsFixed(1), style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700)),
        if (count != null && count! > 0)
          Text(' ($count)', style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
      ],
    );
  }
}
