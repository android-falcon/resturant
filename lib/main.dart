import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/database/network_table.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/splash_screen.dart';
import 'package:restaurant_system/utils/app_themes.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_device_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_http_overrides.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/translations.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:wakelock/wakelock.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await mySharedPreferences.init();
  HttpOverrides.global = MyHttpOverrides();
  runApp(RestaurantSystem());
}

class RestaurantSystem extends StatefulWidget {
  const RestaurantSystem({Key? key}) : super(key: key);

  @override
  State<RestaurantSystem> createState() => _RestaurantSystemState();
}

class _RestaurantSystemState extends State<RestaurantSystem> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadAssets();
    Utils.packageInfo().then((value) {
      packageInfo = value;
    });
    Wakelock.enable();
    // log('Token : $token');
    // mySharedPreferences.deviceToken = token;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mySharedPreferences.language == "") {
      if (Get.deviceLocale == null) {
        mySharedPreferences.language = 'en';
      } else {
        String language = Get.deviceLocale!.languageCode;
        if (language != 'en' || language != 'ar') {
          mySharedPreferences.language = 'en';
        } else {
          mySharedPreferences.language = language;
        }
      }
    }
    Timer.periodic(const Duration(seconds: 30), (Timer t) async {
      var networkModel = await NetworkTable.queryRows(status: 1);
      log('NetworkModel : ${networkModel.length}');
      for (var element in networkModel) {
        var difference = DateTime.now().difference(DateTime.parse(element.createdAt));
        if (difference.inSeconds > 70) {
          RestApi.uploadNetworkTable(element);
        }
      }
    });
    getDeviceType();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        translations: Translation(),
        locale: Locale(mySharedPreferences.language),
        fallbackLocale: const Locale('en'),
        theme: AppThemes().appThemeData[AppTheme.lightTheme],
        home: SplashScreen(),
      ),
    );
  }
}
