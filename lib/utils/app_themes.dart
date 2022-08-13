import 'package:flutter/material.dart';
import 'package:restaurant_system/utils/color.dart';

class AppThemes {
  late Map<AppTheme, ThemeData> appThemeData;

  AppThemes() {
    appThemeData = {
      AppTheme.lightTheme: ThemeData(
        toggleableActiveColor: ColorsApp.primaryColor.shade700,
        //brightness: Brightness.light,
        primarySwatch: ColorsApp.primaryColor,
        primaryColor: ColorsApp.primaryColor,
        // fontFamily: fontFamily,
        cardColor: Colors.white,
        scaffoldBackgroundColor: const Color(0xFFF9F9F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F9),
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.black,
          )
        ),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorsApp.primaryColor).copyWith(
          secondary: ColorsApp.primaryColor.shade700,
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
          cursorColor: ColorsApp.primaryColor,
          selectionHandleColor: ColorsApp.primaryColor.shade700,
        ),
      ),
      AppTheme.darkTheme: ThemeData(
        toggleableActiveColor: ColorsApp.primaryColor.shade700,
        // brightness: Brightness.dark,
        primarySwatch: ColorsApp.primaryColor,
        primaryColor: ColorsApp.primaryColor,
        // fontFamily: fontFamily,
        cardColor: Colors.black,
        scaffoldBackgroundColor: const Color(0xFF212121),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: ColorsApp.primaryColor).copyWith(
          secondary: ColorsApp.primaryColor.shade700,
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
          cursorColor: ColorsApp.primaryColor,
          selectionHandleColor: ColorsApp.primaryColor.shade700,
        ),
      ),
    };
  }
}

enum AppTheme { lightTheme, darkTheme }
