import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Design Tokens
  static const Color backgroundDark = Color(0xFF0F172A); // Deep Navy
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color primaryIndigo = Color(0xFF6366F1); // Vibrant Indigo
  static const Color secondaryCyan = Color(0xFF22D3EE);
  static const Color accentRose = Color(0xFFF43F5E);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Light Theme (Premium Light Slate)
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      primary: primaryIndigo,
      secondary: secondaryCyan,
      surface: Colors.white,
      background: Color(0xFFF1F5F9),
      error: accentRose,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF1F5F9),
    textTheme: GoogleFonts.outfitTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
      titleTextStyle: TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.white,
    ),
  );

  // Dark Theme (Ultra Premium Deep Navy)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryIndigo,
      primary: primaryIndigo,
      secondary: secondaryCyan,
      surface: surfaceDark,
      background: backgroundDark,
      error: accentRose,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: const TextStyle(color: textPrimary),
      bodyMedium: const TextStyle(color: textSecondary),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: surfaceDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark.withAlpha(150),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryIndigo, width: 2),
      ),
    ),
  );
}
