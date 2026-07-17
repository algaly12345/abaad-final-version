import 'package:flutter/material.dart';

// نسخة داكنة مكتملة تُطابق بنية light_theme.dart (نفس مفاتيح ThemeData)
// بدل النسخة القديمة المختصرة جدًا (كانت تفتقد scaffoldBackgroundColor/
// appBarTheme/cardTheme/... فتظهر شاشات كثيرة بيضاء رغم تفعيل الوضع الداكن).
// اللون الأساسي هنا نسخة أفتح من primaryColor في light_theme.dart (نفس عائلة
// الأزرق) لضمان تباين كافٍ فوق خلفية داكنة، وليس هوية بصرية جديدة.
ThemeData dark = ThemeData(
  fontFamily: 'IBMPlexSansArabic',
  primaryColor: const Color(0xFF4C86C1),
  secondaryHeaderColor: const Color(0xFFE0904D),
  disabledColor: const Color(0xFF4A4E5C),
  brightness: Brightness.dark,
  hintColor: const Color(0xFF8B92A5),
  cardColor: const Color(0xFF1C1F2B),
  scaffoldBackgroundColor: const Color(0xFF12141C),
  dividerColor: const Color(0xFF2A2D3A),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(backgroundColor: const Color(0xFF1C1F2B)),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF4C86C1),
    secondary: Color(0xFFE0904D),
    surface: Color(0xFF1C1F2B),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    error: Color(0xFFEF5350),
  ).copyWith(
    surface: const Color(0xFF1C1F2B),
    error: const Color(0xFFEF5350),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1C1F2B),
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'IBMPlexSansArabic',
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    color: const Color(0xFF1C1F2B),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1C1F2B),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2A2D3A)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF2A2D3A)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4C86C1), width: 1.5),
    ),
    hintStyle: const TextStyle(color: Color(0xFF8B92A5), fontSize: 14),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4C86C1),
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
    backgroundColor: Color(0xFF1C1F2B),
    selectedItemColor: Color(0xFF4C86C1),
    unselectedItemColor: Color(0xFF8B92A5),
    elevation: 8,
    type: BottomNavigationBarType.fixed,
  ),
);
