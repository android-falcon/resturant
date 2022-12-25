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
import 'package:restaurant_system/models/printer_invoice_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/printer.dart';
import 'package:restaurant_system/screens/home_screen.dart';
import 'package:restaurant_system/screens/order_screen.dart';
import 'package:restaurant_system/screens/table_screen.dart';
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
import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:screenshot/screenshot.dart';

class PayScreen extends StatefulWidget {
  final CartModel cart;
  final int? tableId;
  final int? openTypeDialog;

  const PayScreen({Key? key, required this.cart, this.tableId, this.openTypeDialog}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  double remaining = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _calculateRemaining());
  }

  _calculateRemaining() {
    remaining = widget.cart.amountDue - (widget.cart.cash + widget.cart.credit + widget.cart.cheque + widget.cart.gift + widget.cart.coupon + widget.cart.point);
    setState(() {});
  }

  _finishInvoice() {
    if (remaining == 0) {
      for (int i = 0; i < widget.cart.items.length; i++) {
        widget.cart.items[i].rowSerial = i + 1;
      }
      RestApi.invoice(cart: widget.cart, invoiceKind: InvoiceKind.invoicePay);
      KitchenInvoice.init(orderNo: widget.cart.orderNo, cart: widget.cart);

      mySharedPreferences.inVocNo++;

      Printer.printInvoicesDialog(cart: widget.cart, showPrintButton: false, invNo: '${mySharedPreferences.inVocNo - 1}').then((value) {
        Get.offAll(() => HomeScreen());
        if (widget.tableId != null) {
          Get.to(() => TableScreen());
        } else {
          Get.to(() => OrderScreen(type: widget.cart.orderType));
        }
      });
      if (widget.tableId != null) {
        RestApi.closeTable(widget.tableId!);
      }
    } else {
      Fluttertoast.showToast(msg: 'The remainder should be 0'.tr);
    }
  }

  _showFinishDialog() {
    Get.dialog(
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
                  'Do you want to finish the invoice?'.tr,
                  style: kStyleTextTitle.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    fixed: true,
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                    child: Text(
                      'Close'.tr,
                      style: kStyleButtonPayment,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  SizedBox(width: 25.w),
                  CustomButton(
                    fixed: true,
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
                    child: Text(
                      'Finish'.tr,
                      style: kStyleButtonPayment,
                    ),
                    onPressed: () {
                      Get.back();
                      _finishInvoice();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<Map<String, dynamic>> _showPayDialog({TextEditingController? controllerReceived, required double balance, required double received, bool enableReturnValue = false, TextEditingController? controllerCreditCard, int? paymentCompany}) async {
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
    if (paymentCompany != null) {
      selectedPaymentCompany = paymentCompany;
    }
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
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text(
                              '${'Balance'.tr} : ${balance.toStringAsFixed(3)}',
                              style: kStyleTextTitle,
                            ),
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
                      child: Utils.numPadWidget(
                        _controllerSelected,
                        (p0) {
                          if (_controllerSelected == controllerCreditCard) {
                            creditCardType = detectCCType(controllerCreditCard!.text);
                          }
                          setState(() {});
                          setState;
                        },
                        onClear: () {
                          Get.back(result: "0.0");
                        },
                        onSubmit: () {
                          if (_keyForm.currentState!.validate()) {
                            if (controllerCreditCard != null && selectedPaymentCompany == null && controllerReceived!.text != '0') {
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
    if ((_received - double.parse(balance.toStringAsFixed(3))) == 0) {
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
                    icon: const Icon(Icons.arrow_back_ios),
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
                  Expanded(
                    child: Text(
                      '${'Check'.tr} : ',
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault,
                    ),
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
                  IconButton(
                    onPressed: () {

                    },
                    icon:  Icon(Icons.print,color: ColorsApp.orange_2,size: 30,),
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
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.r),
                              border: Border.all(color: ColorsApp.orange_2)),
                          height: Get.height * 0.4,
                          padding: EdgeInsets.all(16.h),
                          child: Align(
                            alignment: AlignmentDirectional.center,
                            child: Text(
                              '${'Remaining'.tr} : ${remaining.toStringAsFixed(3)}',
                              style: kStyleTextTitle,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: ColorsApp.backgroundDialog,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible: (widget.openTypeDialog != 0),
                                        child: Expanded(
                                          child: CustomButton(
                                            backgroundColor: ColorsApp.orange_2,
                                            margin: EdgeInsets.all(10.h),
                                            height: 50.h,
                                            child: Text(
                                              widget.cart.cash == 0 ? 'Cash'.tr : '${'Cash'.tr} : ${widget.cart.cash.toStringAsFixed(3)}',
                                              style: kStyleButtonPayment,
                                              textAlign: TextAlign.center,
                                            ),
                                            onPressed: () async {
                                              var result = await _showPayDialog(balance: remaining + widget.cart.cash, received: widget.cart.cash, enableReturnValue: true);
                                              widget.cart.cash = result['received'];
                                              _calculateRemaining();
                                              if (remaining == 0) {
                                                _showFinishDialog();
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: (widget.openTypeDialog != 1),
                                        child: Expanded(
                                          child: CustomButton(
                                            backgroundColor: ColorsApp.blue_light,
                                            margin: EdgeInsets.all(10.h),
                                            height: 50.h,
                                            child: Text(
                                              widget.cart.credit == 0 ? 'Credit Card'.tr : '${'Credit Card'.tr} : ${widget.cart.credit.toStringAsFixed(3)}',
                                              style: kStyleButtonPayment,
                                              textAlign: TextAlign.center,
                                            ),
                                            onPressed: () async {
                                              var result = await _showPayDialog(
                                                balance: remaining + widget.cart.credit,
                                                received: widget.cart.credit,
                                                enableReturnValue: false,
                                                controllerCreditCard: TextEditingController(text: widget.cart.creditCardNumber),
                                                paymentCompany: widget.cart.payCompanyId == 0 ? null : widget.cart.payCompanyId,
                                              );
                                              widget.cart.credit = result['received'];
                                              widget.cart.creditCardNumber = result['credit_card'];
                                              widget.cart.creditCardType = result['credit_card_type'];
                                              widget.cart.payCompanyId = result['payment_company'];
                                              _calculateRemaining();
                                              if (remaining == 0) {
                                                _showFinishDialog();
                                              }
                                            },
                                          ),
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
                              border: Border.all(color: ColorsApp.orange_2),
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
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red_light, fontWeight: FontWeight.bold),
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
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red_light, fontWeight: FontWeight.bold),
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
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red_light, fontWeight: FontWeight.bold),
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
                                          backgroundColor: ColorsApp.orange_2,
                                          onPressed: () {
                                            _finishInvoice();
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
