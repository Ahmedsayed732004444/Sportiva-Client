import 'package:flutter/material.dart';

// The design system's palette: white 60%, black 30%, main green 10%. Tints are read off the design file.
abstract final class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const gray200 = Color(0xFFE0E0E0);
  static const gray400 = Color(0xFFBDBDBD);
  static const gray500 = Color(0xFFA3A3A3);

  static const black = Color(0xFF0D1110);
  static const black600 = Color(0xFF636363);
  static const black800 = Color(0xFF3C3C3D);

  static const primary = Color(0xFF1B5743);
  static const primaryMid = Color(0xFF2A7F62);
  static const primaryLight = Color(0xFF7EE8C7);

  // Not part of the design system: validation and failed requests need a signal color.
  static const error = Color(0xFFB3261E);
}
