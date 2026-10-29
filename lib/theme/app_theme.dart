import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide theme definition following Material 3 guidelines and
/// HabitFlow's calm, Gen-Z-friendly dark visual style.
class AppTheme {
  AppTheme._();

  // Primary palette
  static const Color darkBackground = Color(0xFF0B0F14);
  static const Color darkSurface = Color(0xFF141B23);
  static const Color darkSurfaceVariant = Color(0xFF1C2530);
  static const Color darkBorder = Color(0xFF222F3E);

  static const Color primaryMint = Color(0xFF34D399);
  static const Color accentTeal = Color(0xFF22D3EE);
  static const Color secondaryViolet = Color(0xFFA78BFA);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);

  static const Color textMain = Color(0xFFE6EDF3);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textSubtle = Color(0xFF64748B);

  // Light theme alternative colors
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color textMainLight = Color(0xFF0F172A);
  static const Color textMutedLight = Color(0xFF64748B);

  // Border radius standards
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 22.0;
  static const double radiusPill = 999.0;

  /// Dark Theme (Default)
  static ThemeData get darkTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    final headingFont = GoogleFonts.sora();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryMint,
        onPrimary: Color(0xFF062A1F),
        secondary: secondaryViolet,
        onSecondary: Color(0xFF251048),
        tertiary: accentTeal,
        surface: darkSurface,
        onSurface: textMain,
        error: dangerRed,
        onError: Colors.white,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.sora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textMain,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.sora(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textMain,
          letterSpacing: -0.5,
        ),
        headlineLarge: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        headlineMedium: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        titleMedium: GoogleFonts.sora(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: textMain,
          height: 1.4,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.sora(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: headingFont.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: primaryMint,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryMint,
        foregroundColor: const Color(0xFF062A1F),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryMint, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: dangerRed),
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSurfaceVariant,
        contentTextStyle: const TextStyle(color: textMain),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          side: const BorderSide(color: darkBorder),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Light Theme (Optional preference)
  static ThemeData get lightTheme {
    final baseText = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF059669),
        onPrimary: Colors.white,
        secondary: secondaryViolet,
        tertiary: accentTeal,
        surface: lightSurface,
        onSurface: textMainLight,
        error: dangerRed,
        onError: Colors.white,
      ),
      textTheme: baseText.copyWith(
        displayLarge: GoogleFonts.sora(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textMainLight,
        ),
        headlineLarge: GoogleFonts.sora(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textMainLight,
        ),
        headlineMedium: GoogleFonts.sora(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textMainLight,
        ),
        titleLarge: GoogleFonts.sora(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textMainLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: textMainLight,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: textMutedLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: textMainLight,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: Color(0xFF059669),
        unselectedItemColor: textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: const Color(0xFF059669),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }
}
