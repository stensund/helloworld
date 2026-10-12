import 'package:flutter/material.dart';

const brandRed = Color(0xFFE53935);
const surfaceDark = Color(0xFF121212);
const cardDark = Color(0xFF1E1E1E);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: brandRed,
    brightness: Brightness.dark,
    primary: brandRed,
    surface: surfaceDark,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: surfaceDark,
    cardTheme: const CardThemeData(color: cardDark, margin: EdgeInsets.zero),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceDark,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
    ),
  );
}
