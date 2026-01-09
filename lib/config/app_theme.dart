import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF28C28);
  static const Color scaffoldColor = Color(0xFFFFF3E3);
  static const Color textColorDark = Color(0xFF4A321F);
  static const Color textColorLight = Color(0xFF5C4633);
  static const Color borderColor = Color(0xFF8B5E3B);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: scaffoldColor,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textColorDark),
      bodyMedium: TextStyle(color: textColorLight),
      titleLarge: TextStyle(color: textColorDark),
      titleMedium: TextStyle(color: textColorLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: borderColor, width: 2),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
    ),
    cardTheme: const CardThemeData(
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 1),
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
  );
}
