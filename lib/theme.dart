import 'package:flutter/material.dart';

final appTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Montserrat',
  primaryColor: const Color(0xFFFFB800),
  disabledColor: const Color(0xFF9F7300),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black,
      backgroundColor: const Color(0xFFFFB800),
    ),
  ),
  shadowColor: Colors.black.withOpacity(0.25),
  colorScheme: const ColorScheme(
    background: Color(0xFF343434),
    brightness: Brightness.dark,
    error: Colors.red,
    onBackground: Colors.white,
    onError: Colors.white,
    primary: Color(0xFFFFB800),
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.white,
    secondary: Color(0xFFFFB800),
    surface: Color(0xFF9F7300),
  ),
);
