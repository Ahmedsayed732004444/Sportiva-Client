import 'package:flutter/material.dart';

import 'app_colors.dart';

// The design system's type scale (Almarai covers Arabic and Latin). "Auto" line height = null.
abstract final class AppTextStyles {
  static const _family = 'Almarai';

  static const header = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const title = TextStyle(
    fontFamily: _family,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const cta = TextStyle(fontFamily: _family, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.black);
  static const body1Semibold = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
  );
  static const body1 = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const paragraph = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.black,
  );
  static const underline = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1,
    decoration: TextDecoration.underline,
    color: AppColors.black,
  );
  static const body2 = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const navBar = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
  static const small = TextStyle(
    fontFamily: _family,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );
}
