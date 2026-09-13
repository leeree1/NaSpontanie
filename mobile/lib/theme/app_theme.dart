import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  // Główne barwy marki i kompatybilność
  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF0F3E2E);
  static const Color primaryDark = Color(0xFF0F3E2E);
  static const Color primaryMid = Color(0xFF1B5E43);
  static const Color primaryLight = Color(0xFFE8F5EE);
  static const Color primarySoft = Color(0xFFC8E6C9);

  // Akcenty i gamifikacja
  static const Color secondary = Color(0xFFFFB300);
  static const Color accent = Color(0xFF00C896);
  static const Color accentSoft = Color(0xFFD7F9EE);
  static const Color xpGold = Color(0xFFFFB300);
  static const Color xpGoldSoft = Color(0xFFFFF8E1);
  static const Color fireOrange = Color(0xFFFF5722);
  static const Color error = Color(0xFFE53935);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Ramki i teksty
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color muted = Color(0xFFB0B0A8);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);

  // Gradienty
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F3E2E), Color(0xFF1E6F4C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppStyles {
  const AppStyles._();

  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F3E2E).withOpacity(0.06),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final textTheme = GoogleFonts.interTextTheme();
    const radius = BorderRadius.all(Radius.circular(12));

    return ThemeData(
      useMaterial3: false,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.onPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          shape: const RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: AppColors.cardBorder),
          shape: const RoundedRectangleBorder(borderRadius: radius),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryMid),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      chipTheme: const ChipThemeData(
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surface,
        disabledColor: AppColors.muted,
        labelStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        secondaryLabelStyle: TextStyle(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        showCheckmark: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}