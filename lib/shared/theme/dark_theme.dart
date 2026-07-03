import 'package:flutter/material.dart';

ThemeData dark = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: Color(0xB3930404),
  secondaryHeaderColor: Color(0xFF009f67),
  disabledColor: Color(0xffa2a7ad),
  brightness: Brightness.dark,
  hintColor: Color(0xFFbebebe),
  cardColor: Colors.black,
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(backgroundColor: Color(
      0xff034a77))), colorScheme: ColorScheme.dark(primary: Color(0xFFffbd5c), secondary: Color(0xFFffbd5c)).copyWith(surface: Color(0xFF343636)).copyWith(error: Color(0xFFdd3135)),
);
