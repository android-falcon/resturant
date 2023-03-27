import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/login_screen.dart';
import 'package:restaurant_system/utils/assets.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ScreenUtil().orientation;
    delayScreen();
  }

  delayScreen() {
    Future.delayed(const Duration(seconds: 2)).then((value) {
      Get.offAll(() => LoginScreen());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          Assets.kAssetsSplash,
          width: 0.4.sw,
        ),
      ),
    );
  }
}
