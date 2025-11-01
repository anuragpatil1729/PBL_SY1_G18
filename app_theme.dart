// lib/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // --- Common Theme Data ---

  // --- FIX: Use CardThemeData (the data class) instead of CardTheme (the widget) ---
  static final _commonCardTheme = CardThemeData(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  // --- END FIX ---

  static final _commonInputTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
  );

  // --- Light Theme ---
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[100],
    fontFamily: GoogleFonts.lato().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      headlineSmall: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
      titleLarge: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
      bodyLarge: GoogleFonts.lato(),
      bodyMedium: GoogleFonts.lato(),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: _commonCardTheme.copyWith(
      color: Colors.white,
    ), // This line is now valid
    inputDecorationTheme: _commonInputTheme.copyWith(
      fillColor: Colors.white,
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );

  // --- Dark Theme ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue[300],
    scaffoldBackgroundColor: const Color(0xFF121212),
    fontFamily: GoogleFonts.lato().fontFamily,
    textTheme: TextTheme(
      displayLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.montserrat(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.lato(color: Colors.white70),
      bodyMedium: GoogleFonts.lato(color: Colors.white70),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: GoogleFonts.montserrat(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: _commonCardTheme.copyWith(
      color: Colors.grey[850],
    ), // This line is also now valid
    inputDecorationTheme: _commonInputTheme.copyWith(
      fillColor: Colors.grey[800],
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade700, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[300],
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
