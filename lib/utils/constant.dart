import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';

final kStyleTextDefault = TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp);
final kStyleTextTitle = TextStyle(fontWeight: FontWeight.normal, fontSize: 20.sp);
final kStyleHeaderTable = TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: ColorsApp.red);
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
final kStyleTextOrange = TextStyle(fontWeight: FontWeight.normal, fontSize: 14.sp, color: ColorsApp.orange_2);

const placeholderImage = 'assets/images/logo.png';

const companyType = CompanyType.falcons;

String kAssetsLoginBackground = "";
String kAssetsLoginBack = "";
String kAssetsDrawerHeader = "";
String kAssetsHomeScreen = "";
String kAssetsChoose = "";
String kAssetsTakeAway = "";
String kAssetsDineIn = "";

loadAssets() {
  switch (companyType) {
    case CompanyType.falcons:
      kAssetsLoginBackground = "assets/images/rectangle60.png";
      kAssetsLoginBack = "assets/images/home_back.png";
      kAssetsDrawerHeader = "assets/images/rectangle60.png";
      kAssetsHomeScreen = "assets/images/takeway108.png";
      kAssetsChoose = "assets/images/choose109.png";
      kAssetsTakeAway = "assets/images/take_away_.png";
      kAssetsDineIn = "assets/images/dine_in_.png";
      break;
    case CompanyType.umniah:
      kAssetsLoginBackground = "assets/images/rectangle602.png";
      kAssetsLoginBack = "assets/images/login_back_umnia.png";
      kAssetsDrawerHeader = "assets/images/logo_arabic.png";
      kAssetsHomeScreen = "assets/images/takeway108.png";
      kAssetsChoose = "assets/images/choose109.png";
      kAssetsTakeAway = "assets/images/take_away_.png";
      kAssetsDineIn = "assets/images/dine_in_.png";
      break;
  }
}
