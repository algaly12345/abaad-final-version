import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'IBMPlexSansArabic',
  primaryColor: const Color(0xFF1A3C5E),
  secondaryHeaderColor: const Color(0xFF2E6DA4),
  disabledColor: const Color(0xFFBCC0C7),
  brightness: Brightness.light,
  hintColor: const Color(0xFF9DA3AF),
  cardColor: Colors.white,
  scaffoldBackgroundColor: const Color(0xFFF6F8FD),
  dividerColor: const Color(0xFFE8ECF0),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: Colors.white),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF1A3C5E),
    secondary: Color(0xFFE07B2A),
    surface: Color(0xFFF6F8FD),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    error: Color(0xFFD32F2F),
  ).copyWith(
    surface: const Color(0xFFF6F8FD),
    error: const Color(0xFFD32F2F),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'IBMPlexSansArabic',
      color: Color(0xFF1A3C5E),
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Color(0xFF1A3C5E)),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE8ECF0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF1A3C5E), width: 1.5),
    ),
    hintStyle: const TextStyle(color: Color(0xFF9DA3AF), fontSize: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1A3C5E),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      textStyle: const TextStyle(
        fontFamily: 'IBMPlexSansArabic',
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Color(0xFF1A3C5E),
    unselectedItemColor: Color(0xFF9DA3AF),
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);
