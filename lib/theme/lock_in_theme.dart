import 'package:flutter/material.dart';

class LockInColors {
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const surfaceAlt = Color(0xFF1E1E1E);
  static const line = Color(0xFF2A2A2A);
  static const white = Color(0xFFF5F5F5);
  static const grey = Color(0xFF8A8A8A);
  static const darkGrey = Color(0xFF4A4A4A);
}

ThemeData buildLockInTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: LockInColors.bg,
    fontFamily: 'monospace',
    colorScheme: const ColorScheme.dark(
      primary: LockInColors.white,
      surface: LockInColors.surface,
    ),
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
  );
}

TextStyle dot(
  double size, {
  Color color = LockInColors.white,
  FontWeight weight = FontWeight.w400,
}) {
  return TextStyle(
    fontFamily: 'monospace',
    fontSize: size,
    color: color,
    fontWeight: weight,
    letterSpacing: size * 0.12,
    height: 1.25,
  );
}
