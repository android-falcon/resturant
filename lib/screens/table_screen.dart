import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:restaurant_system/models/printer_invoice_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/printer.dart';
import 'package:restaurant_system/screens/order_screen.dart';
import 'package:restaurant_system/utils/assets.dart';
import 'package:restaurant_system/screens/widgets/custom__drop_down.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_drawer.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:screenshot/screenshot.dart';

import '../models/all_data/employee_model.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<HomeMenu> _menu = [];
  Set<int> floors = {};
  int? _selectFloor;
  List<DineInModel> dineInSaved = []; //m// ySharedPreferences.dineIn;
  Timer? _timer;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _menu = <HomeMenu>[
      HomeMenu(
        name: 'Move'.tr,
        icon: Icon(Icons.move_down, color: ColorsApp.primaryColor),
        onTab: () async {
          if (mySharedPreferences.employee.hasMoveTablePermission) {
            await _showMoveDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await Utils.showLoginDialog();
            if (employee != null) {
              if (employee.hasMoveTablePermission) {
                await _showMoveDialog();
                setState(() {});
              } else {
                Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
              }
            }
          }
        },
      ),
      HomeMenu(
        name: 'Merge'.tr,
        icon: Icon(Icons.merge_type_rounded, color: ColorsApp.gray),
        onTab: () async {
          if (mySharedPreferences.employee.hasMergeTablePermission) {
            await _showMargeDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await Utils.showLoginDialog();
            if (employee != null) {
              if (employee.hasMergeTablePermission) {
                await _showMargeDialog();
                setState(() {});
              } else {
                Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
              }
            }
          }
        },
      ),
      HomeMenu(
        name: 'Split'.tr,
        icon: Icon(Icons.call_split_rounded, color: ColorsApp.gray),
        onTab: () async {
          if (mySharedPreferences.employee.hasMergeTablePermission) {
            await _showSelectTableSplitDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await Utils.showLoginDialog();
            if (employee != null) {
              if (employee.hasMergeTablePermission) {
                await _showSelectTableSplitDialog();
                setState(() {});
              } else {
                Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
              }
            }
          }
        },
      ),
      // HomeMenu(
      //   name: 'Reservation'.tr,
      //   onTab: () {},
      // ),
      // HomeMenu(
      //   name: 'Check Out'.tr,
      //   onTab: () async {
      //     var tableId = await _showCheckOutDialog();
      //     if (tableId != null) {
      //       var indexTable = dineInSaved.indexWhere((element) => element.tableId == tableId);
      //       Get.to(() => PayScreen(cart: dineInSaved[indexTable].cart, tableId: tableId));
      //     }
      //   },
      // ),
      HomeMenu(
        name: 'Print'.tr,
        icon: Icon(Icons.print, color: ColorsApp.gray),
        onTab: () async {
          await _showPrintTablesDialog();
          setState(() {});
        },
      ),
      HomeMenu(
        name: 'Cash Drawer'.tr,
        icon: Icon(Icons.cable_sharp, color: ColorsApp.gray),
        onTab: () async {
          var indexPrinter = allDataModel.printers.indexWhere((element) => element.cashNo == mySharedPreferences.cashNo);
          if (indexPrinter != -1) {
            Printer.openCash(allDataModel.printers[indexPrinter].ipAddress, allDataModel.printers[indexPrinter].port);
          }
        },
      ),
      HomeMenu(
        name: 'Change User'.tr,
        icon: Icon(Icons.supervised_user_circle, color: ColorsApp.gray),
        onTab: () async {
          if (mySharedPreferences.employee.hasChangeTableCaptinPermission) {
            await _showChangeUserDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await Utils.showLoginDialog();
            if (employee != null) {
              if (employee.hasChangeTableCaptinPermission) {
                await _showChangeUserDialog();
                setState(() {});
              } else {
                Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
              }
            }
          }
        },
      ),
      HomeMenu(
        icon: Icon(Icons.note, color: ColorsApp.gray),
        name: 'Report Tables'.tr,
        onTab: () async {
          await _showReportTablesDialog();
          setState(() {});
        },
      ),
      HomeMenu(
        name: 'Close'.tr,
        icon: Icon(Icons.exit_to_app, color: ColorsApp.gray),
        onTab: () {
          Get.back();
        },
      ),
    ];
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _initData(true);
    });
  }

  _initData(bool enableTimer) async {
    Utils.showLoadingDialog();
    await _getTables();
    Utils.hideLoadingDialog();

    if (enableTimer) {
      _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) async => await _getTables());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timer!.cancel();
  }

  _getTables() async {
    var tables = await RestApi.getTables();
    floors = tables.map((e) => e.floorNo).toSet();
    _selectFloor ??= floors.first;
    dineInSaved = tables.map((e) {
      CartModel? cart;
      try {
        cart = e.cart.isEmpty ? CartModel.init(orderType: OrderType.dineIn, tableId: e.id) : CartModel.fromJson(jsonDecode(e.cart));
      } catch (ex) {
        cart = CartModel.init(orderType: OrderType.dineIn, tableId: e.id);
      }
      return DineInModel(
        isOpen: e.isOpened == 1,
        isPrinted: e.isPrinted == 1,
        isReservation: false,
        userId: e.userId,
        tableId: e.id,
        tableNo: e.tableNo,
        floorNo: e.floorNo,
        cart: cart,
      );
    }).toList();
    setState(() {});
  }

  Future<void> _showPrintTablesDialog() async {
    int? _selectTableId;
    int? _selectFloor = floors.first;
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
                        Text('Table'.tr),
                        const Divider(),
                        Container(
                          width: double.infinity,
                          height: 35.h,
                          color: Colors.white,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
                                              color: _selectFloor == e ? ColorsApp.primaryColor : null,
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => element.isOpen && element.floorNo == _selectFloor && element.userId == mySharedPreferences.employee.id)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectTableId == e.tableId ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            _selectTableId = e.tableId;
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
                                                Assets.kAssetsTable,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Print'.tr),
                  onPressed: () async {
                    if (_selectTableId == null) {
                      Fluttertoast.showToast(msg: 'Please select a table'.tr);
                    } else {
                      var result = await Utils.showAreYouSureDialog(title: 'Print Order'.tr);
                      if (result) {
                        Utils.showLoadingDialog();
                        var indexTable = dineInSaved.indexWhere((element) => element.tableId == _selectTableId);
                        dineInSaved[indexTable].isPrinted = true;
                        await RestApi.printTable(dineInSaved[indexTable].tableId);
                        Utils.hideLoadingDialog();
                        Get.back();

                        Printer.printInvoicesDialog(
                          cart: dineInSaved[indexTable].cart,
                          showPrintButton: true,
                          kitchenPrinter: false,
                          showInvoiceNo: false,
                        );
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  fixed: true,
                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showReportTablesDialog() async {
    int? _selectFloor = floors.first;
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
                        Text('Table'.tr),
                        const Divider(),
                        Container(
                          width: double.infinity,
                          height: 35.h,
                          color: ColorsApp.orangeLight,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => element.isOpen && element.floorNo == _selectFloor)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black),
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: Column(
                                          children: [
                                            Center(
                                              child: Text(
                                                '${e.tableNo} (${allDataModel.employees.firstWhereOrNull((element) => element.id == e.userId)?.empName ?? ''})',
                                                style: kStyleTextTable,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Image.asset(
                                              Assets.kAssetsTable,
                                              height: 80.h,
                                            )
                                          ],
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
              backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
              child: Text('Close'.tr),
              onPressed: () {
                Get.back();
              },
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showChangeUserDialog() async {
    int? _selectUserId;
    int? _selectTableId;
    int? _selectFloor = floors.first;
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
                        Text('Table'.tr),
                        const Divider(),
                        Container(
                          width: double.infinity,
                          height: 35.h,
                          color: Colors.white,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
                                              color: _selectFloor == e ? ColorsApp.primaryColor : null,
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
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: dineInSaved
                                  .where((element) => element.isOpen && element.floorNo == _selectFloor && element.userId == mySharedPreferences.employee.id)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectTableId == e.tableId ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            _selectTableId = e.tableId;
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
                                                Assets.kAssetsTable,
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
                        Text('Users'.tr),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: StaggeredGrid.count(
                              crossAxisCount: 4,
                              children: allDataModel.employees
                                  .where((element) => element.id != mySharedPreferences.employee.id)
                                  .map((e) => Container(
                                        margin: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectUserId == e.id ? Border.all(color: Colors.black) : null,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                        ),
                                        child: InkWell(
                                          radius: 10,
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          onTap: () {
                                            _selectUserId = e.id;
                                            setState(() {});
                                          },
                                          child: Column(
                                            children: [
                                              Center(
                                                child: Text(
                                                  '${e.empName} (${e.id})',
                                                  style: kStyleTextTable,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Image.asset(
                                                Assets.kAssetsUser,
                                                height: 80.h,
                                              )
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Change User'.tr),
                  onPressed: () async {
                    if (_selectUserId == null) {
                      Fluttertoast.showToast(msg: 'Please select a user'.tr);
                    } else if (_selectTableId == null) {
                      Fluttertoast.showToast(msg: 'Please select a table'.tr);
                    } else {
                      var result = await Utils.showAreYouSureDialog(title: 'Change User'.tr);
                      if (result) {
                        Utils.showLoadingDialog();
                        var resultApi = await RestApi.changeUserTable(_selectTableId!, mySharedPreferences.employee.id, _selectUserId!);
                        if (resultApi) {
                          var indexTable = dineInSaved.indexWhere((element) => element.tableId == _selectTableId);
                          dineInSaved[indexTable].userId = _selectUserId!;
                          await RestApi.saveTableOrder(cart: dineInSaved[indexTable].cart);
                        }
                        Utils.hideLoadingDialog();
                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                  fixed: true,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
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
                          color: Colors.white,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
                                              color: _selectFromFloor == e ? ColorsApp.primaryColor : null,
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
                                  .where((element) => element.isOpen && element.floorNo == _selectFromFloor && element.userId == mySharedPreferences.employee.id)
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
                                                Assets.kAssetsTable,
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
                          color: Colors.white,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
                                              color: _selectToFloor == e ? ColorsApp.primaryColor : null,
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
                                                Assets.kAssetsTable,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Move'.tr),
                  onPressed: () async {
                    if (_selectFromTableId == null || _selectToTableId == null) {
                      Fluttertoast.showToast(msg: 'Please select a table'.tr);
                    } else {
                      var result = await Utils.showAreYouSureDialog(title: 'Move'.tr);
                      if (result) {
                        Utils.showLoadingDialog();
                        var resultApi = await RestApi.moveTable(_selectFromTableId!, _selectToTableId!);
                        if (resultApi) {
                          var indexFrom = dineInSaved.indexWhere((element) => element.tableId == _selectFromTableId);
                          var indexTo = dineInSaved.indexWhere((element) => element.tableId == _selectToTableId);
                          dineInSaved[indexTo].userId = dineInSaved[indexFrom].userId;
                          dineInSaved[indexTo].isOpen = dineInSaved[indexFrom].isOpen;
                          dineInSaved[indexTo].isReservation = dineInSaved[indexFrom].isReservation;
                          dineInSaved[indexTo].cart = dineInSaved[indexFrom].cart;
                          dineInSaved[indexTo].cart.tableId = _selectToTableId!;
                          dineInSaved[indexFrom].isOpen = false;
                          dineInSaved[indexFrom].isReservation = false;
                          dineInSaved[indexFrom].cart = CartModel.init(orderType: OrderType.dineIn);
                          dineInSaved[indexTo].cart = Utils.calculateOrder(cart: dineInSaved[indexTo].cart, orderType: OrderType.dineIn);

                          await RestApi.saveTableOrder(cart: dineInSaved[indexTo].cart);
                        }
                        Utils.hideLoadingDialog();
                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  fixed: true,
                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
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
                          color: Colors.white,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
                                              color: _selectFromFloor == e ? ColorsApp.primaryColor : null,
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
                                  .where((element) => element.isOpen && element.floorNo == _selectFromFloor) //  && element.userId == mySharedPreferences.employee.id
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
                                                Assets.kAssetsTable,
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
                          color: Colors.white,
                          child: Row(
                              children: floors
                                  .map(
                                    (e) => Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: 35.h,
                                              color: _selectToFloor == e ? ColorsApp.primaryColor : null,
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
                                  .where((element) => element.isOpen && element.floorNo == _selectToFloor && element.userId == mySharedPreferences.employee.id)
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
                                                Assets.kAssetsTable,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Marge'.tr),
                  onPressed: () async {
                    if (_selectFromTableId == null || _selectToTableId == null) {
                      Fluttertoast.showToast(msg: 'Please select a table'.tr);
                    } else {
                      var result = await Utils.showAreYouSureDialog(title: 'Marge'.tr);
                      if (result) {
                        var resultApi = await RestApi.mergeTable(_selectFromTableId!, _selectToTableId!);
                        if (resultApi) {
                          var indexFrom = dineInSaved.indexWhere((element) => element.tableId == _selectFromTableId);
                          var indexTo = dineInSaved.indexWhere((element) => element.tableId == _selectToTableId);
                          dineInSaved[indexTo].cart.items.addAll(dineInSaved[indexFrom].cart.items);
                          dineInSaved[indexTo].cart.totalSeats += dineInSaved[indexFrom].cart.totalSeats;
                          dineInSaved[indexTo].cart.seatsFemale += dineInSaved[indexFrom].cart.seatsFemale;
                          dineInSaved[indexTo].cart.seatsMale += dineInSaved[indexFrom].cart.seatsMale;
                          dineInSaved[indexFrom].isOpen = false;
                          dineInSaved[indexFrom].isReservation = false;
                          dineInSaved[indexFrom].cart = CartModel.init(orderType: OrderType.dineIn);
                          dineInSaved[indexTo].cart = Utils.calculateOrder(cart: dineInSaved[indexTo].cart, orderType: OrderType.dineIn);
                          await RestApi.saveTableOrder(cart: dineInSaved[indexTo].cart);
                        }
                        Utils.hideLoadingDialog();
                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  fixed: true,
                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showSelectTableSplitDialog() async {
    int? _selectTableId;
    int? _selectFloor = floors.first;
    await Get.dialog(
      CustomDialog(
        enableScroll: false,
        builder: (context, setState, constraints) => Column(
          children: [
            Text('Split'.tr),
            const Divider(),
            Container(
              width: double.infinity,
              height: 35.h,
              color: Colors.white,
              child: Row(
                  children: floors
                      .map(
                        (e) => Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 35.h,
                                  color: _selectFloor == e ? ColorsApp.primaryColor : null,
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
                child: StaggeredGrid.count(
                  crossAxisCount: 4,
                  children: dineInSaved
                      .where((element) => element.isOpen && element.floorNo == _selectFloor) //  && element.userId == mySharedPreferences.employee.id
                      .map((e) => Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: _selectTableId == e.tableId ? Border.all(color: Colors.black) : null,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                            ),
                            child: InkWell(
                              radius: 10,
                              borderRadius: const BorderRadius.all(Radius.circular(10)),
                              onTap: () {
                                if (e.tableId == _selectTableId) {
                                  _selectTableId = null;
                                } else {
                                  _selectTableId = e.tableId;
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
                                    Assets.kAssetsTable,
                                    height: 80.h,
                                  )
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Next'.tr),
                  onPressed: () async {
                    if (_selectTableId == null) {
                      Fluttertoast.showToast(msg: 'Please select a table'.tr);
                    } else {
                      Get.back();
                      _showSplitDialog(_selectTableId!);
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  fixed: true,
                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _showSplitDialog(int tableId) async {
    _timer!.cancel();
    DineInModel table = dineInSaved.firstWhere((element) => element.tableId == tableId);
    int _indexItemSelect = -1;
    int _indexItemSelectSplit = -1;
    List<CartModel> splits = [];
    CartModel? _selectSplit = null;
    await Get.dialog(
      CustomDialog(
        enableScroll: false,
        builder: (context, setState, constraints) => Column(
          children: [
            Text('Split'.tr),
            const Divider(),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Invoice'.tr),
                        const Divider(),
                        Expanded(
                          child: ListView(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      color: Colors.white,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                'Qty'.tr,
                                                style: kStyleHeaderTable,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                'Pro-Nam'.tr,
                                                style: kStyleHeaderTable,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Price'.tr,
                                                style: kStyleHeaderTable,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                'Total'.tr,
                                                style: kStyleHeaderTable,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Divider(color: Colors.grey, height: 1),
                                    ListView.separated(
                                      itemCount: table.cart.items.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, index) => table.cart.items[index].parentUuid.isNotEmpty ? Container() : const Divider(color: Colors.black, height: 1),
                                      itemBuilder: (context, index) {
                                        if (table.cart.items[index].parentUuid.isNotEmpty) {
                                          return Container();
                                        } else {
                                          var subItem = table.cart.items.where((element) => element.parentUuid == table.cart.items[index].uuid).toList();
                                          return InkWell(
                                            onTap: () {
                                              _indexItemSelect = index;
                                              setState(() {});
                                            },
                                            child: Container(
                                              color: index == _indexItemSelect ? ColorsApp.primaryColor : null,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '${table.cart.items[index].qty}',
                                                            style: kStyleDataTable,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            table.cart.items[index].name,
                                                            style: kStyleDataTable,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            table.cart.items[index].priceChange.toStringAsFixed(3),
                                                            style: kStyleDataTable,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            (table.cart.items[index].priceChange * table.cart.items[index].qty).toStringAsFixed(3),
                                                            style: kStyleDataTable,
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                    child: Column(
                                                      children: [
                                                        ListView.builder(
                                                          itemCount: table.cart.items[index].questions.length,
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemBuilder: (context, indexQuestions) => Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      table.cart.items[index].questions[indexQuestions].question.trim(),
                                                                      style: kStyleDataTableModifiers,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              ListView.builder(
                                                                itemCount: table.cart.items[index].questions[indexQuestions].modifiers.length,
                                                                shrinkWrap: true,
                                                                physics: const NeverScrollableScrollPhysics(),
                                                                itemBuilder: (context, indexModifiers) => Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child: Text(
                                                                            '* ${table.cart.items[index].questions[indexQuestions].modifiers[indexModifiers].modifier}',
                                                                            style: kStyleDataTableModifiers,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        ListView.builder(
                                                          itemCount: table.cart.items[index].modifiers.length,
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemBuilder: (context, indexModifiers) => Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  '${table.cart.items[index].modifiers[indexModifiers].name}\n* ${table.cart.items[index].modifiers[indexModifiers].modifier}',
                                                                  style: kStyleDataTableModifiers,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (subItem.isNotEmpty)
                                                          ListView.builder(
                                                            itemCount: subItem.length,
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemBuilder: (context, indexSubItem) {
                                                              return Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child: Text(
                                                                      subItem[indexSubItem].name,
                                                                      style: kStyleDataTableModifiers,
                                                                      textAlign: TextAlign.center,
                                                                      maxLines: 1,
                                                                      overflow: TextOverflow.ellipsis,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      subItem[indexSubItem].priceChange.toStringAsFixed(3),
                                                                      style: kStyleDataTableModifiers,
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      (subItem[indexSubItem].priceChange * subItem[indexSubItem].qty).toStringAsFixed(3),
                                                                      style: kStyleDataTableModifiers,
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(thickness: 2),
                  Column(
                    children: [
                      SizedBox(height: 50),
                      InkWell(
                        onTap: () {
                          if (_indexItemSelect != -1 && _selectSplit != null) {
                            _selectSplit!.items.add(table.cart.items[_indexItemSelect]);
                            var subItem = table.cart.items.where((element) => element.parentUuid == table.cart.items[_indexItemSelect].uuid).toList();
                            _selectSplit!.items.addAll(subItem);
                            table.cart.items.removeWhere((element) => element.parentUuid == table.cart.items[_indexItemSelect].uuid);
                            table.cart.items.remove(table.cart.items[_indexItemSelect]);
                            _indexItemSelect = -1;
                            setState(() {});
                          }
                        },
                        child: RotationTransition(
                          turns: const AlwaysStoppedAnimation(270 / 360),
                          child: Image.asset(
                            Assets.kAssetsArrowBottom,
                            height: 40,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      InkWell(
                        onTap: () {
                          if (_selectSplit != null && _indexItemSelectSplit != -1) {
                            table.cart.items.add(_selectSplit!.items[_indexItemSelectSplit]);
                            var subItem = _selectSplit!.items.where((element) => element.parentUuid == _selectSplit!.items[_indexItemSelectSplit].uuid).toList();
                            table.cart.items.addAll(subItem);
                            _selectSplit!.items.removeWhere((element) => element.parentUuid == _selectSplit!.items[_indexItemSelectSplit].uuid);
                            _selectSplit!.items.remove(_selectSplit!.items[_indexItemSelectSplit]);
                            _indexItemSelectSplit = -1;
                            setState(() {});
                          }
                        },
                        child: RotationTransition(
                          turns: const AlwaysStoppedAnimation(90 / 360),
                          child: Image.asset(
                            Assets.kAssetsArrowBottom,
                            height: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 2),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            splits.add(CartModel.init(orderType: OrderType.dineIn, tableId: table.tableId, splitIndex: splits.length + 1));
                            setState(() {});
                          },
                          icon: Icon(Icons.add),
                          label: Text('Split Invoice'.tr),
                        ),
                        const Divider(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: StaggeredGrid.count(
                              crossAxisCount: 2,
                              children: splits
                                  .map((e) => Container(
                                        height: 200,
                                        margin: const EdgeInsets.all(2),
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: _selectSplit == e ? Border.all(color: Colors.black) : null,
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            if (e == _selectSplit) {
                                              _selectSplit = null;
                                            } else {
                                              _selectSplit = e;
                                            }
                                            _indexItemSelectSplit = -1;
                                            setState(() {});
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text('${e.splitIndex}'),
                                                  IconButton(
                                                    onPressed: () {
                                                      table.cart.items.addAll(e.items);
                                                      splits.remove(e);
                                                      _indexItemSelectSplit = -1;
                                                      _selectSplit = null;
                                                      for (int i = 0; i < splits.length; i++) {
                                                        splits[i].splitIndex = i + 1;
                                                      }
                                                      setState(() {});
                                                    },
                                                    icon: Icon(Icons.clear),
                                                  ),
                                                ],
                                              ),
                                              Expanded(
                                                child: ListView(
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(),
                                                        borderRadius: BorderRadius.circular(3.r),
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            color: Colors.white,
                                                            child: Padding(
                                                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Qty'.tr,
                                                                      style: kStyleHeaderTable,
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 3,
                                                                    child: Text(
                                                                      'Pro-Nam'.tr,
                                                                      style: kStyleHeaderTable,
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Price'.tr,
                                                                      style: kStyleHeaderTable,
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      'Total'.tr,
                                                                      style: kStyleHeaderTable,
                                                                      textAlign: TextAlign.center,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          const Divider(color: Colors.grey, height: 1),
                                                          ListView.separated(
                                                            itemCount: e.items.length,
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            separatorBuilder: (context, index) => e.items[index].parentUuid.isNotEmpty ? Container() : const Divider(color: Colors.black, height: 1),
                                                            itemBuilder: (context, index) {
                                                              if (e.items[index].parentUuid.isNotEmpty) {
                                                                return Container();
                                                              } else {
                                                                var subItem = e.items.where((element) => element.parentUuid == e.items[index].uuid).toList();
                                                                return InkWell(
                                                                  onTap: _selectSplit != e
                                                                      ? null
                                                                      : () {
                                                                          _selectSplit = e;
                                                                          _indexItemSelectSplit = index;
                                                                          setState(() {});
                                                                        },
                                                                  child: Container(
                                                                    color: (_selectSplit == e && index == _indexItemSelectSplit) ? ColorsApp.primaryColor : null,
                                                                    child: Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                                          child: Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  '${e.items[index].qty}',
                                                                                  style: kStyleDataTable,
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                flex: 3,
                                                                                child: Text(
                                                                                  e.items[index].name,
                                                                                  style: kStyleDataTable,
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  e.items[index].priceChange.toStringAsFixed(3),
                                                                                  style: kStyleDataTable,
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                              Expanded(
                                                                                child: Text(
                                                                                  (e.items[index].priceChange * e.items[index].qty).toStringAsFixed(3),
                                                                                  style: kStyleDataTable,
                                                                                  textAlign: TextAlign.center,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                                          child: Column(
                                                                            children: [
                                                                              ListView.builder(
                                                                                itemCount: e.items[index].questions.length,
                                                                                shrinkWrap: true,
                                                                                physics: const NeverScrollableScrollPhysics(),
                                                                                itemBuilder: (context, indexQuestions) => Column(
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            e.items[index].questions[indexQuestions].question.trim(),
                                                                                            style: kStyleDataTableModifiers,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    ListView.builder(
                                                                                      itemCount: e.items[index].questions[indexQuestions].modifiers.length,
                                                                                      shrinkWrap: true,
                                                                                      physics: const NeverScrollableScrollPhysics(),
                                                                                      itemBuilder: (context, indexModifiers) => Column(
                                                                                        children: [
                                                                                          Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: Text(
                                                                                                  '* ${e.items[index].questions[indexQuestions].modifiers[indexModifiers].modifier}',
                                                                                                  style: kStyleDataTableModifiers,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              ListView.builder(
                                                                                itemCount: e.items[index].modifiers.length,
                                                                                shrinkWrap: true,
                                                                                physics: const NeverScrollableScrollPhysics(),
                                                                                itemBuilder: (context, indexModifiers) => Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Text(
                                                                                        '${e.items[index].modifiers[indexModifiers].name}\n* ${e.items[index].modifiers[indexModifiers].modifier}',
                                                                                        style: kStyleDataTableModifiers,
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              if (subItem.isNotEmpty)
                                                                                ListView.builder(
                                                                                  itemCount: subItem.length,
                                                                                  shrinkWrap: true,
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  itemBuilder: (context, indexSubItem) {
                                                                                    return Row(
                                                                                      children: [
                                                                                        Expanded(
                                                                                          flex: 4,
                                                                                          child: Text(
                                                                                            subItem[indexSubItem].name,
                                                                                            style: kStyleDataTableModifiers,
                                                                                            textAlign: TextAlign.center,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            subItem[indexSubItem].priceChange.toStringAsFixed(3),
                                                                                            style: kStyleDataTableModifiers,
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            (subItem[indexSubItem].priceChange * subItem[indexSubItem].qty).toStringAsFixed(3),
                                                                                            style: kStyleDataTableModifiers,
                                                                                            textAlign: TextAlign.center,
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    );
                                                                                  },
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Split'.tr),
                  onPressed: () async {
                    Get.back();
                    _initData(true);
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  fixed: true,
                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                  child: Text('Close'.tr),
                  onPressed: () {
                    for (var element in splits) {
                      table.cart.items.addAll(element.items);
                    }
                    Get.back();
                    _initData(true);
                  },
                ),
              ],
            ),
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

  Future<Map?> _showNumberSeatsDialog() async {
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
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.kAssetsPlaceholder),
                  ),
                ),
                height: 200.h,

                // width: 500.w,
              ),
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
      return null;
    }
    return {
      'number_seats': _numberSeats,
      'male': int.tryParse(_controllerMale.text) ?? 0,
      'female': int.tryParse(_controllerFemale.text) ?? 0,
      'children': int.tryParse(_controllerChildren.text) ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ClipPath(
        // clipper: OvalRightBorderClipper(),
        child: SizedBox(
          width: 120.w,
          child: CustomDrawer(
            menu: _menu,
          ),
        ),
      ),
      body: CustomSingleChildScrollView(
        child: Stack(
          children: [
            Container(
              color: companyType == CompanyType.umniah ? Colors.white : ColorsApp.backgroundDialog,
              width: 1.sw,
              height: 1.sh,
            ),
            Image.asset(
              Assets.kAssetsDinInBackground,
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
                        color: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.backgroundDialog,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: companyType == CompanyType.umniah ? ColorsApp.primaryColor : ColorsApp.black,
                              ),
                            ),
                            Text(
                              'Dine In'.tr,
                              style: TextStyle(color: companyType == CompanyType.umniah ? ColorsApp.primaryColor : ColorsApp.black),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                onPressed: () {
                                  _scaffoldKey.currentState?.openEndDrawer();
                                },
                                icon: Icon(Icons.menu, color: companyType == CompanyType.umniah ? ColorsApp.primaryColor : ColorsApp.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 35.h,
                        color: ColorsApp.orangeLight,
                        child: Row(
                            children: floors
                                .map(
                                  (e) => Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 35.h,
                                            color: _selectFloor == e ? ColorsApp.primaryColor : null,
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
                                          if (e.isOpen) {
                                            if (mySharedPreferences.employee.id == e.userId) {
                                              await RestApi.openTable(e.tableId);
                                              Get.to(() => OrderScreen(type: OrderType.dineIn, dineIn: e))!.then((value) {
                                                RestApi.unlockTable(e.tableId);
                                                _initData(false);
                                              });
                                            } else {
                                              Fluttertoast.showToast(msg: 'A table opened by another user'.tr);
                                            }
                                          } else {
                                            var totalSeats = await _showNumberSeatsDialog();
                                            if (totalSeats != null) {
                                              Utils.showLoadingDialog();
                                              bool isOpened = await RestApi.openTable(e.tableId);
                                              Utils.hideLoadingDialog();
                                              if (isOpened) {
                                                mySharedPreferences.orderNo++;
                                                e.isOpen = true;
                                                e.cart.orderNo = mySharedPreferences.orderNo;
                                                e.cart.totalSeats = totalSeats['number_seats'];
                                                e.cart.seatsMale = totalSeats['male'];
                                                e.cart.seatsFemale = totalSeats['female'];
                                                Get.to(() => OrderScreen(type: OrderType.dineIn, dineIn: e))!.then((value) {
                                                  RestApi.unlockTable(e.tableId);
                                                  _initData(false);
                                                });
                                              }
                                            }
                                          }
                                        },
                                        child: Column(
                                          children: [
                                            // Center(
                                            //   child: Text(
                                            //     '${e.tableNo}',
                                            //     style: kStyleTextTable,
                                            //   ),
                                            // ),
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 120.h,
                                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(width: 2, color: ColorsApp.orangeLight),
                                                    borderRadius: BorderRadius.circular(5),
                                                    boxShadow: [
                                                      if (e.isOpen) //  && mySharedPreferences.employee.id == e.userId
                                                        BoxShadow(
                                                          color: e.isPrinted ? Colors.yellow.withOpacity(0.5) : Colors.green.withOpacity(0.5),
                                                          spreadRadius: 1,
                                                          blurRadius: 20,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                Opacity(
                                                  opacity: 0.9,
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        margin: EdgeInsets.all(10),
                                                        height: 120.h,
                                                        decoration: BoxDecoration(
                                                          color: ColorsApp.backgroundDialog,
                                                          border: Border.all(width: 2, color: ColorsApp.backgroundDialog),
                                                          borderRadius: BorderRadius.circular(5.r),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                  image: AssetImage(Assets.kAssetsTable),
                                                                ),
                                                              ),
                                                              height: 70.h,
                                                              width: 100.w,
                                                            ),
                                                            Center(
                                                              child: Text(
                                                                '${e.tableNo}',
                                                                style: kStyleTextTable,
                                                              ),
                                                            ),
                                                            Container(
                                                              width: 50.w,
                                                              decoration: BoxDecoration(
                                                                color: ColorsApp.backgroundDialog,
                                                                border: Border.all(width: 1, color: ColorsApp.primaryColor),
                                                                borderRadius: BorderRadius.circular(5.r),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  'View ',
                                                                  style: kStyleTextTable.copyWith(color: ColorsApp.redLight),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
