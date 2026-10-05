import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

// "—— or login with ——"
class OrDivider extends StatelessWidget {
  const OrDivider(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    const line = Expanded(child: Divider(color: AppColors.gray200, thickness: 1));
    return Row(
      children: [
        line,
        Flexible(
          flex: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.title.copyWith(color: AppColors.primaryMid, fontSize: 16),
            ),
          ),
        ),
        line,
      ],
    );
  }
}
