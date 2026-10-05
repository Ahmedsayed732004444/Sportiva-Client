import 'package:flutter/material.dart';

// The design system's palette: white 60%, black 30%, main green 10%. Tints are read off the design file.
//
// The light palette is the design's. The dark one keeps the same roles (surface, text, gray steps) on dark values, and
// a lighter green so the brand colour stays readable on dark. The app root sets [dark] from the user's choice before
// building (and rebuilds the whole tree when it changes), so colours are read as they are now, never cached.
abstract final class AppColors {
  static bool dark = false;

  // What things sit on.
  static Color get background => dark ? const Color(0xFF0F1412) : const Color(0xFFFFFFFF);
  static Color get surface => dark ? const Color(0xFF1A211E) : const Color(0xFFFFFFFF);

  // Text and the gray steps.
  static Color get ink => dark ? const Color(0xFFF1F4F2) : const Color(0xFF0D1110);
  static Color get black600 => dark ? const Color(0xFFA9B3AE) : const Color(0xFF636363);
  static Color get gray200 => dark ? const Color(0xFF2A332F) : const Color(0xFFE0E0E0);
  static Color get gray400 => dark ? const Color(0xFF55615B) : const Color(0xFFBDBDBD);
  static Color get gray500 => dark ? const Color(0xFF7C8780) : const Color(0xFFA3A3A3);

  // The brand.
  static Color get primary => dark ? const Color(0xFF2F9272) : const Color(0xFF1B5743);
  static Color get primaryMid => dark ? const Color(0xFF4CBF98) : const Color(0xFF2A7F62);
  static const primaryLight = Color(0xFF7EE8C7);

  // Not part of the design system: validation and failed requests need a signal color.
  static Color get error => dark ? const Color(0xFFF2766E) : const Color(0xFFB3261E);

  // The same in both modes: text and icons on the brand colour or on a picture, and the dark veil over media.
  static const onBrand = Color(0xFFFFFFFF);
  static const scrim = Color(0xFF0D1110);
}
