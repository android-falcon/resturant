import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/report_screen.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/enums/enum_device_type.dart';
import 'package:restaurant_system/utils/enums/enum_report_type.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports'.tr),
      ),
      body: SingleChildScrollView(
        child: StaggeredGrid.count(
          crossAxisCount: deviceType == DeviceType.phone ? 2 : 2,
          children: [
            Padding(
              padding: EdgeInsets.all(2.w),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const ReportScreen(type: ReportType.cashReport));
                },
                child: Card(
                  color: ColorsApp.gray_light,
                  shadowColor: ColorsApp.gray_light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  elevation: 0,
                  child: Container(
                    height: 100.h,
                    width: 100.w,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 25.w,
                        ),
                        Center(
                          child: Text(
                            'Cash Report'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const ReportScreen(type: ReportType.cashInOutReport));
                },
                child: Card(
                  color: ColorsApp.gray_light,
                  shadowColor: ColorsApp.gray_light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  elevation: 0,
                  child: Container(
                    height: 100.h,
                    width: 100.w,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.money,
                          size: 25.w,
                        ),
                        Center(
                          child: Text(
                            'Cash In / Out Report'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.w),
              child: GestureDetector(
                onTap: () {
                  Get.to(() => const ReportScreen(type: ReportType.soldQtyReport));
                },
                child: Card(
                  color: ColorsApp.gray_light,
                  shadowColor: ColorsApp.gray_light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.r),
                  ),
                  elevation: 0,
                  child: Container(
                    height: 100.h,
                    width: 100.w,
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(
                          Icons.money,
                          size: 25.w,
                        ),
                        Center(
                          child: Text(
                            'Sold Qty Report'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
