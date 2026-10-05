import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// "− 4 +" : a small whole-number picker (players needed).
class StepperField extends StatelessWidget {
  const StepperField({super.key, required this.value, required this.onChanged, this.min = 1, this.max = 50});

  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, bool enabled, VoidCallback onTap) => IconButton.outlined(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(Icons.remove, value > min, () => onChanged(value - 1)),
        SizedBox(
          width: 56,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        button(Icons.add, value < max, () => onChanged(value + 1)),
      ],
    );
  }
}
