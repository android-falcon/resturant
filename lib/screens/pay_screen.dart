import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:restaurant_system/models/print_invoice_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/print_invoice.dart';
import 'package:restaurant_system/screens/home_screen.dart';
import 'package:restaurant_system/screens/widgets/custom__drop_down.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/socket/kitchen_invoice.dart';
import 'package:restaurant_system/socket/kitchen_socket_client.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/credit_card_type_detector.dart';
import 'package:restaurant_system/utils/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:screenshot/screenshot.dart';

class PayScreen extends StatefulWidget {
  final CartModel cart;
  final int? tableId;

  const PayScreen({Key? key, required this.cart, this.tableId}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  double remaining = 0;
  List<DineInModel> dineInSaved = mySharedPreferences.dineIn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) => calculateRemaining());
  }

  calculateRemaining() {
    remaining = widget.cart.amountDue - (widget.cart.cash + widget.cart.credit + widget.cart.cheque + widget.cart.gift + widget.cart.coupon + widget.cart.point);
    setState(() {});
  }

  Future<Map<String, dynamic>> _showPayDialog({TextEditingController? controllerReceived, required double balance, required double received, bool enableReturnValue = false, TextEditingController? controllerCreditCard}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    if (controllerCreditCard != null && received == 0) {
      controllerReceived ??= TextEditingController(text: balance.toStringAsFixed(3));
    } else {
      controllerReceived ??= TextEditingController(text: received.toStringAsFixed(3));
    }

    if (controllerReceived.text.endsWith('.000')) {
      controllerReceived.text = controllerReceived.text.replaceFirst('.000', '');
    }
    CreditCardType creditCardType = CreditCardType.unknown;
    CreditCardType selectedCreditCard = CreditCardType.visa;
    int? selectedPaymentCompany;
    TextEditingController _controllerSelected = controllerReceived;
    var result = await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            Form(
              key: _keyForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),
                        InkWell(
                          onTap: () {
                            controllerReceived!.text = balance.toStringAsFixed(3);
                          },
                          child: Text(
                            '${'Balance'.tr} : ${balance.toStringAsFixed(3)}',
                            style: kStyleTextTitle,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: controllerReceived,
                          label: Text('Received'.tr),
                          fillColor: Colors.white,
                          maxLines: 1,
                          inputFormatters: [
                            EnglishDigitsTextInputFormatter(decimal: true),
                          ],
                          enableInteractiveSelection: false,
                          keyboardType: const TextInputType.numberWithOptions(),
                          borderColor: _controllerSelected == controllerReceived ? ColorsApp.primaryColor : null,
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            _controllerSelected = controllerReceived!;
                            setState(() {});
                          },
                          validator: (value) {
                            if (!enableReturnValue) {
                              if (double.parse(value!) > double.parse(balance.toStringAsFixed(3))) {
                                return '${'The entered value cannot be greater than the balance'.tr} (${balance.toStringAsFixed(3)})';
                              }
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.h),
                        if (controllerCreditCard != null)
                          Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                      title: Text('Visa'.tr),
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                      value: CreditCardType.visa,
                                      groupValue: selectedCreditCard,
                                      onChanged: (value) {
                                        selectedCreditCard = value as CreditCardType;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                      title: Text('Mastercard'.tr),
                                      dense: true,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                                      value: CreditCardType.mastercard,
                                      groupValue: selectedCreditCard,
                                      onChanged: (value) {
                                        selectedCreditCard = value as CreditCardType;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              CustomDropDown(
                                isExpanded: true,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                hint: 'Payment Company'.tr,
                                items: allDataModel.paymentCompanyModel.map((e) => DropdownMenuItem(child: Text(e.coName), value: e.id)).toList(),
                                selectItem: selectedPaymentCompany,
                                onChanged: (value) {
                                  selectedPaymentCompany = value as int;
                                  setState(() {});
                                },
                              ),
                              CustomTextField(
                                controller: controllerCreditCard,
                                label: Text('Card Number'.tr),
                                hintText: 'XXXX XXXX XXXX XXXX',
                                fillColor: Colors.white,
                                maxLines: 1,
                                maxLength: 19,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CardNumberFormatter(),
                                ],
                                keyboardType: TextInputType.number,
                                borderColor: _controllerSelected == controllerCreditCard ? ColorsApp.primaryColor : null,
                                suffixIcon: iconCreditCard(type: creditCardType),
                                onChanged: (value) {
                                  creditCardType = detectCCType(value);
                                  setState(() {});
                                },
                                onTap: () {
                                  FocusScope.of(context).requestFocus(FocusNode());
                                  _controllerSelected = controllerCreditCard;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: numPadWidget(
                        _controllerSelected,
                        (p0) {
                          if (_controllerSelected == controllerCreditCard) {
                            creditCardType = detectCCType(controllerCreditCard!.text);
                          }
                          setState(() {});
                          setState;
                        },
                        onSubmit: () {
                          if (_keyForm.currentState!.validate()) {
                            if (controllerCreditCard != null && selectedPaymentCompany == null) {
                              Fluttertoast.showToast(msg: 'Please select a payment company'.tr);
                            } else {
                              Get.back(result: controllerReceived!.text);
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    double _received = result == null ? received : double.parse(result);
    if ((_received - double.parse(balance.toStringAsFixed(3)) == 0)) {
      _received = balance;
    } else if (enableReturnValue && _received > balance) {
      await Get.dialog(
        CustomDialog(
          builder: (context, setState, constraints) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 80.h),
                  child: Text(
                    '${'Please return this value'.tr} :    ${(_received - balance).toStringAsFixed(3)}',
                    style: kStyleTextTitle,
                  ),
                ),
                CustomButton(
                  fixed: true,
                  padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                  child: Text(
                    'Done'.tr,
                    style: kStyleButtonPayment,
                  ),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      _received = balance;
    }
    return {"received": _received, "credit_card": controllerCreditCard?.text ?? "", "credit_card_type": selectedCreditCard.name, 'payment_company': selectedPaymentCompany};
  }

  Future<void> _showPrintDialog() async {
    ScreenshotController _screenshotControllerCash = ScreenshotController();
    List<PrintInvoiceModel> invoices = [];

    for (var printer in allDataModel.printers) {
      if (printer.cashNo == mySharedPreferences.cashNo) {
        invoices.add(PrintInvoiceModel(ipAddress: printer.ipAddress, screenshotController: ScreenshotController(), items: []));
      }
      var itemsPrinter = allDataModel.itemsPrintersModel.where((element) => element.kitchenPrinter.id == printer.id).toList();
      List<CartItemModel> cartItems = widget.cart.items.where((element) => itemsPrinter.any((elementPrinter) => element.id == elementPrinter.itemId)).toList();
      if (cartItems.isNotEmpty) {
        invoices.add(PrintInvoiceModel(ipAddress: printer.ipAddress, screenshotController: ScreenshotController(), items: cartItems));
      }
    }
    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      var screenshotCash = await _screenshotControllerCash.capture(delay: const Duration(milliseconds: 10));
      await Future.forEach(invoices, (PrintInvoiceModel element) async {
        if (element.items.isEmpty) {
          element.invoice = screenshotCash;
        } else {
          var screenshotKitchen = await element.screenshotController.capture(delay: const Duration(milliseconds: 10));
          element.invoice = screenshotKitchen;
        }
      });
      invoices.removeWhere((element) => element.invoice == null);
      PrintInvoice.init(invoices: invoices);
    });

    await Get.dialog(
      CustomDialog(
        width: 100,
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
                    PrintInvoice.init(invoices: invoices);
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
                width: 215,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Text(
                            widget.cart.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
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
                            '${mySharedPreferences.orderNo - 1}',
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
                              Text(
                                '${'Invoice No'.tr} : ${mySharedPreferences.inVocNo - 1}',
                                style: kStyleDataPrinter,
                              ),
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
                              if (widget.cart.orderType == OrderType.dineIn)
                                Text(
                                  '${'Table No'.tr} : ${widget.cart.tableNo}',
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
                          itemCount: widget.cart.items.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
                          itemBuilder: (context, index) {
                            if (widget.cart.items[index].parentUuid.isNotEmpty) {
                              return Container();
                            } else {
                              var subItem = widget.cart.items.where((element) => element.parentUuid == widget.cart.items[index].uuid).toList();
                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            widget.cart.items[index].name,
                                            style: kStyleDataPrinter,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            '${widget.cart.items[index].qty}',
                                            style: kStyleDataPrinter,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            widget.cart.items[index].total.toStringAsFixed(2),
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
                                          itemCount: widget.cart.items[index].questions.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, indexQuestions) => Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      '- ${widget.cart.items[index].questions[indexQuestions].question.trim()}',
                                                      style: kStyleDataPrinter,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              ListView.builder(
                                                itemCount: widget.cart.items[index].questions[indexQuestions].modifiers.length,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemBuilder: (context, indexModifiers) => Column(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            '  • ${widget.cart.items[index].questions[indexQuestions].modifiers[indexModifiers]}',
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
                                          itemCount: widget.cart.items[index].modifiers.length,
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, indexModifiers) => Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '• ${widget.cart.items[index].modifiers[indexModifiers].name} * ${widget.cart.items[index].modifiers[indexModifiers].modifier}',
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
                                                      subItem[indexSubItem].priceChange.toStringAsFixed(2),
                                                      style: kStyleDataPrinter,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      subItem[indexSubItem].total.toStringAsFixed(2),
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
                                widget.cart.total.toStringAsFixed(3),
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
                                widget.cart.totalDiscount.toStringAsFixed(3),
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
                                widget.cart.totalLineDiscount.toStringAsFixed(3),
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
                                widget.cart.deliveryCharge.toStringAsFixed(3),
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
                                widget.cart.service.toStringAsFixed(3),
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
                                widget.cart.tax.toStringAsFixed(3),
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
                                widget.cart.amountDue.toStringAsFixed(3),
                                style: kStyleTitlePrinter.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.black, thickness: 2),
                          if (widget.cart.cash != 0)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Cash'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  widget.cart.cash.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          if (widget.cart.credit != 0)
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Credit'.tr,
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  widget.cart.credit.toStringAsFixed(3),
                                  style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          SizedBox(height: 15.h),
                          Image.asset(
                            'assets/images/welcome.png',
                            height: 60.h,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(thickness: 2),
            Text(
              'Kitchens Invoices'.tr,
              style: kStyleLargePrinter,
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
                          width: 215,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      widget.cart.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                                      style: kStyleLargePrinter,
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
                                      '${'Order No'.tr} : ${mySharedPreferences.orderNo - 1}',
                                      style: kStyleTitlePrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    if (widget.cart.orderType == OrderType.dineIn)
                                      Text(
                                        '${'Table No'.tr} : 1',
                                        style: kStyleTitlePrinter.copyWith(fontWeight: FontWeight.bold),
                                      ),
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
                                      flex: 2,
                                      child: Text(
                                        'Note'.tr,
                                        style: kStyleDataPrinter,
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
                                itemBuilder: (context, indexItem) => Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          invoices[index].items[indexItem].name,
                                          style: kStyleDataPrinter,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${invoices[index].items[indexItem].qty}',
                                          style: kStyleDataPrinter,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          invoices[index].items[indexItem].note,
                                          style: kStyleDataPrinter,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (widget.cart.note.isNotEmpty)
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(
                                      color: Colors.black,
                                      height: 0,
                                    ),
                                    Text(
                                      widget.cart.note,
                                      style: kStyleDataPrinter,
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
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 50.h,
              color: ColorsApp.gray,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 2,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      '${'Table'.tr} : ',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault,
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 2,
                  ),
                  Expanded(
                    child: Text(
                      '${'Check'.tr} : ',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault,
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 2,
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose), //  hh:mm a
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault,
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 2,
                  ),
                  Image.asset(
                    'assets/images/printer.png',
                    height: 45.h,
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          height: Get.height * 0.4,
                          padding: EdgeInsets.all(16.h),
                          child: Align(
                            alignment: AlignmentDirectional.bottomCenter,
                            child: Text(
                              '${'Remaining'.tr} : ${remaining.toStringAsFixed(3)}',
                              style: kStyleTextTitle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: ColorsApp.grayLight,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          margin: EdgeInsets.all(8.h),
                                          height: double.infinity,
                                          child: Text(
                                            widget.cart.cash == 0 ? 'Cash'.tr : '${'Cash'.tr} : ${widget.cart.cash.toStringAsFixed(3)}',
                                            style: kStyleButtonPayment,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () async {
                                            var result = await _showPayDialog(balance: remaining + widget.cart.cash, received: widget.cart.cash, enableReturnValue: true);
                                            widget.cart.cash = result['received'];
                                            calculateRemaining();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomButton(
                                          margin: EdgeInsets.all(8.h),
                                          height: double.infinity,
                                          child: Text(
                                            widget.cart.credit == 0 ? 'Credit Card'.tr : '${'Credit Card'.tr} : ${widget.cart.credit.toStringAsFixed(3)}',
                                            style: kStyleButtonPayment,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () async {
                                            var result = await _showPayDialog(balance: remaining + widget.cart.credit, received: widget.cart.credit, enableReturnValue: false, controllerCreditCard: TextEditingController(text: widget.cart.creditCardNumber));
                                            widget.cart.credit = result['received'];
                                            widget.cart.creditCardNumber = result['credit_card'];
                                            widget.cart.creditCardType = result['credit_card_type'];
                                            widget.cart.payCompanyId = result['payment_company'];
                                            calculateRemaining();
                                          },
                                        ),
                                      ),
                                      // Expanded(
                                      //   child: CustomButton(
                                      //     margin: EdgeInsets.all(8.h),
                                      //     height: double.infinity,
                                      //     child: Text(
                                      //       widget.cart.cheque == 0 ? 'Cheque'.tr : '${'Cheque'.tr} : ${widget.cart.cheque.toStringAsFixed(3)}',
                                      //       style: kStyleButtonPayment,
                                      //       textAlign: TextAlign.center,
                                      //     ),
                                      //     onPressed: () async {
                                      //       widget.cart.cheque = await _showDeliveryDialog(balance: remaining + widget.cart.cheque, received: widget.cart.cheque, enableReturnValue: false);
                                      //       calculateRemaining();
                                      //     },
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                                // Expanded(
                                //   child: Row(
                                //     children: [
                                //       Expanded(
                                //         child: CustomButton(
                                //           margin: EdgeInsets.all(8.h),
                                //           height: double.infinity,
                                //           child: Text(
                                //             widget.cart.gift == 0 ? 'Gift Card'.tr : '${'Gift Card'.tr} : ${widget.cart.gift.toStringAsFixed(3)}',
                                //             style: kStyleButtonPayment,
                                //             textAlign: TextAlign.center,
                                //           ),
                                //           onPressed: () async {
                                //             widget.cart.gift = await _showDeliveryDialog(balance: remaining + widget.cart.gift, received: widget.cart.gift, enableReturnValue: false);
                                //             calculateRemaining();
                                //           },
                                //         ),
                                //       ),
                                //       Expanded(
                                //         child: CustomButton(
                                //           margin: EdgeInsets.all(8.h),
                                //           height: double.infinity,
                                //           child: Text(
                                //             widget.cart.coupon == 0 ? 'Coupon'.tr : '${'Coupon'.tr} : ${widget.cart.coupon.toStringAsFixed(3)}',
                                //             style: kStyleButtonPayment,
                                //             textAlign: TextAlign.center,
                                //           ),
                                //           onPressed: () async {
                                //             widget.cart.coupon = await _showDeliveryDialog(balance: remaining + widget.cart.coupon, received: widget.cart.coupon, enableReturnValue: false);
                                //             calculateRemaining();
                                //           },
                                //         ),
                                //       ),
                                //       Expanded(
                                //         child: CustomButton(
                                //           margin: EdgeInsets.all(8.h),
                                //           height: double.infinity,
                                //           child: Text(
                                //             widget.cart.point == 0 ? 'Point'.tr : '${'Point'.tr} : ${widget.cart.point.toStringAsFixed(3)}',
                                //             style: kStyleButtonPayment,
                                //             textAlign: TextAlign.center,
                                //           ),
                                //           onPressed: () async {
                                //             widget.cart.point = await _showDeliveryDialog(balance: remaining + widget.cart.point, received: widget.cart.point, enableReturnValue: false);
                                //             calculateRemaining();
                                //           },
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Container(
                      width: 110.w,
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.total.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Delivery Charge'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.deliveryCharge.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Line Discount'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.totalLineDiscount.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Discount'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.totalDiscount.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Sub Total'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.subTotal.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Service'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.service.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Tax'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.tax.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Amount Due'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.amountDue.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.black),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total Due'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      widget.cart.amountDue.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total Received'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      (widget.cart.cash + widget.cart.credit + widget.cart.cheque + widget.cart.gift + widget.cart.coupon + widget.cart.point).toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Balance'.tr,
                                        style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(
                                      remaining.toStringAsFixed(3),
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const Divider(color: Colors.black),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: CustomButton(
                                          child: Text(
                                            'Save'.tr,
                                            style: kStyleTextButton,
                                          ),
                                          fixed: true,
                                          backgroundColor: ColorsApp.primaryColor,
                                          onPressed: () {
                                            if (remaining == 0) {
                                              for (int i = 0; i < widget.cart.items.length; i++) {
                                                widget.cart.items[i].rowSerial = i + 1;
                                              }
                                              RestApi.invoice(widget.cart);
                                              KitchenInvoice.init(orderNo: mySharedPreferences.orderNo, cart: widget.cart);

                                              mySharedPreferences.inVocNo++;
                                              mySharedPreferences.orderNo++;

                                              _showPrintDialog().then((value) {
                                                Get.offAll(HomeScreen());
                                              });
                                              if (widget.tableId != null) {
                                                RestApi.closeTable(widget.tableId!);
                                                var indexTable = dineInSaved.indexWhere((element) => element.tableId == widget.tableId);
                                                dineInSaved[indexTable].isOpen = false;
                                                dineInSaved[indexTable].numberSeats = 0;
                                                dineInSaved[indexTable].cart = CartModel.init(orderType: OrderType.dineIn);
                                                mySharedPreferences.dineIn = dineInSaved;
                                              }
                                            } else {
                                              Fluttertoast.showToast(msg: 'The remainder should be 0'.tr);
                                            }
                                          },
                                        ),
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
