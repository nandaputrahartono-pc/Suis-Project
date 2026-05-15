import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors for Dark Mode
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color neonGreen = Color(0xFFC6F432); // From the Preezy inspiration
  static const Color electricPurple = Color(0xFF7C4DFF); // Vibrant purple accent
  static const Color darkText = Color(0xFFE0E0E0);
  
  // Colors for Light Mode
  static const Color lightBackground = Color(0xFFF0F0F0);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color deepPurple = Color(0xFF4527A0);
  static const Color lightText = Color(0xFF212121);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: deepPurple,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: deepPurple,
        secondary: darkGreen,
        surface: lightCard,
      ),
      textTheme: GoogleFonts.vt323TextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.vt323(fontSize: 32, fontWeight: FontWeight.bold, color: lightText),
        bodyLarge: GoogleFonts.vt323(fontSize: 20, color: lightText),
        bodyMedium: GoogleFonts.vt323(fontSize: 18, color: lightText),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: deepPurple),
        titleTextStyle: GoogleFonts.vt323(fontSize: 24, color: lightText, fontWeight: FontWeight.bold),
      ),
      cardColor: lightCard,
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: electricPurple,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: electricPurple,
        secondary: neonGreen,
        surface: darkCard,
      ),
      textTheme: GoogleFonts.vt323TextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.vt323(fontSize: 32, fontWeight: FontWeight.bold, color: darkText),
        bodyLarge: GoogleFonts.vt323(fontSize: 20, color: darkText),
        bodyMedium: GoogleFonts.vt323(fontSize: 18, color: darkText),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkCard,
        elevation: 0,
        iconTheme: const IconThemeData(color: neonGreen),
        titleTextStyle: GoogleFonts.vt323(fontSize: 24, color: darkText, fontWeight: FontWeight.bold),
      ),
      cardColor: darkCard,
      useMaterial3: true,
    );
  }
}
