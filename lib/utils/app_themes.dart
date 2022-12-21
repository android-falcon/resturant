import 'package:flutter/material.dart';
import 'package:restaurant_system/utils/color.dart';

import 'constant.dart';

class AppThemes {
  late Map<AppTheme, ThemeData> appThemeData;

  AppThemes() {
    appThemeData = {
      AppTheme.lightTheme: ThemeData(
        toggleableActiveColor: ColorsApp.primaryColor.shade700,
        //brightness: Brightness.light,
        primarySwatch:UMNIA_FALG==1 ?ColorsApp.accentColor: ColorsApp.primaryColor,
        primaryColor: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor,
        // fontFamily: fontFamily,
        cardColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFDADADA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F9),
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          )
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorsApp.primaryColor).copyWith(
          secondary: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor.shade700,
          brightness: Brightness.light,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            foregroundColor: MaterialStateProperty.resolveWith((state) => Colors.black),
            overlayColor: MaterialStateProperty.resolveWith((state) => Colors.black.withOpacity(0.1)),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor:UMNIA_FALG==1 ?ColorsApp.accentColor: ColorsApp.primaryColor,
          selectionHandleColor: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor.shade700,
        ),
      ),
      AppTheme.darkTheme: ThemeData(
        toggleableActiveColor:UMNIA_FALG==1 ?ColorsApp.accentColor: ColorsApp.primaryColor.shade700,
        // brightness: Brightness.dark,
        primarySwatch:UMNIA_FALG==1 ?ColorsApp.accentColor: ColorsApp.primaryColor,
        primaryColor: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor,
        // fontFamily: fontFamily,
        cardColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFF212121),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor).copyWith(
          secondary: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor.shade700,
          brightness: Brightness.dark,
        ),
        textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
            foregroundColor: MaterialStateProperty.resolveWith((state) => Colors.black),
            overlayColor: MaterialStateProperty.resolveWith((state) => Colors.black.withOpacity(0.1)),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: UMNIA_FALG==1 ?ColorsApp.accentColor:ColorsApp.primaryColor,
          selectionHandleColor:UMNIA_FALG==1 ?ColorsApp.accentColor: ColorsApp.primaryColor.shade700,
        ),
      ),
    };
  }
}

enum AppTheme { lightTheme, darkTheme }
