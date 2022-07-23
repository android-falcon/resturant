import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/home_screen.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';

class PayScreen extends StatefulWidget {
  final CartModel cart;

  const PayScreen({Key? key, required this.cart}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> {
  double remaining = 0;

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

  Future<double> _showDeliveryDialog({TextEditingController? controller, required double balance, required double received, bool enableReturnValue = false}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '$received');
    if (controller.text.endsWith('.0')) {
      controller.text = controller.text.replaceFirst('.0', '');
    }
    var _received = await Get.dialog(
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
                        Text(
                          '${'Balance'.tr} : ${balance.toStringAsFixed(3)}',
                          style: kStyleTextTitle,
                        ),
                        SizedBox(height: 8.h),
                        CustomTextField(
                          controller: controller,
                          label: Text('Received'.tr),
                          fillColor: Colors.white,
                          maxLines: 1,
                          inputFormatters: [
                            EnglishDigitsTextInputFormatter(decimal: true),
                          ],
                          enableInteractiveSelection: false,
                          keyboardType: const TextInputType.numberWithOptions(),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                          validator: (value) {
                            if (!enableReturnValue) {
                              if (double.parse(value!) > balance) {
                                return '${'The entered value cannot be greater than the balance'.tr} (${balance.toStringAsFixed(3)})';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: numPadWidget(
                        controller,
                        setState,
                        onSubmit: () {
                          if (_keyForm.currentState!.validate()) {
                            Get.back(result: controller!.text);
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
    _received = _received == null ? received : double.parse(_received);
    if (enableReturnValue && _received > balance) {
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
    return _received;
  }

  Future<void> _showPrintDialog() async {
    await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  child: Text('Print'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
              ],
            ),
            const Divider(thickness: 2),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${'Date'.tr} : '),
                      SizedBox(height: 15.h),
                      Text('${'Invoice No'.tr} : '),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now())),
                      SizedBox(height: 15.h),
                      Text('${mySharedPreferences.inVocNo - 1}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            Column(
              children: [
                Padding(
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
                const Divider(color: Colors.black, height: 1),
                ListView.separated(
                  itemCount: widget.cart.items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
                  itemBuilder: (context, index) => Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${widget.cart.items[index].qty}',
                                  style: kStyleDataTable,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  widget.cart.items[index].name,
                                  style: kStyleDataTable,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.cart.items[index].priceChange.toStringAsFixed(2),
                                  style: kStyleDataTable,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  widget.cart.items[index].total.toStringAsFixed(2),
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
                                itemCount: widget.cart.items[index].questions.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, indexModifiers) => Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '• ${widget.cart.items[index].questions[indexModifiers].name.trim()}? * ${widget.cart.items[index].questions[indexModifiers].modifier}',
                                        style: kStyleDataTableModifiers,
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
                                        style: kStyleDataTableModifiers,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
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
                        widget.cart.lineDiscount.toStringAsFixed(3),
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
                        widget.cart.discount.toStringAsFixed(3),
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
                        style: kStyleTextDefault.copyWith(color: ColorsApp.red, fontWeight: FontWeight.bold),
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
                      DateFormat('yyyy/MM/dd hh:mm a').format(DateTime.now()),
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
                                            widget.cart.cash = await _showDeliveryDialog(balance: remaining + widget.cart.cash, received: widget.cart.cash, enableReturnValue: true);
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
                                            widget.cart.credit = await _showDeliveryDialog(balance: remaining + widget.cart.credit, received: widget.cart.credit, enableReturnValue: false);
                                            calculateRemaining();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomButton(
                                          margin: EdgeInsets.all(8.h),
                                          height: double.infinity,
                                          child: Text(
                                            widget.cart.cheque == 0 ? 'Cheque'.tr : '${'Cheque'.tr} : ${widget.cart.cheque.toStringAsFixed(3)}',
                                            style: kStyleButtonPayment,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () async {
                                            widget.cart.cheque = await _showDeliveryDialog(balance: remaining + widget.cart.cheque, received: widget.cart.cheque, enableReturnValue: false);
                                            calculateRemaining();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          margin: EdgeInsets.all(8.h),
                                          height: double.infinity,
                                          child: Text(
                                            widget.cart.gift == 0 ? 'Gift Card'.tr : '${'Gift Card'.tr} : ${widget.cart.gift.toStringAsFixed(3)}',
                                            style: kStyleButtonPayment,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () async {
                                            widget.cart.gift = await _showDeliveryDialog(balance: remaining + widget.cart.gift, received: widget.cart.gift, enableReturnValue: false);
                                            calculateRemaining();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomButton(
                                          margin: EdgeInsets.all(8.h),
                                          height: double.infinity,
                                          child: Text(
                                            widget.cart.coupon == 0 ? 'Coupon'.tr : '${'Coupon'.tr} : ${widget.cart.coupon.toStringAsFixed(3)}',
                                            style: kStyleButtonPayment,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () async {
                                            widget.cart.coupon = await _showDeliveryDialog(balance: remaining + widget.cart.coupon, received: widget.cart.coupon, enableReturnValue: false);
                                            calculateRemaining();
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomButton(
                                          margin: EdgeInsets.all(8.h),
                                          height: double.infinity,
                                          child: Text(
                                            widget.cart.point == 0 ? 'Point'.tr : '${'Point'.tr} : ${widget.cart.point.toStringAsFixed(3)}',
                                            style: kStyleButtonPayment,
                                            textAlign: TextAlign.center,
                                          ),
                                          onPressed: () async {
                                            widget.cart.point = await _showDeliveryDialog(balance: remaining + widget.cart.point, received: widget.cart.point, enableReturnValue: false);
                                            calculateRemaining();
                                          },
                                        ),
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
                                      widget.cart.lineDiscount.toStringAsFixed(3),
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
                                      widget.cart.discount.toStringAsFixed(3),
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
                                              RestApi.invoice(widget.cart);
                                              mySharedPreferences.inVocNo++;
                                              _showPrintDialog().then((value) {
                                                Get.offAll(HomeScreen());
                                              });
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
