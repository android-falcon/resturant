import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/login_screen.dart';
import 'package:restaurant_system/socket/kitchen_socket_server.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/utils.dart';

class KitchenScreen extends StatefulWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    KitchenSocketServer.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (mySharedPreferences.language == 'ar') {
                mySharedPreferences.language = 'en';
              } else {
                mySharedPreferences.language = 'ar';
              }
              Get.updateLocale(Locale(mySharedPreferences.language));
            },
            icon: const Icon(Icons.language),
          ),
          IconButton(
            onPressed: () {
              Get.offAll(() => LoginScreen());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: SizedBox(
          height: 690.h,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 10,
            itemBuilder: (context, index) => Container(
              width: 120.w,
              padding: EdgeInsets.zero,
              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${'Order No'.tr} : 5'),
                              Text('${'Table No'.tr} : 5'),
                              Text('${'Section No'.tr} : 5'),
                            ],
                          ),
                        ),
                        // Expanded(
                        //   flex: ,
                        //   child: Container(),
                        // ),
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/take_away.png',
                                width: 50.h,
                              ),
                              Text('Take Away'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 0,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                    // color: ColorsApp.primaryColor,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Item Name'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Qty'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Note'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20,
                      // shrinkWrap: true,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Item Name',
                                style: kStyleDataTable,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                '4',
                                style: kStyleDataTable,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Note'.tr,
                                style: kStyleDataTable,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(
                    color: Colors.black,
                    height: 0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                    child: Text('No Update'),
                  ),
                  InkWell(
                    onTap: () async {
                      var result = await showAreYouSureDialog(title: 'Finish Order'.tr);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorsApp.red,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4.r), bottomRight: Radius.circular(4.r)),
                      ),
                      height: 35,
                      width: double.infinity,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
