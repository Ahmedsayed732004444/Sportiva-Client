import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  // Built from the palette as it is now (see AppColors.dark).
  static ThemeData build() {
    final dark = AppColors.dark;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      borderSide: BorderSide(color: AppColors.gray400),
    );
    final scheme = dark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: AppColors.onBrand,
            secondary: AppColors.primaryMid,
            surface: AppColors.surface,
            onSurface: AppColors.ink,
            error: AppColors.error,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: AppColors.onBrand,
            secondary: AppColors.primaryMid,
            surface: AppColors.surface,
            onSurface: AppColors.ink,
            error: AppColors.error,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      fontFamily: 'Almarai',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: scheme,
      textTheme: TextTheme(
        headlineSmall: AppTextStyles.header,
        titleLarge: AppTextStyles.title,
        titleMedium: AppTextStyles.body1Semibold,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        bodySmall: AppTextStyles.caption,
        labelLarge: AppTextStyles.cta,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        titleTextStyle: AppTextStyles.title,
      ),
      dividerColor: AppColors.gray200,
      dialogTheme: DialogThemeData(backgroundColor: AppColors.surface, surfaceTintColor: AppColors.surface),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: AppColors.surface, surfaceTintColor: AppColors.surface),
      popupMenuTheme: PopupMenuThemeData(color: AppColors.surface, surfaceTintColor: AppColors.surface),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: AppColors.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
        hintStyle: AppTextStyles.body1.copyWith(color: AppColors.gray400),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: AppColors.primary)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: AppColors.error)),
        focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: AppColors.error)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTextStyles.body2.copyWith(color: AppColors.background),
      ),
    );
  }
}
