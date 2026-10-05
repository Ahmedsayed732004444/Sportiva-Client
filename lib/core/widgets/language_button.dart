import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/l10n_extension.dart';
import '../localization/locale_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Switches between Arabic and English; the button always shows the language you can switch to.
class LanguageButton extends ConsumerWidget {
  const LanguageButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: ref.read(localeProvider.notifier).toggle,
      icon: const Icon(Icons.language, color: AppColors.primary, size: 20),
      label: Text(context.l10n.switchLanguage, style: AppTextStyles.body2.copyWith(color: AppColors.primary)),
    );
  }
}
