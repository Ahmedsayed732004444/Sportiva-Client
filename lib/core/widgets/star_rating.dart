import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Five stars filled to the rating (halves included), then the number and how many people rated.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.count, this.size = 16});

  final double? rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final value = rating;
    if (value == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          Icon(
            value >= star - 0.25
                ? Icons.star_rounded
                : (value >= star - 0.75 ? Icons.star_half_rounded : Icons.star_outline_rounded),
            size: size,
            color: AppColors.primary,
          ),
        const SizedBox(width: 4),
        Text(value.toStringAsFixed(1), style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w700)),
        if (count != null && count! > 0)
          Text(' ($count)', style: AppTextStyles.caption.copyWith(color: AppColors.black600)),
      ],
    );
  }
}
