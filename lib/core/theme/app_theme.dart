import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const Color overlayLine = Color(0x99FFFFFF);
  static const Color overlayAccent = Color(0xCCFFD54F);
  static const Color scaffoldDark = Color(0xFF0D0D0D);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: scaffoldDark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFD54F),
        secondary: Color(0xFF80CBC4),
        surface: Color(0xFF1A1A1A),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}