import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF181B21),
  fontFamily: 'Montserrat',
  primaryColor: const Color(0xFFFFB800),
  disabledColor: const Color(0xFF9F7300),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFFFFB800),
      minimumSize: const Size(44, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  shadowColor: Colors.black.withValues(alpha: 0.25),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    error: Colors.red,
    onError: Colors.white,
    primary: Color(0xFFFFB800),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    secondary: Color(0xFFFFB800),
    surface: Color(0xFF252A33),
  ),
);
