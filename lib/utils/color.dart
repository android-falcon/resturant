import 'package:flutter/material.dart';

class ColorsApp {
  static const MaterialColor primaryColor = MaterialColor(
    0xFF89cbee,
    <int, Color>{
      50: Color(0xFF89cbee),
      100: Color(0xFF89cbee),
      200: Color(0xFF89cbee),
      300: Color(0xFF89cbee),
      350: Color(0xFF89cbee), // only for raised button while pressed in light theme
      400: Color(0xFF89cbee),
      500: Color(0xFF89cbee),
      600: Color(0xFF89cbee),
      700: Color(0xFF89cbee),
      800: Color(0xFF89cbee),
      850: Color(0xFF89cbee), // only for background color in dark theme
      900: Color(0xFF89cbee),
    },
  );
  //  static const Color primaryColor = Color.fromRGBO(255, 133, 73, 1.0);
  static const MaterialColor accentColor = MaterialColor(
    0xFFC2DFFF,
    <int, Color>{
      50: Color(0xFFC2DFFF),
      100: Color(0xFFC2DFFF),
      200: Color(0xFFC2DFFF),
      300: Color(0xFFC2DFFF),
      350: Color(0xFFC2DFFF), // only for raised button while pressed in light theme
      400: Color(0xFFC2DFFF),
      500: Color(0xFFC2DFFF),
      600: Color(0xFFC2DFFF),
      700: Color(0xFFC2DFFF),
      800: Color(0xFFC2DFFF),
      850: Color(0xFFC2DFFF), // only for background color in dark theme
      900: Color(0xFFC2DFFF),
    },
  );
  // static const Color accentColor = Color.fromRGBO(98, 208, 61, 1);
  static const Color border = Color(0x7f333639);
  static const Color blue = Color(0xFF4aa5d4);
  static const Color red = Color(0xFFaf0a0a);
  static const Color orange = Color(0xfff19954);
  static const Color green = Color(0xFF32CD32);
  static const Color gray = Colors.grey;
  static const Color grayLight = Color.fromRGBO(236, 236, 236, 1);
  static const Color grayLightTransparent = Color.fromRGBO(224, 224, 224, 0.7);
  static const Color chatReceived = Color(0xFFFFEFEE);
  static const Color backgroundDialog = Color(0xFFE5E4E2);
}