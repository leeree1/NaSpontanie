import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  const AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF1F1F1);
  static const Color accent = Color(0xFFB4DB4A);
  static const Color accentAction = Color(0xFF9EC532);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A18);
  static const Color textSecondary = Color(0xFF4A4A42);
  static const Color textTertiary = Color(0xFFD9D9D9);
  static const Color error = Color(0xFFE53935);
  static const Color accentSecondary = Color(0xFFFFB53C);
}

class AppTypography {
  const AppTypography._();

  static String get fontFamily => GoogleFonts.inter().fontFamily!;

  static TextStyle get header => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get normal => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get normalBold => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get tinyCaption => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get tinyCaptionDark => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );
}
