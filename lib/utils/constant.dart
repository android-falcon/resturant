import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';

final kStyleTextDefault = TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp);
final kStyleTextTitle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20.sp);
final kStyleHeaderTable = TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: companyType == CompanyType.umniah ? ColorsApp.black : ColorsApp.red);
final kStyleDataTable = TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.black);
final kStyleDataTableModifiers = TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.redAccent);
final kStyleTextButton = TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.white);
final kStyleTextTable = TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black);
final kStyleButtonPayment = TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp);
final kStyleForceQuestion = TextStyle(fontWeight: FontWeight.bold, fontSize: 17.sp);
final kStyleLargePrinter = TextStyle(fontWeight: FontWeight.bold, fontSize: 34.sp);
final kStyleTitlePrinter = TextStyle(fontWeight: FontWeight.bold, fontSize: 27.sp);
final kStyleDataPrinter = TextStyle(fontSize: 23.sp);

final kStyleHint = TextStyle(fontWeight: FontWeight.normal, fontSize: 13.sp, color: Colors.grey);
final kStyleTextOrange = TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp, color: ColorsApp.primaryColor);


const companyType = CompanyType.falcons;

String kAssetsLoginBackground = "";
String kAssetsDinInBackground = "";
String kAssetsLoginBack = "";
String kAssetsDrawerHeader = "";
String kAssetsHomeScreen = "";
String kAssetsChoose = "";
String kAssetsTakeAway = "";
String kAssetsDineIn = "";
String kAssetsCategory = "";
String kAssetsItem = "";
String kAssetsFavorite = "";
String kAssetsWelcome = "";
String kAssetsSplash = "";
String kAssetsTable = "";
String kAssetsGuests = "";
String kAssetsArrowRight = "";
String kAssetsArrowBottom = "";
String kAssetsUser = "";
String kAssetsPlaceholder = "";

loadAssets() {
  switch (companyType) {
    case CompanyType.falcons:
      kAssetsLoginBackground = "assets/images/rectangle60.png";
      kAssetsDinInBackground = "assets/images/dinin_group.png";
      kAssetsLoginBack = "assets/images/home_back.png";
      kAssetsDrawerHeader = "assets/images/rectangle60.png";
      kAssetsHomeScreen = "assets/images/takeway108.png";
      kAssetsChoose = "assets/images/choose109.png";
      kAssetsTakeAway = "assets/images/take_away_.png";
      kAssetsDineIn = "assets/images/dine_in_.png";
      kAssetsCategory = "assets/images/Image_1.jpg";
      kAssetsItem = "assets/images/Image_2.png";
      kAssetsFavorite = "assets/images/Favorite.png";
      kAssetsWelcome = "assets/images/welcome.png";
      kAssetsSplash = "assets/images/logo.png";
      kAssetsTable = "assets/images/table_ellipse.png";
      kAssetsGuests = "assets/images/guests.png";
      kAssetsArrowRight = "assets/images/arrowchevronright.png";
      kAssetsArrowBottom = "assets/images/drop_dark.png";
      kAssetsUser = "assets/images/user.png";
      kAssetsPlaceholder = "assets/images/image_placeholder.png";
      break;
    case CompanyType.umniah:
      kAssetsLoginBackground = "assets/images/rectangle602.png";
      kAssetsDinInBackground = "assets/images/dinin_group.png";
      kAssetsLoginBack = "assets/images/login_back_umnia.png";
      kAssetsDrawerHeader = "assets/images/logo_arabic.png";
      kAssetsHomeScreen = "assets/images/takeway108.png";
      kAssetsChoose = "assets/images/choose109.png";
      kAssetsTakeAway = "assets/images/take_away_.png";
      kAssetsDineIn = "assets/images/dine_in_.png";
      kAssetsCategory = "assets/images/Image_1.jpg";
      kAssetsItem = "assets/images/Image_2.png";
      kAssetsFavorite = "assets/images/Favorite.png";
      kAssetsWelcome = "assets/images/welcome.png";
      kAssetsSplash = "assets/images/u_logo.png";
      kAssetsTable = "assets/images/table_ellipse.png";
      kAssetsGuests = "assets/images/guests.png";
      kAssetsArrowRight = "assets/images/arrowchevronright.png";
      kAssetsArrowBottom = "assets/images/drop_dark.png";
      kAssetsUser = "assets/images/user.png";
      kAssetsPlaceholder = "assets/images/image_placeholder.png";
      break;
  }
}

loadColor() {
  switch (companyType) {
    case CompanyType.falcons:
      ColorsApp.primaryColor = const MaterialColor(
        0xFFFF9A3F,
        <int, Color>{
          50: Color(0xFFFF9A3F),
          100: Color(0xFFFF9A3F),
          200: Color(0xFFFF9A3F),
          300: Color(0xFFFF9A3F),
          350: Color(0xFFFF9A3F),
          400: Color(0xFFFF9A3F),
          500: Color(0xFFFF9A3F),
          600: Color(0xFFFF9A3F),
          700: Color(0xFFFF9A3F),
          800: Color(0xFFFF9A3F),
          850: Color(0xFFFF9A3F),
          900: Color(0xFFFF9A3F),
        },
      );
      ColorsApp.accentColor = const MaterialColor(
        0xFFFF9A3F,
        <int, Color>{
          50: Color(0xFFFF9A3F),
          100: Color(0xFFFF9A3F),
          200: Color(0xFFFF9A3F),
          300: Color(0xFFFF9A3F),
          350: Color(0xFFFF9A3F),
          400: Color(0xFFFF9A3F),
          500: Color(0xFFFF9A3F),
          600: Color(0xFFFF9A3F),
          700: Color(0xFFFF9A3F),
          800: Color(0xFFFF9A3F),
          850: Color(0xFFFF9A3F),
          900: Color(0xFFFF9A3F),
        },
      );
      break;
    case CompanyType.umniah:
      ColorsApp.primaryColor = const MaterialColor(
        //
        0xFFDCE324,
        <int, Color>{
          50: Color(0xFFDCE324),
          100: Color(0xFFDCE324),
          200: Color(0xFFDCE324),
          300: Color(0xFFDCE324),
          350: Color(0xFFDCE324), // only for raised button while pressed in light theme
          400: Color(0xFFDCE324),
          500: Color(0xFFDCE324),
          600: Color(0xFFDCE324),
          700: Color(0xFFDCE324),
          800: Color(0xFFDCE324),
          850: Color(0xFFDCE324), // only for background color in dark theme
          900: Color(0xFFDCE324),
        },
      );
      ColorsApp.accentColor = const MaterialColor(
        //
        0xFFDCE324,
        <int, Color>{
          50: Color(0xFFDCE324),
          100: Color(0xFFDCE324),
          200: Color(0xFFDCE324),
          300: Color(0xFFDCE324),
          350: Color(0xFFDCE324), // only for raised button while pressed in light theme
          400: Color(0xFFDCE324),
          500: Color(0xFFDCE324),
          600: Color(0xFFDCE324),
          700: Color(0xFFDCE324),
          800: Color(0xFFDCE324),
          850: Color(0xFFDCE324), // only for background color in dark theme
          900: Color(0xFFDCE324),
        },
      );
      break;
  }
}
