import 'dart:ui';

class ColorConverter{
  static Color  stringToColor(String color){
    int value = 0xFFEF7822;
    value = int.parse(color.replaceAll('#', '0xFF'));
      return Color(value);
  }
}