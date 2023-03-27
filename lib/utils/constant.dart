import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/assets.dart';
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
final kStyleLargePrinter = TextStyle(fontWeight: FontWeight.bold, fontSize: 34);
final kStyleTitlePrinter = TextStyle(fontWeight: FontWeight.bold, fontSize: 27);
final kStyleDataPrinter = TextStyle(fontSize: 23);

final kStyleHint = TextStyle(fontWeight: FontWeight.normal, fontSize: 13.sp, color: Colors.grey);
final kStyleTextOrange = TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp, color: ColorsApp.primaryColor);


const companyType = CompanyType.falcons;



loadAssets() {
  switch (companyType) {
    case CompanyType.falcons:
      Assets.kAssetsLoginBackground = "assets/images/rectangle60.png";
      Assets.kAssetsDinInBackground = "assets/images/dinin_group.png";
      Assets.kAssetsLoginBack = "assets/images/home_back.png";
      Assets.kAssetsDrawerHeader = "assets/images/rectangle60.png";
      Assets.kAssetsHomeScreen = "assets/images/takeway108.png";
      Assets.kAssetsChoose = "assets/images/choose109.png";
      Assets.kAssetsTakeAway = "assets/images/take_away_.png";
      Assets.kAssetsDineIn = "assets/images/dine_in_.png";
      Assets.kAssetsCategory = "assets/images/Image_1.jpg";
      Assets.kAssetsItem = "assets/images/Image_2.png";
      Assets.kAssetsFavorite = "assets/images/Favorite.png";
      Assets.kAssetsWelcome = "assets/images/welcome.png";
      Assets.kAssetsSplash = "assets/images/logo.png";
      Assets.kAssetsTable = "assets/images/table_ellipse.png";
      Assets.kAssetsGuests = "assets/images/guests.png";
      Assets.kAssetsArrowRight = "assets/images/arrowchevronright.png";
      Assets.kAssetsArrowBottom = "assets/images/drop_dark.png";
      Assets.kAssetsUser = "assets/images/user.png";
      Assets.kAssetsPlaceholder = "assets/images/image_placeholder.png";
      break;
    case CompanyType.umniah:
      Assets.kAssetsLoginBackground = "assets/images/rectangle602.png";
      Assets.kAssetsDinInBackground = "assets/images/dinin_group.png";
      Assets.kAssetsLoginBack = "assets/images/login_back_umnia.png";
      Assets.kAssetsDrawerHeader = "assets/images/logo_arabic.png";
      Assets.kAssetsHomeScreen = "assets/images/takeway108.png";
      Assets.kAssetsChoose = "assets/images/choose109.png";
      Assets.kAssetsTakeAway = "assets/images/take_away_.png";
      Assets.kAssetsDineIn = "assets/images/dine_in_.png";
      Assets.kAssetsCategory = "assets/images/Image_1.jpg";
      Assets.kAssetsItem = "assets/images/Image_2.png";
      Assets.kAssetsFavorite = "assets/images/Favorite.png";
      Assets.kAssetsWelcome = "assets/images/welcome.png";
      Assets.kAssetsSplash = "assets/images/u_logo.png";
      Assets.kAssetsTable = "assets/images/table_ellipse.png";
      Assets.kAssetsGuests = "assets/images/guests.png";
      Assets.kAssetsArrowRight = "assets/images/arrowchevronright.png";
      Assets.kAssetsArrowBottom = "assets/images/drop_dark.png";
      Assets.kAssetsUser = "assets/images/user.png";
      Assets.kAssetsPlaceholder = "assets/images/image_placeholder.png";
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
