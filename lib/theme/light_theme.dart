import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: Color(0xFF194B7C),
  secondaryHeaderColor: Color(0xFF58B3F5),
  disabledColor: Color(0xFFBABFC4),
  brightness: Brightness.light,
  hintColor: Color(0xFF9F9F9F),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(backgroundColor: Color(
      0xFFFFFFFF))), colorScheme: ColorScheme.light(primary: Color(0xFFEF7822), secondary: Color(0xFFEF7822)).copyWith(surface: Color(0xFFF3F3F3)).copyWith(error: Color(0xFF034A77)),
);