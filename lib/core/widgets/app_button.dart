import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonStyle { filled, outlined }

// The design system's pill button. A null onPressed shows the disabled look; isLoading shows a spinner and ignores taps.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.style = AppButtonStyle.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonStyle style;
  // An icon before the label (a phone on "call").
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final filled = style == AppButtonStyle.filled;
    final foreground = filled ? AppColors.onBrand : AppColors.primary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      side: filled ? BorderSide.none : BorderSide(color: AppColors.primary),
    );

    return SizedBox(
      width: double.infinity,
      height: AppSpacing.fieldHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: shape,
          backgroundColor: filled ? AppColors.primary : AppColors.surface,
          foregroundColor: foreground,
          disabledBackgroundColor: filled ? AppColors.primary.withValues(alpha: 0.4) : AppColors.surface,
          disabledForegroundColor: filled ? AppColors.onBrand : AppColors.gray400,
        ),
        child: isLoading
            ? SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: foreground))
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Flexible(child: Text(label, style: AppTextStyles.cta.copyWith(color: null))),
                ],
              ),
      ),
    );
  }
}
