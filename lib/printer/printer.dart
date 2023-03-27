import 'dart:developer';
import 'dart:typed_data';
// import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart' as esc_bluetooth;
import 'package:restaurant_system/utils/assets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/printer_invoice_model.dart';
import 'package:restaurant_system/models/printer_image_model.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:screenshot/screenshot.dart';

class Printer {
  static Future<void> printInvoicesDialog(
      {required CartModel cart,
      bool kitchenPrinter = true,
      bool cashPrinter = true,
      bool reprint = false,
      bool showPrintButton = true,
      bool showOrderNo = true,
      bool showInvoiceNo = true,
      String invNo = ''}) async {
    ScreenshotController _screenshotControllerCash = ScreenshotController();
    List<PrinterInvoiceModel> invoices = [];

    for (var printer in allDataModel.printers) {
      if (cashPrinter) {
        if (printer.cashNo == mySharedPreferences.cashNo) {
          invoices.add(PrinterInvoiceModel(
              ipAddress: printer.ipAddress, port: printer.port, openCashDrawer: true, screenshotController: ScreenshotController(), items: []));
        }
      }
      if (kitchenPrinter) {
        if (cart.orderType == OrderType.takeAway) {
          var itemsPrinter = allDataModel.itemsPrintersModel.where((element) => element.kitchenPrinter.id == printer.id).toList();
          List<CartItemModel> cartItems = cart.items.where((element) => itemsPrinter.any((elementPrinter) => element.id == elementPrinter.itemId)).toList();
          if (cartItems.isNotEmpty) {
            invoices.add(PrinterInvoiceModel(
                ipAddress: printer.ipAddress, port: printer.port, openCashDrawer: false, screenshotController: ScreenshotController(), items: cartItems));
          }
        } else if (cart.orderType == OrderType.dineIn) {
          var itemsPrinter = allDataModel.itemsPrintersModel.where((element) => element.kitchenPrinter.id == printer.id).toList();
          List<CartItemModel> cartItems =
              cart.items.where((element) => !element.dineInSavedOrder && itemsPrinter.any((elementPrinter) => element.id == elementPrinter.itemId)).toList();
          if (cartItems.isNotEmpty) {
            invoices.add(PrinterInvoiceModel(
                ipAddress: printer.ipAddress, port: printer.port, openCashDrawer: false, screenshotController: ScreenshotController(), items: cartItems));
          }
        }
      }
    }

    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      Uint8List? screenshotCash;
      if (cashPrinter) {
        screenshotCash = await _screenshotControllerCash.capture(delay: const Duration(milliseconds: 10));
      }
      await Future.forEach(invoices, (PrinterInvoiceModel element) async {
        if (cashPrinter && element.items.isEmpty) {
          element.invoice = screenshotCash;
        } else {
          var screenshotKitchen = await element.screenshotController.capture(delay: const Duration(milliseconds: 10));
          element.invoice = screenshotKitchen;
        }
      });
      invoices.removeWhere((element) => element.invoice == null);
      Printer.invoices(invoices: invoices);
    });

    await Get.dialog(
      CustomDialog(
        width: mySharedPreferences.printerWidth.toDouble(),
        builder: (context, setState, constraints) => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showPrintButton)
                  CustomButton(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    fixed: true,
                    child: Text('Print'.tr),
                    onPressed: () {
                      Printer.invoices(invoices: invoices);
                    },
                  ),
                // SizedBox(width: 10.w),
                CustomButton(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  fixed: true,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(thickness: 2),
            if (cashPrinter)
              Screenshot(
                controller: _screenshotControllerCash,
                child: SizedBox(
                  width: mySharedPreferences.printerWidth.toDouble(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (Assets.kAssetsCompanyLogo.isNotEmpty)
                        Center(
                          child: Image.memory(
                            Uint8List.fromList(Assets.kAssetsCompanyLogo),
                            height: 120,
                          ),
                        ),
                      if (Assets.kAssetsCompanyLogo.isNotEmpty) const SizedBox(height: 25),
                      Center(
                        child: Column(
                          children: [
                            if (reprint)
                              Text(
                                'Reprint'.tr,
                                style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                              ),
                            Text(
                              cart.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                              style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (showOrderNo)
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Order No'.tr,
                                style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                              ),
                              Text(
                                '${cart.orderNo}',
                                style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
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
                                if (showInvoiceNo)
                                  Text(
                                    '${'Invoice No'.tr} : $invNo',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                Text(
                                  '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                                Text(
                                  '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    maxLines: 1,
                                  ),
                                Text(
                                  '${'User'.tr} : ${mySharedPreferences.employee.empName}',
                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  maxLines: 1,
                                ),
                                Text(
                                  '${'Phone'.tr} : ${allDataModel.companyConfig[0].phoneNo}',
                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Qty'.tr,
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Total'.tr,
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${cart.items[index].qty}',
                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              cart.items[index].total.toStringAsFixed(3),
                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                // Row(
                                                //   children: [
                                                //     Expanded(
                                                //       child: Text(
                                                //         '- ${widget.cart.items[index].questions[indexQuestions].question.trim()}',
                                                //         style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                //       ),
                                                //     ),
                                                //   ],
                                                // ),
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
                                                              '  • ${cart.items[index].questions[indexQuestions].modifiers[indexModifiers].modifier}',
                                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '${subItem[indexSubItem].qty}',
                                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        subItem[indexSubItem].total.toStringAsFixed(3),
                                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.total.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Discount'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.totalDiscount.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Line Discount'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.totalLineDiscount.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Delivery Charge'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.deliveryCharge.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Service'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.service.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Tax'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.tax.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Amount Due'.tr,
                                    style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                  ),
                                ),
                                Text(
                                  cart.amountDue.toStringAsFixed(3),
                                  style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
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
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    ),
                                  ),
                                  Text(
                                    cart.cash.toStringAsFixed(3),
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ],
                              ),
                            if (cart.credit != 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Credit'.tr,
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    ),
                                  ),
                                  Text(
                                    cart.credit.toStringAsFixed(3),
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                ],
                              ),
                            SizedBox(height: 15.h),
                            Image.asset(
                              Assets.kAssetsWelcome,
                              height: 80.h,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (kitchenPrinter)
              Column(
                children: [
                  const Divider(thickness: 2),
                  Text(
                    'Kitchens Invoices'.tr,
                    style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                  ),
                  const Divider(thickness: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: invoices.length,
                      separatorBuilder: (context, index) => invoices[index].items.isEmpty ? Container() : const Divider(thickness: 2),
                      itemBuilder: (context, index) => invoices[index].items.isEmpty
                          ? Container()
                          : Screenshot(
                              controller: invoices[index].screenshotController,
                              child: SizedBox(
                                width: mySharedPreferences.printerWidth.toDouble(),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          Text(
                                            cart.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                                            style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${'Order No'.tr} : ${cart.orderNo}',
                                            style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                          ),
                                          if (cart.orderType == OrderType.dineIn)
                                            Text(
                                              '${'Table No'.tr} : ${allDataModel.tables.firstWhereOrNull((element) => element.id == cart.tableId)?.tableNo ?? ''}',
                                              style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                            ),
                                          Text(
                                            '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                          ),
                                          Text(
                                            '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                            flex: 4,
                                            child: Text(
                                              'Item Name'.tr,
                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Qty'.tr,
                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Note'.tr,
                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(color: Colors.black, height: 1),
                                    ListView.separated(
                                      itemCount: invoices[index].items.length,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      separatorBuilder: (context, indexItem) => const Divider(
                                        height: 0,
                                      ),
                                      itemBuilder: (context, indexItem) {
                                        if (invoices[index].items[indexItem].parentUuid.isNotEmpty) {
                                          return Container();
                                        } else {
                                          var subItem = cart.items.where((element) => element.parentUuid == invoices[index].items[indexItem].uuid).toList();
                                          return Column(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        invoices[index].items[indexItem].name,
                                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '${invoices[index].items[indexItem].qty}',
                                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        invoices[index].items[indexItem].note,
                                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                      itemCount: invoices[index].items[indexItem].questions.length,
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context, indexQuestions) => Column(
                                                        children: [
                                                          // Row(
                                                          //   children: [
                                                          //     Expanded(
                                                          //       child: Text(
                                                          //         '- ${cart.items[index].questions[indexQuestions].question.trim()}',
                                                          //         style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                          //       ),
                                                          //     ),
                                                          //   ],
                                                          // ),
                                                          ListView.builder(
                                                            itemCount: invoices[index].items[indexItem].questions[indexQuestions].modifiers.length,
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemBuilder: (context, indexModifiers) => Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        '  • ${invoices[index].items[indexItem].questions[indexQuestions].modifiers[indexModifiers].modifier}',
                                                                        style: kStyleDataPrinter.copyWith(
                                                                            fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                      itemCount: invoices[index].items[indexItem].modifiers.length,
                                                      shrinkWrap: true,
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      itemBuilder: (context, indexModifiers) => Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '• ${invoices[index].items[indexItem].modifiers[indexModifiers].name} * ${invoices[index].items[indexItem].modifiers[indexModifiers].modifier}',
                                                              style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                                  textAlign: TextAlign.center,
                                                                  maxLines: 1,
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '${subItem[indexSubItem].qty}',
                                                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  subItem[indexSubItem].note,
                                                                  style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                                  textAlign: TextAlign.center,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    if (cart.note.isNotEmpty)
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Divider(
                                            color: Colors.black,
                                            height: 0,
                                          ),
                                          Text(
                                            cart.note,
                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                          ),
                                        ],
                                      ),
                                  ],
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
      barrierDismissible: false,
    );
  }

  static Future<void> printKitchenVoidItemsDialog({required CartModel cart, required List<CartItemModel> itemsVoid}) async {
    List<PrinterInvoiceModel> invoices = [];

    for (var printer in allDataModel.printers) {
      var itemsPrinter = allDataModel.itemsPrintersModel.where((element) => element.kitchenPrinter.id == printer.id).toList();
      List<CartItemModel> cartItems = itemsVoid.where((element) => itemsPrinter.any((elementPrinter) => element.id == elementPrinter.itemId)).toList();
      if (cartItems.isNotEmpty) {
        invoices.add(PrinterInvoiceModel(
            ipAddress: printer.ipAddress, port: printer.port, openCashDrawer: false, screenshotController: ScreenshotController(), items: cartItems));
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      await Future.forEach(invoices, (PrinterInvoiceModel element) async {
        var screenshotKitchen = await element.screenshotController.capture(delay: const Duration(milliseconds: 10));
        element.invoice = screenshotKitchen;
      });
      invoices.removeWhere((element) => element.invoice == null);
      Printer.invoices(invoices: invoices);
    });

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
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  fixed: true,
                  child: Text('Close'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(thickness: 2),
            Column(
              children: [
                const Divider(thickness: 2),
                Text(
                  'Kitchens Invoices'.tr,
                  style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                ),
                const Divider(thickness: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: invoices.length,
                    separatorBuilder: (context, index) => invoices[index].items.isEmpty ? Container() : const Divider(thickness: 2),
                    itemBuilder: (context, index) => invoices[index].items.isEmpty
                        ? Container()
                        : Screenshot(
                            controller: invoices[index].screenshotController,
                            child: SizedBox(
                              width: mySharedPreferences.printerWidth.toDouble(),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Void Items'.tr,
                                          style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                                        ),
                                        Text(
                                          cart.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                                          style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${'Order No'.tr} : ${cart.orderNo}',
                                          style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                        ),
                                        if (cart.orderType == OrderType.dineIn)
                                          Text(
                                            '${'Table No'.tr} : ${allDataModel.tables.firstWhereOrNull((element) => element.id == cart.tableId)?.tableNo ?? ''}',
                                            style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                          ),
                                        Text(
                                          '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
                                          style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                        ),
                                        Text(
                                          '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                          style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                          flex: 4,
                                          child: Text(
                                            'Item Name'.tr,
                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            'Qty'.tr,
                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Note'.tr,
                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: Colors.black, height: 1),
                                  ListView.separated(
                                    itemCount: invoices[index].items.length,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    separatorBuilder: (context, indexItem) => const Divider(
                                      height: 0,
                                    ),
                                    itemBuilder: (context, indexItem) {
                                      if (invoices[index].items[indexItem].parentUuid.isNotEmpty) {
                                        return Container();
                                      } else {
                                        var subItem = itemsVoid.where((element) => element.parentUuid == invoices[index].items[indexItem].uuid).toList();
                                        return Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      invoices[index].items[indexItem].name,
                                                      style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '${invoices[index].items[indexItem].qty}',
                                                      style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      invoices[index].items[indexItem].note,
                                                      style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                    itemCount: invoices[index].items[indexItem].questions.length,
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, indexQuestions) => Column(
                                                      children: [
                                                        // Row(
                                                        //   children: [
                                                        //     Expanded(
                                                        //       child: Text(
                                                        //         '- ${cart.items[index].questions[indexQuestions].question.trim()}',
                                                        //         style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                        //       ),
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                        ListView.builder(
                                                          itemCount: invoices[index].items[indexItem].questions[indexQuestions].modifiers.length,
                                                          shrinkWrap: true,
                                                          physics: const NeverScrollableScrollPhysics(),
                                                          itemBuilder: (context, indexModifiers) => Column(
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      '  • ${invoices[index].items[indexItem].questions[indexQuestions].modifiers[indexModifiers].modifier}',
                                                                      style:
                                                                          kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                    itemCount: invoices[index].items[indexItem].modifiers.length,
                                                    shrinkWrap: true,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, indexModifiers) => Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '• ${invoices[index].items[indexItem].modifiers[indexModifiers].name} * ${invoices[index].items[indexItem].modifiers[indexModifiers].modifier}',
                                                            style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                                                                style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                                textAlign: TextAlign.center,
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '${subItem[indexSubItem].qty}',
                                                                style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child: Text(
                                                                subItem[indexSubItem].note,
                                                                style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  ),
                                ],
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
      barrierDismissible: false,
    );
  }

  static Future<void> invoices({required List<PrinterInvoiceModel> invoices}) async {
    for (var invoice in invoices) {
      // if(mySharedPreferences.printerBluetooth){
      // esc_bluetooth.PrinterBluetoothManager printerManager = esc_bluetooth.PrinterBluetoothManager();
      // printerManager.scanResults.listen((printers) async {
      //   // store found printers
      // });
      // printerManager.startScan(const Duration(seconds: 4));
      // printerManager.selectPrinter(printer);
      // printImageBluetooth(printerManager, invoice.invoice!);
      // } else {
      final profile = await CapabilityProfile.load(); //name: 'TP806L'
      final printer = NetworkPrinter(PaperSize.mm80, profile);
      var printerResult = await printer.connect(invoice.ipAddress, port: invoice.port);
      if (printerResult == PosPrintResult.success) {
        try {
          printImage(printer, invoice.invoice!, openCashDrawer: invoice.openCashDrawer);
          await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
          log('printer catch ${e.toString()} || ${invoice.ipAddress}:${invoice.port}');
          // try {
          //   printImage(printer, invoice.invoice!, openCashDrawer: invoice.openCashDrawer);
          //   await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
          //   printer.disconnect();
          //   await Future.delayed(const Duration(milliseconds: 200));
          // } catch (e) {
          //   printer.disconnect();
          //   await Future.delayed(const Duration(milliseconds: 200));
          //   log('printer catch ${e.toString()} || ${invoice.ipAddress}:${invoice.port}');
          // }
        }
      } else {
        log('printer else ${printerResult.msg} || ${invoice.ipAddress}:${invoice.port}');
        await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
        printerResult = await printer.connect(invoice.ipAddress, port: invoice.port);
        if (printerResult == PosPrintResult.success) {
          try {
            printImage(printer, invoice.invoice!, openCashDrawer: invoice.openCashDrawer);
            await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
            printer.disconnect();
            await Future.delayed(const Duration(milliseconds: 200));
          } catch (e) {
            printer.disconnect();
            await Future.delayed(const Duration(milliseconds: 200));
            log('printer catch ${e.toString()} || ${invoice.ipAddress}:${invoice.port}');
          }
        } else {
          log('printer catch ${printerResult.msg} || ${invoice.ipAddress}:${invoice.port}');
        }
      }
      // }
    }
  }

  static Future<void> payInOut({required PrinterImageModel printerImageModel}) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
    final printer = NetworkPrinter(PaperSize.mm80, profile);
    final cashPosPrintResult = await printer.connect(printerImageModel.ipAddress, port: printerImageModel.port);
    if (cashPosPrintResult == PosPrintResult.success) {
      try {
        printImage(printer, printerImageModel.image!, openCashDrawer: true);
        await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
        printer.disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        printer.disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
        log('cashPrinter catch ${e.toString()} || ${printerImageModel.ipAddress}:${printerImageModel.port}');
        try {
          printImage(printer, printerImageModel.image!, openCashDrawer: true);
          await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
          log('cashPrinter catch ${e.toString()} || ${printerImageModel.ipAddress}:${printerImageModel.port}');
        }
      }
    } else {
      log('cashPrinter catch ${cashPosPrintResult.msg} || ${printerImageModel.ipAddress}:${printerImageModel.port}');
    }
  }

  static void printImage(NetworkPrinter printer, Uint8List invoice, {bool openCashDrawer = false}) {
    final img.Image? image = img.decodeImage(invoice);
    printer.image(image!, align: PosAlign.center);
    printer.cut();
    if (openCashDrawer) {
      printer.drawer();
    }
  }

  // static void printImageBluetooth(esc_bluetooth.PrinterBluetoothManager printer, Uint8List invoice, {bool openCashDrawer = false}) async{
  //   final profile = await CapabilityProfile.load();
  //   final generator = Generator(PaperSize.mm80, profile);
  //   final img.Image? image = img.decodeImage(invoice);
  //   await printer.printTicket(generator.image(image!, align: PosAlign.center));
  //   await printer.printTicket(generator.cut());
  //   if (openCashDrawer) {
  //     await printer.printTicket(generator.drawer());
  //   }
  // }

  static void openCash(String ipAddress, int port) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
    final printer = NetworkPrinter(PaperSize.mm80, profile);
    final printerResult = await printer.connect(ipAddress, port: port);
    if (printerResult == PosPrintResult.success) {
      try {
        printer.drawer();
        await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
        printer.disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        printer.disconnect();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }
}
