import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      borderSide: const BorderSide(color: AppColors.gray400),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Almarai',
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.white,
        secondary: AppColors.primaryMid,
        surface: AppColors.white,
        onSurface: AppColors.black,
        error: AppColors.error,
      ),
      textTheme: const TextTheme(
        headlineSmall: AppTextStyles.header,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.body1Semibold,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.cta,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        titleTextStyle: AppTextStyles.title,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        hintStyle: AppTextStyles.body1.copyWith(color: AppColors.gray400),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.primary)),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: border.copyWith(borderSide: const BorderSide(color: AppColors.error)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.black,
        contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.white),
      ),
    );
  }
}
