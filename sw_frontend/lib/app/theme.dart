import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color lightBlue = Color(0xFFE3F2FD);

  // Background and surfaces
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF667085);

  // Status colors
  static const Color success = Color(0xFF16803C);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFD92D20);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    colorScheme:
        ColorScheme.fromSeed(
          seedColor: primaryBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: primaryBlue,
          secondary: darkBlue,
          surface: surface,
          error: error,
        ),

    scaffoldBackgroundColor: background,

    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: const CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primaryBlue, width: 2),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
