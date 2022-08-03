import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/global_variable.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<HomeMenu> _menu = [];
  Set<int> floors = {};
  int _selectFloor = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _menu = <HomeMenu>[
      HomeMenu(
        name: 'Move'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Merge'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Reservation'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Close'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Cash Drawer'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Check Out'.tr,
        onTab: () {},
      ),
    ];
    floors = allDataModel.tables.map((e) => e.floorNo).toSet();
    _selectFloor = floors.first;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/floor.png',
              width: 1.sw,
              height: 1.sh,
              fit: BoxFit.cover,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50.h,
                        color: ColorsApp.grayLight,
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: const Icon(Icons.arrow_back),
                            ),
                            Text('Dine In'.tr),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 35.h,
                        color: Colors.grey,
                        child: Row(
                            children: floors
                                .map(
                                  (e) => Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35.h,
                                            color: _selectFloor == e ? ColorsApp.accentColor : null,
                                            child: InkWell(
                                              onTap: () {
                                                _selectFloor = e;
                                                setState(() {});
                                              },
                                              child: Center(
                                                child: Text(
                                                  '$e ${'Floor'.tr}',
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: kStyleTextDefault,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (floors.last != e) const VerticalDivider(color: Colors.white, width: 1, thickness: 2),
                                      ],
                                    ),
                                  ),
                                )
                                .toList()),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.w),
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: allDataModel.tables
                                  .where((element) => element.floorNo == _selectFloor)
                                  .map((e) => Column(
                                        children: [
                                          Center(
                                            child: Text(
                                              '${e.tableNo}',
                                              style: kStyleTextTable,
                                            ),
                                          ),
                                          Image.asset(
                                            'assets/images/round_table_4.png',
                                            height: 80.h,
                                          ),
                                        ],
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1.sh,
                  width: 80.w,
                  constraints: BoxConstraints(maxHeight: Get.height, maxWidth: Get.width),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    border: Border.all(width: 2, color: ColorsApp.blue),
                    gradient: const LinearGradient(
                      colors: [
                        ColorsApp.primaryColor,
                        ColorsApp.accentColor,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: ListView.separated(
                    itemCount: _menu.length,
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Divider(
                      height: 1.h,
                      thickness: 2,
                    ),
                    itemBuilder: (context, index) => InkWell(
                      onTap: _menu[index].onTab,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        width: double.infinity,
                        child: Text(
                          _menu[index].name,
                          style: kStyleTextTitle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
