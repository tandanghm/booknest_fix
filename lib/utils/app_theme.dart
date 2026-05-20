// lib/utils/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna Utama
  static const Color primary = Color(0xFF1A2744);
  static const Color primaryLight = Color(0xFF2D4080);
  static const Color accent = Color(0xFFE8943A);
  static const Color background = Color(0xFFF6F4EE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EDE6);

  // Warna Status Badge
  static const Color readingBg = Color(0xFFE6F1FB);
  static const Color readingFg = Color(0xFF185FA5);
  static const Color doneBg = Color(0xFFEAF3DE);
  static const Color doneFg = Color(0xFF3B6D11);
  static const Color wishlistBg = Color(0xFFFAEEDA);
  static const Color wishlistFg = Color(0xFF854F0B);

  // Warna Genre Cover
  static const List<Color> coverColors = [
    Color(0xFFE6F1FB),
    Color(0xFFFAEEDA),
    Color(0xFFEAF3DE),
    Color(0xFFFBEAF0),
    Color(0xFFF1EFE8),
    Color(0xFFE1F5EE),
  ];
  static const List<Color> coverTextColors = [
    Color(0xFF185FA5),
    Color(0xFF854F0B),
    Color(0xFF3B6D11),
    Color(0xFF993556),
    Color(0xFF5F5E5A),
    Color(0xFF0F6E56),
  ];

  static Color getCoverColor(int index) =>
      coverColors[index % coverColors.length];
  static Color getCoverTextColor(int index) =>
      coverTextColors[index % coverTextColors.length];

  // Map genre → index warna
  static int getGenreColorIndex(String genre) {
    const genreMap = {
      'Self-Help': 0,
      'Bisnis & Keuangan': 1,
      'Sains & Teknologi': 2,
      'Fiksi': 3,
      'Sejarah': 4,
      'Filsafat': 5,
    };
    return genreMap[genre] ?? 0;
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        background: background,
        surface: surface,
        primary: primary,
      ),
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: primary,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 15,
          color: const Color(0xFF2C2C2A),
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: const Color(0xFF5F5E5A),
        ),
        labelSmall: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: const Color(0xFF888780),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF888780),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD3D1C7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD3D1C7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFA32D2D)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFA32D2D), width: 1.5),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          color: const Color(0xFF5F5E5A),
        ),
        errorStyle: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          color: const Color(0xFFA32D2D),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFD3D1C7), width: 0.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primary,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Konstanta aplikasi
class AppConstants {
  static const String appName = 'BookNest';
  static const List<String> genres = [
    'Self-Help',
    'Fiksi',
    'Sains & Teknologi',
    'Bisnis & Keuangan',
    'Sejarah',
    'Filsafat',
    'Biografi',
    'Psikologi',
    'Seni & Budaya',
    'Lainnya',
  ];

  static const List<String> statuses = [
    'wishlist',
    'reading',
    'done',
  ];

  static const Map<String, String> statusLabels = {
    'wishlist': 'Wishlist',
    'reading': 'Sedang Dibaca',
    'done': 'Selesai',
  };
}
