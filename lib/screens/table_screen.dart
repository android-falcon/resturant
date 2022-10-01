import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/order_screen.dart';
import 'package:restaurant_system/screens/pay_screen.dart';
import 'package:restaurant_system/screens/widgets/custom__drop_down.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  List<HomeMenu> _menu = [];
  Set<int> floors = {};
  int _selectFloor = 0;
  List<DineInModel> dineInSaved = mySharedPreferences.dineIn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _menu = <HomeMenu>[
      HomeMenu(
        name: 'Move'.tr,
        onTab: () async {
          await _showMoveDialog();
          setState(() {});
        },
      ),
      HomeMenu(
        name: 'Merge'.tr,
        onTab: () async {
          await _showMargeDialog();
          setState(() {});
        },
      ),
      // HomeMenu(
      //   name: 'Reservation'.tr,
      //   onTab: () {},
      // ),
      HomeMenu(
        name: 'Check Out'.tr,
        onTab: () async {
          var tableId = await _showCheckOutDialog();
          if (tableId != null) {
            var indexTable = dineInSaved.indexWhere((element) => element.tableId == tableId);
            Get.to(() => PayScreen(cart: dineInSaved[indexTable].cart, tableId: tableId));
          }
        },
      ),
      HomeMenu(
        name: 'Cash Drawer'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Close'.tr,
        onTab: () {
          Get.back();
        },
      ),
    ];
    floors = allDataModel.tables.map((e) => e.floorNo).toSet();
    _selectFloor = floors.first;
  }

  Future<void> _showMoveDialog() async {
    int? _selectFromTableId;
    int? _selectFromFloor = floors.first;
    int? _selectToTableId;
    int? _selectToFloor = floors.first;
    await Get.dialog(
      CustomDialog(
        enableScroll: false,
        builder: (context, setState, constraints) => Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('From'.tr),
                        const Divider(),
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
                                              color: _selectFromFloor == e ? ColorsApp.accentColor : null,
                                              child: InkWell(
                                                onTap: () {
                                                  _selectFromFloor = e;
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => element.isOpen && element.floorNo == _selectFromFloor)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectFromTableId == e.tableId ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            _selectFromTableId = e.tableId;
                                            setState(() {});
                                          },
                                          child: Column(
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
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 2),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('To'.tr),
                        const Divider(),
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
                                              color: _selectToFloor == e ? ColorsApp.accentColor : null,
                                              child: InkWell(
                                                onTap: () {
                                                  _selectToFloor = e;
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => !element.isOpen && element.floorNo == _selectToFloor)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectToTableId == e.tableId ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            _selectToTableId = e.tableId;
                                            setState(() {});
                                          },
                                          child: Column(
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
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomButton(
              fixed: true,
              child: Text('Move'.tr),
              onPressed: () async {
                if (_selectFromTableId == null || _selectToTableId == null) {
                  Fluttertoast.showToast(msg: 'Please select a table'.tr);
                } else {
                  var result = await showAreYouSureDialog(title: 'Move'.tr);
                  if (result) {
                    var indexFrom = dineInSaved.indexWhere((element) => element.tableId == _selectFromTableId);
                    var indexTo = dineInSaved.indexWhere((element) => element.tableId == _selectToTableId);
                    dineInSaved[indexTo].isOpen = dineInSaved[indexFrom].isOpen;
                    dineInSaved[indexTo].isReservation = dineInSaved[indexFrom].isReservation;
                    dineInSaved[indexTo].cart = dineInSaved[indexFrom].cart;
                    dineInSaved[indexTo].numberSeats = dineInSaved[indexFrom].numberSeats;
                    dineInSaved[indexFrom].isOpen = false;
                    dineInSaved[indexFrom].isReservation = false;
                    dineInSaved[indexFrom].numberSeats = 0;
                    dineInSaved[indexFrom].cart = CartModel.init(orderType: OrderType.dineIn);
                    mySharedPreferences.dineIn = dineInSaved;
                    Get.back();
                  }
                }
              },
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showMargeDialog() async {
    int? _selectFromTableId;
    int? _selectFromFloor = floors.first;
    int? _selectToTableId;
    int? _selectToFloor = floors.first;
    await Get.dialog(
      CustomDialog(
        enableScroll: false,
        builder: (context, setState, constraints) => Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('From'.tr),
                        const Divider(),
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
                                              color: _selectFromFloor == e ? ColorsApp.accentColor : null,
                                              child: InkWell(
                                                onTap: () {
                                                  _selectFromFloor = e;
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => element.isOpen && element.floorNo == _selectFromFloor)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectFromTableId == e.tableId ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            if (e.tableId == _selectFromTableId) {
                                              _selectFromTableId = null;
                                            } else if (e.tableId != _selectToTableId) {
                                              _selectFromTableId = e.tableId;
                                            }
                                            setState(() {});
                                          },
                                          child: Column(
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
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 2),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('To'.tr),
                        const Divider(),
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
                                              color: _selectToFloor == e ? ColorsApp.accentColor : null,
                                              child: InkWell(
                                                onTap: () {
                                                  _selectToFloor = e;
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => element.isOpen && element.floorNo == _selectToFloor)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectToTableId == e.tableId ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            if (e.tableId == _selectToTableId) {
                                              _selectToTableId = null;
                                            } else if (e.tableId != _selectFromTableId) {
                                              _selectToTableId = e.tableId;
                                            }
                                            setState(() {});
                                          },
                                          child: Column(
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
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            CustomButton(
              fixed: true,
              child: Text('Marge'.tr),
              onPressed: () async {
                if (_selectFromTableId == null || _selectToTableId == null) {
                  Fluttertoast.showToast(msg: 'Please select a table'.tr);
                } else {
                  var result = await showAreYouSureDialog(title: 'Marge'.tr);
                  if (result) {
                    var indexFrom = dineInSaved.indexWhere((element) => element.tableId == _selectFromTableId);
                    var indexTo = dineInSaved.indexWhere((element) => element.tableId == _selectToTableId);
                    dineInSaved[indexTo].cart.items.addAll(dineInSaved[indexFrom].cart.items);
                    dineInSaved[indexTo].numberSeats += dineInSaved[indexFrom].numberSeats;
                    dineInSaved[indexFrom].isOpen = false;
                    dineInSaved[indexFrom].isReservation = false;
                    dineInSaved[indexFrom].numberSeats = 0;
                    dineInSaved[indexFrom].cart = CartModel.init(orderType: OrderType.dineIn);
                    mySharedPreferences.dineIn = dineInSaved;
                    Get.back();
                  }
                }
              },
            )
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<int?> _showCheckOutDialog() async {
    int? _selectedTableId;
    int? _tableId;
    await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            CustomDropDown(
              margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 50.w),
              label: 'Table No'.tr,
              hint: 'Table No'.tr,
              textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 15),
              color: Colors.white60,
              // borderColor: ColorsApp.primaryColor,
              isExpanded: true,
              onChanged: (value) {
                _selectedTableId = value as int;
                setState(() {});
              },
              items: dineInSaved
                  .where((element) => element.isOpen)
                  .map(
                    (entry) => DropdownMenuItem(
                      value: entry.tableId,
                      child: Text(
                        '${entry.tableNo}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              selectItem: _selectedTableId,
            ),
            SizedBox(height: 50.h),
            CustomButton(
              margin: EdgeInsets.symmetric(horizontal: 50.w),
              child: Text('Done'.tr),
              onPressed: () {
                _tableId = _selectedTableId;
                Get.back();
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return _tableId;
  }

  Future<int> _showNumberSeatsDialog() async {
    TextEditingController _controllerMale = TextEditingController(text: '1');
    TextEditingController _controllerFemale = TextEditingController();
    TextEditingController _controllerChildren = TextEditingController();
    int _numberSeats = 1;
    bool? result = await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 10.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${'The number of seats'.tr} :   '),
                  Text(
                    '$_numberSeats',
                    style: kStyleTextTable,
                  ),
                ],
              ),
              SizedBox(height: 50.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _controllerMale,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      keyboardType: const TextInputType.numberWithOptions(),
                      maxLines: 1,
                      inputFormatters: [
                        EnglishDigitsTextInputFormatter(decimal: false),
                      ],
                      label: Text('Male'.tr),
                      onChanged: (value) {
                        int male = 0;
                        int female = 0;
                        int children = 0;
                        if (_controllerMale.text.isNotEmpty) {
                          male = int.parse(_controllerMale.text);
                        }
                        if (_controllerFemale.text.isNotEmpty) {
                          female = int.parse(_controllerFemale.text);
                        }
                        if (_controllerChildren.text.isNotEmpty) {
                          children = int.parse(_controllerChildren.text);
                        }
                        _numberSeats = male + female + children;
                        setState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: _controllerFemale,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      keyboardType: const TextInputType.numberWithOptions(),
                      maxLines: 1,
                      inputFormatters: [
                        EnglishDigitsTextInputFormatter(decimal: false),
                      ],
                      label: Text('Female'.tr),
                      onChanged: (value) {
                        int male = 0;
                        int female = 0;
                        int children = 0;
                        if (_controllerMale.text.isNotEmpty) {
                          male = int.parse(_controllerMale.text);
                        }
                        if (_controllerFemale.text.isNotEmpty) {
                          female = int.parse(_controllerFemale.text);
                        }
                        if (_controllerChildren.text.isNotEmpty) {
                          children = int.parse(_controllerChildren.text);
                        }
                        _numberSeats = male + female + children;
                        setState(() {});
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomTextField(
                      controller: _controllerChildren,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      keyboardType: const TextInputType.numberWithOptions(),
                      maxLines: 1,
                      inputFormatters: [
                        EnglishDigitsTextInputFormatter(decimal: false),
                      ],
                      label: Text('Children'.tr),
                      onChanged: (value) {
                        int male = 0;
                        int female = 0;
                        int children = 0;
                        if (_controllerMale.text.isNotEmpty) {
                          male = int.parse(_controllerMale.text);
                        }
                        if (_controllerFemale.text.isNotEmpty) {
                          female = int.parse(_controllerFemale.text);
                        }
                        if (_controllerChildren.text.isNotEmpty) {
                          children = int.parse(_controllerChildren.text);
                        }
                        _numberSeats = male + female + children;
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50.h),
              CustomButton(
                child: Text('Done'.tr),
                onPressed: () {
                  Get.back(result: true);
                },
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    if (result == null || !result) {
      return 0;
    }
    return _numberSeats;
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
                              children: dineInSaved
                                  .where((element) => element.floorNo == _selectFloor)
                                  .map((e) => InkWell(
                                        onTap: () async {
                                          var numberSeats = e.isOpen ? e.numberSeats : await _showNumberSeatsDialog();
                                          if (numberSeats != 0) {
                                            Get.to(() => OrderScreen(type: OrderType.dineIn, tableId: e.tableId, numberSeats: numberSeats))!.then((value) {
                                              dineInSaved = mySharedPreferences.dineIn;
                                              setState(() {});
                                            });
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                '${e.tableNo}',
                                                style: kStyleTextTable,
                                              ),
                                            ),
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 80.h,
                                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                                  decoration: BoxDecoration(
                                                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(150), topRight: Radius.circular(150), bottomLeft: Radius.circular(150), bottomRight: Radius.circular(150)),
                                                    boxShadow: [
                                                      if (e.isOpen)
                                                        BoxShadow(
                                                          color: Colors.green.withOpacity(0.5),
                                                          spreadRadius: 1,
                                                          blurRadius: 20,
                                                        ),
                                                    ],
                                                    image: const DecorationImage(
                                                      image: AssetImage('assets/images/round_table_4.png'),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
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
