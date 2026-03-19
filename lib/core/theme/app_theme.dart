import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceVariant = Color(0xFF1E293B);
  static const Color primary = Color(0xFFB900D8); // Bright Magenta matching logo
  static const Color primaryLight = Color(0xFFD755F8);
  static const Color accent = Color(0xFFFFB300); // Amber complimentary
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color subtle = Color(0xFF64748B);
  static const Color error = Color(0xFFFF5370);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFB900D8), Color(0xFF8A00A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0A0E1A), Color(0xFF1B1F3B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Theme ─────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        onPrimary: onSurface,
        surface: surface,
        onSurface: onSurface,
        error: error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant, 
        hintStyle: GoogleFonts.outfit(color: subtle, fontSize: 14),
        labelStyle: GoogleFonts.outfit(color: subtle, fontSize: 14),
        prefixIconColor: subtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerColor: Colors.transparent,
    );
  }
}
