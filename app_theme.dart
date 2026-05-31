// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Base palette ──────────────────────────────────────────────
  static const background    = Color(0xFF080A0F);
  static const surface       = Color(0xFF0E1117);
  static const surfaceElevated = Color(0xFF141820);
  static const surfaceCard   = Color(0xFF1A1F2E);
  static const border        = Color(0xFF252B3A);
  static const borderLight   = Color(0xFF2E3548);

  // ── Gold accent spectrum ──────────────────────────────────────
  static const gold          = Color(0xFFD4A843);
  static const goldLight     = Color(0xFFE8C060);
  static const goldDim       = Color(0xFFA07830);
  static const goldGlow      = Color(0x33D4A843);
  static const goldSubtle    = Color(0x1AD4A843);

  // ── Semantic colors ───────────────────────────────────────────
  static const success       = Color(0xFF2ECC8A);
  static const successDim    = Color(0xFF1A7A52);
  static const warning       = Color(0xFFE8A020);
  static const danger        = Color(0xFFE85050);
  static const dangerDim     = Color(0xFF7A2525);
  static const info          = Color(0xFF5090E8);

  // ── Text ──────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFF0EDE8);
  static const textSecondary = Color(0xFF8A8FA0);
  static const textMuted     = Color(0xFF4A5060);
  static const textGold      = Color(0xFFD4A843);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary:    AppColors.gold,
        secondary:  AppColors.goldLight,
        surface:    AppColors.surface,
        background: AppColors.background,
        error:      AppColors.danger,
        onPrimary:  AppColors.background,
        onSecondary: AppColors.background,
        onSurface:  AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary, fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -1),
        displayMedium: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w600),
        displaySmall: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.dmSans(
          color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineMedium: GoogleFonts.dmSans(
          color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        headlineSmall: GoogleFonts.dmSans(
          color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.dmSans(
          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.dmSans(
          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.dmSans(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        bodyLarge: GoogleFonts.dmSans(
          color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.dmSans(
          color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.dmSans(
          color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w400),
        labelLarge: GoogleFonts.dmSans(
          color: AppColors.background, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.8),
        labelMedium: GoogleFonts.dmSans(
          color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
        labelSmall: GoogleFonts.dmSans(
          color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 1.0),
      ).apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.cormorantGaramond(
          color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(color: AppColors.textMuted, fontSize: 14),
        labelStyle: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gold,
          side: const BorderSide(color: AppColors.gold),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceElevated,
        selectedColor: AppColors.goldSubtle,
        labelStyle: GoogleFonts.dmSans(color: AppColors.textSecondary, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.background,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
