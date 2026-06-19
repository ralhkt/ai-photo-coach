import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_design_tokens.dart';

abstract final class AppTheme {
  static const Color accent = AppDesignTokens.accentPrimary;
  static const Color accentMuted = Color(0x29FFD60A);
  static const Color coach = AppDesignTokens.accentCoach;
  static const Color success = AppDesignTokens.accentSuccess;

  static const Color overlayLine = Color(0x40FFFFFF);
  static const Color overlayAccent = Color(0x66FFD60A);
  static const Color scaffoldDark = Color(0xFF000000);
  static const Color surfaceElevated = Color(0xFF1C1C1E);
  static const Color surfaceGrouped = Color(0xFF2C2C2E);
  static const Color surfaceQuaternary = Color(0xFF3A3A3C);

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: accent,
      onPrimary: Colors.black,
      secondary: coach,
      onSecondary: Colors.black,
      tertiary: success,
      surface: surfaceElevated,
      onSurface: AppDesignTokens.textPrimary,
      error: Color(0xFFFF453A),
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: scaffoldDark,
      colorScheme: colorScheme,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.1,
          color: AppDesignTokens.textPrimary,
        ),
      ),
      textTheme: _textTheme,
      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignTokens.cardRadius,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(AppDesignTokens.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppDesignTokens.textPrimary,
          minimumSize: const Size.fromHeight(AppDesignTokens.minTapTarget),
          side: BorderSide.none,
          backgroundColor: AppDesignTokens.fillTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppDesignTokens.fillQuaternary,
        selectedColor: AppDesignTokens.fillPrimary,
        labelStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppDesignTokens.textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          color: AppDesignTokens.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppDesignTokens.textSecondary,
        textColor: AppDesignTokens.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDesignTokens.spaceLg,
          vertical: AppDesignTokens.spaceXs,
        ),
        minLeadingWidth: 28,
      ),
      dividerTheme: const DividerThemeData(
        color: AppDesignTokens.separator,
        thickness: AppDesignTokens.hairline,
        space: AppDesignTokens.hairline,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surfaceGrouped,
        contentTextStyle: const TextStyle(color: AppDesignTokens.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignTokens.radiusMd),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceGrouped,
        shape: RoundedRectangleBorder(
          borderRadius: AppDesignTokens.sheetRadius,
        ),
        showDragHandle: true,
        dragHandleColor: AppDesignTokens.textQuaternary,
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    headlineLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.1,
      color: AppDesignTokens.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1.15,
      color: AppDesignTokens.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: AppDesignTokens.textPrimary,
    ),
    titleSmall: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: AppDesignTokens.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      height: 1.35,
      color: AppDesignTokens.textSecondary,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.1,
      height: 1.35,
      color: AppDesignTokens.textSecondary,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: AppDesignTokens.textTertiary,
    ),
    labelLarge: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: AppDesignTokens.textTertiary,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppDesignTokens.textTertiary,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppDesignTokens.textQuaternary,
    ),
  );
}