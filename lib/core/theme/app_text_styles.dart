import 'package:flutter/material.dart';

import 'app_colors.dart';

// The design system's type scale (Almarai covers Arabic and Latin). "Auto" line height = null.
abstract final class AppTextStyles {
  static const _family = 'Almarai';

  static TextStyle get header =>
      TextStyle(fontFamily: _family, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle get title =>
      TextStyle(fontFamily: _family, fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle get cta =>
      TextStyle(fontFamily: _family, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle get body1Semibold =>
      TextStyle(fontFamily: _family, fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle get body1 =>
      TextStyle(fontFamily: _family, fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle get paragraph =>
      TextStyle(fontFamily: _family, fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, color: AppColors.ink);
  static TextStyle get underline => TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1,
    decoration: TextDecoration.underline,
    color: AppColors.ink,
  );
  static TextStyle get body2 =>
      TextStyle(fontFamily: _family, fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle get navBar =>
      TextStyle(fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle get caption =>
      TextStyle(fontFamily: _family, fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle get small =>
      TextStyle(fontFamily: _family, fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.ink);
}
