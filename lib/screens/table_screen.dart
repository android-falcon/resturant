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
import 'package:screenshot/screenshot.dart';

import '../models/all_data/employee_model.dart';

class TableScreen extends StatefulWidget {
  const TableScreen({Key? key}) : super(key: key);

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
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
        onTab: () async {
          if (mySharedPreferences.employee.hasMoveTablePermission) {
            await _showMoveDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await showLoginDialog();
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
        onTab: () async {
          if (mySharedPreferences.employee.hasMergeTablePermission) {
            await _showMargeDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await showLoginDialog();
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
        onTab: () async {
          await _showPrintTablesDialog();
          setState(() {});
        },
      ),
      HomeMenu(
        name: 'Change User'.tr,
        onTab: () async {
          if (mySharedPreferences.employee.hasChangeTableCaptinPermission) {
            await _showChangeUserDialog();
            setState(() {});
          } else {
            EmployeeModel? employee = await showLoginDialog();
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
        name: 'Report Tables'.tr,
        onTab: () async {
          await _showReportTablesDialog();
          setState(() {});
        },
      ),
      HomeMenu(
        name: 'Close'.tr,
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
    showLoadingDialog();
    await _getTables();
    hideLoadingDialog();
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
                                                'assets/images/table.png',
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
                      var result = await showAreYouSureDialog(title: 'Print Order'.tr);
                      if (result) {
                        showLoadingDialog();
                        var indexTable = dineInSaved.indexWhere((element) => element.tableId == _selectTableId);
                        dineInSaved[indexTable].isPrinted = true;
                        await RestApi.printTable(dineInSaved[indexTable].tableId);
                        hideLoadingDialog();
                        Get.back();

                        _showPrintDialog(dineInSaved[indexTable].cart);
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
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

  Future<void> _showPrintDialog(CartModel cart) async {
    ScreenshotController _screenshotControllerCash = ScreenshotController();
    List<PrinterInvoiceModel> invoices = [];

    for (var printer in allDataModel.printers) {
      if (printer.cashNo == mySharedPreferences.cashNo) {
        invoices.add(PrinterInvoiceModel(ipAddress: printer.ipAddress, port: printer.port, screenshotController: ScreenshotController(), items: []));
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      var screenshotCash = await _screenshotControllerCash.capture(delay: const Duration(milliseconds: 10));
      await Future.forEach(invoices, (PrinterInvoiceModel element) async {
        if (element.items.isEmpty) {
          element.invoice = screenshotCash;
        } else {
          var screenshotKitchen = await element.screenshotController.capture(delay: const Duration(milliseconds: 10));
          element.invoice = screenshotKitchen;
        }
      });
      invoices.removeWhere((element) => element.invoice == null);
      Printer.invoices(invoices: invoices);
    });
    if (invoices.isNotEmpty) {
      await Get.dialog(
        CustomDialog(
          width: 150.w,
          builder: (context, setState, constraints) => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton(
                    fixed: true,
                    child: Text('Print'.tr),
                    onPressed: () {
                      Printer.invoices(invoices: invoices);
                    },
                  ),
                  SizedBox(width: 10.w),
                  CustomButton(
                    fixed: true,
                    child: Text('Close'.tr),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ],
              ),
              const Divider(thickness: 2),
              Screenshot(
                controller: _screenshotControllerCash,
                child: SizedBox(
                  width: 215.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              cart.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                              style: kStyleLargePrinter,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Order No'.tr,
                              style: kStyleLargePrinter,
                            ),
                            Text(
                              '${cart.orderNo}',
                              style: kStyleLargePrinter,
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.black, thickness: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Text(
                                //   '${'Invoice No'.tr} : ${mySharedPreferences.inVocNo - 1}',
                                //   style: kStyleDataPrinter,
                                // ),
                                Text(
                                  '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                  style: kStyleDataPrinter,
                                ),
                                Text(
                                  '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                  style: kStyleDataPrinter,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (cart.orderType == OrderType.dineIn)
                                  Text(
                                    '${'Table No'.tr} : ${allDataModel.tables.firstWhereOrNull((element) => element.id == cart.tableId)?.tableNo ?? ''}',
                                    style: kStyleDataPrinter,
                                    maxLines: 1,
                                  ),
                                Text(
                                  '${'User'.tr} : ${mySharedPreferences.employee.empName}',
                                  style: kStyleDataPrinter,
                                  maxLines: 1,
                                ),
                                Text(
                                  '${'Phone'.tr} : ${allDataModel.companyConfig[0].phoneNo}',
                                  style: kStyleDataPrinter,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black, thickness: 2),
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    'Pro-Nam'.tr,
                                    style: kStyleDataPrinter,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Qty'.tr,
                                    style: kStyleDataPrinter,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Total'.tr,
                                    style: kStyleDataPrinter,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.black, height: 1),
                          ListView.separated(
                            itemCount: cart.items.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
                            itemBuilder: (context, index) {
                              if (cart.items[index].parentUuid.isNotEmpty) {
                                return Container();
                              } else {
                                var subItem = cart.items.where((element) => element.parentUuid == cart.items[index].uuid).toList();
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              cart.items[index].name,
                                              style: kStyleDataPrinter,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${cart.items[index].qty}',
                                              style: kStyleDataPrinter,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              cart.items[index].total.toStringAsFixed(3),
                                              style: kStyleDataPrinter,
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
                                            itemCount: cart.items[index].questions.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, indexQuestions) => Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '- ${cart.items[index].questions[indexQuestions].question.trim()}',
                                                        style: kStyleDataPrinter,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ListView.builder(
                                                  itemCount: cart.items[index].questions[indexQuestions].modifiers.length,
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, indexModifiers) => Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '  • ${cart.items[index].questions[indexQuestions].modifiers[indexModifiers]}',
                                                              style: kStyleDataPrinter,
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
                                            itemCount: cart.items[index].modifiers.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, indexModifiers) => Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '• ${cart.items[index].modifiers[indexModifiers].name} * ${cart.items[index].modifiers[indexModifiers].modifier}',
                                                    style: kStyleDataPrinter,
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
                                                      flex: 3,
                                                      child: Text(
                                                        subItem[indexSubItem].name,
                                                        style: kStyleDataPrinter,
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        subItem[indexSubItem].priceChange.toStringAsFixed(3),
                                                        style: kStyleDataPrinter,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        subItem[indexSubItem].total.toStringAsFixed(3),
                                                        style: kStyleDataPrinter,
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
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(color: Colors.black, thickness: 2),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.total.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Discount'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.totalDiscount.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Line Discount'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.totalLineDiscount.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Delivery Charge'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.deliveryCharge.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Service'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.service.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Tax'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.tax.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Amount Due'.tr,
                                    style: kStyleTitlePrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  cart.amountDue.toStringAsFixed(3),
                                  style: kStyleTitlePrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black, thickness: 2),
                            if (cart.cash != 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Cash'.tr,
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    cart.cash.toStringAsFixed(3),
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            if (cart.credit != 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Credit'.tr,
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    cart.credit.toStringAsFixed(3),
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            SizedBox(height: 15.h),
                            Image.asset(
                              'assets/images/welcome.png',
                              height: 80.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );
    }
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
                                              'assets/images/table.png',
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
                                                'assets/images/table.png',
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
                                                'assets/images/user.png',
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
                      var result = await showAreYouSureDialog(title: 'Change User'.tr);
                      if (result) {
                        showLoadingDialog();
                        var resultApi = await RestApi.changeUserTable(_selectTableId!, mySharedPreferences.employee.id, _selectUserId!);
                        if (resultApi) {
                          var indexTable = dineInSaved.indexWhere((element) => element.tableId == _selectTableId);
                          dineInSaved[indexTable].userId = _selectUserId!;
                          await RestApi.saveTableOrder(cart: dineInSaved[indexTable].cart);
                        }
                        hideLoadingDialog();
                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
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
                                                'assets/images/table.png',
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
                                                'assets/images/table.png',
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
                      var result = await showAreYouSureDialog(title: 'Move'.tr);
                      if (result) {
                        showLoadingDialog();
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
                          dineInSaved[indexTo].cart = calculateOrder(cart: dineInSaved[indexTo].cart, orderType: OrderType.dineIn);

                          await RestApi.saveTableOrder(cart: dineInSaved[indexTo].cart);
                        }
                        hideLoadingDialog();
                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
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
                                                'assets/images/table.png',
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
                                                'assets/images/table.png',
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
                      var result = await showAreYouSureDialog(title: 'Marge'.tr);
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
                          dineInSaved[indexTo].cart = calculateOrder(cart: dineInSaved[indexTo].cart, orderType: OrderType.dineIn);
                          await RestApi.saveTableOrder(cart: dineInSaved[indexTo].cart);
                        }
                        hideLoadingDialog();
                        Get.back();
                      }
                    }
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
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
                                          if (e.isOpen) {
                                            if (mySharedPreferences.employee.id == e.userId) {
                                              Get.to(() => OrderScreen(type: OrderType.dineIn, dineIn: e))!.then((value) {
                                                _initData(false);
                                              });
                                            } else {
                                              Fluttertoast.showToast(msg: 'A table opened by another user'.tr);
                                            }
                                          } else {
                                            var totalSeats = await _showNumberSeatsDialog();
                                            if (totalSeats != null) {
                                              showLoadingDialog();
                                              bool isOpened = await RestApi.openTable(e.tableId);
                                              hideLoadingDialog();
                                              if (isOpened) {
                                                mySharedPreferences.orderNo++;
                                                e.isOpen = true;
                                                e.cart.orderNo = mySharedPreferences.orderNo;
                                                e.cart.totalSeats = totalSeats['number_seats'];
                                                e.cart.seatsMale = totalSeats['male'];
                                                e.cart.seatsFemale = totalSeats['female'];
                                                Get.to(() => OrderScreen(type: OrderType.dineIn, dineIn: e))!.then((value) {
                                                  _initData(false);
                                                });
                                              }
                                            }
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
                                                      if (e.isOpen && mySharedPreferences.employee.id == e.userId)
                                                        BoxShadow(
                                                          color: e.isPrinted ? Colors.yellow.withOpacity(0.5) : Colors.green.withOpacity(0.5),
                                                          spreadRadius: 1,
                                                          blurRadius: 20,
                                                        ),
                                                    ],
                                                    image: const DecorationImage(
                                                      image: AssetImage('assets/images/table.png'),
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
