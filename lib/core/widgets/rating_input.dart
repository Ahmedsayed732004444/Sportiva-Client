import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

// Five tappable stars.
class RatingInput extends StatelessWidget {
  const RatingInput({super.key, required this.value, required this.onChanged, this.size = 36});

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var star = 1; star <= 5; star++)
        IconButton(
          onPressed: () => onChanged(star),
          iconSize: size,
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(minWidth: size + 6, minHeight: size + 6),
          icon: Icon(star <= value ? Icons.star_rounded : Icons.star_border_rounded, color: AppColors.primary),
        ),
    ],
  );
}
