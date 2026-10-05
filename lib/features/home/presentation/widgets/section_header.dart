import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.m,
        AppSpacing.screenPadding,
        AppSpacing.xs,
      ),
      child: Text(title, style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
