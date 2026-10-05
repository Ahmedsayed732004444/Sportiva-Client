import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// A row of pill options where one is selected (durations, court parts, times). Wraps onto more lines when it must.
class ChoiceChips<T> extends StatelessWidget {
  const ChoiceChips({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> options;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            label: Text(labelOf(option)),
            selected: option == selected,
            onSelected: (_) => onSelected(option),
            showCheckmark: false,
            labelStyle: AppTextStyles.body2.copyWith(color: option == selected ? AppColors.white : AppColors.black),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.white,
            side: BorderSide(color: option == selected ? AppColors.primary : AppColors.gray400),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }
}
