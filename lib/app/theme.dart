import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary palette (Deep Charcoal / Obsidian)
  static const navy = Color(0xFF0C1017);
  static const navyLight = Color(0xFF141A24);
  static const navyCard = Color(0xFF111722);
  static const navyBorder = Color(0xFF1E2837);

  // Modern Accent Colors
  static const teal = Color(0xFF00D2B4); // Electric Mint / Teal
  static const tealDark = Color(0xFF00A892);
  static const blue = Color(0xFF3B82F6); // Electric Cobalt
  static const blueLight = Color(0xFF60A5FA);

  // Status colors
  static const safe = Color(0xFF10B981); // Emerald
  static const safeLight = Color(0xFF34D399);
  static const warning = Color(0xFFF59E0B); // Amber
  static const warningLight = Color(0xFFFBBF24);
  static const high = Color(0xFFF97316); // Orange
  static const highLight = Color(0xFFFB923C);
  static const critical = Color(0xFFEF4444); // Crimson
  static const criticalLight = Color(0xFFF87171);

  // AI / Purple
  static const aiPurple = Color(0xFF8B5CF6); // Modern Violet
  static const aiPurpleLight = Color(0xFFA78BFA);

  // Text Hierarchy
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);

  // Background & Surfaces
  static const background = Color(0xFF080A0F);
  static const surface = Color(0xFF0E131C);
  static const surfaceElevated = Color(0xFF151C28);
  static const divider = Color(0xFF1A2230);

  // Sidebar
  static const sidebar = Color(0xFF0A0D14);
  static const sidebarActive = Color(0xFF151D2A);
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.blue,
        surface: AppColors.surface,
        onPrimary: Color(0xFF080A0F),
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.critical,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.navyCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: AppColors.navyBorder, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.navyLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navyBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.navyBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: const Color(0xFF080A0F),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.2),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.navyCard,
        labelStyle: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        side: BorderSide(color: AppColors.navyBorder),
      ),
    );
  }
}

