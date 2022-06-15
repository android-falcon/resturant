import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/refund_model.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_data_table.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field_num.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/app_config/money_count.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enum_pay_dialog_type.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:restaurant_system/utils/validation.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HomeMenu> _menu = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _menu = <HomeMenu>[
      HomeMenu(
        name: 'Time Card'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Pay In'.tr,
        onTab: () {
          _showPayInOutDialog(type: PayDialogType.payIn);
        },
      ),
      HomeMenu(
        name: 'Pay Out'.tr,
        onTab: () {
          _showPayInOutDialog(type: PayDialogType.payOut);
        },
      ),
      HomeMenu(
        name: 'Refund'.tr,
        onTab: () {
          _showRefundDialog();
        },
      ),
      HomeMenu(
        name: 'Safe Mode'.tr,
        onTab: () {},
      ),
      HomeMenu(
        name: 'Cash Drawer'.tr,
        onTab: () {},
      ),
    ];
  }

  _showPayInOutDialog({required PayDialogType type}) {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerManual = TextEditingController(text: '0');
    TextEditingController _controllerRemark = TextEditingController();
    TextEditingController? _controllerSelectEdit = _controllerManual;
    int _typeInputCash = 1;

    Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {
          _controllerSelectEdit = null;
        },
        builder: (context, setState, constraints) => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'Date'.tr} : ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                    style: kStyleTextDefault,
                  ),
                ),
                Text(
                  type == PayDialogType.payIn ? 'Pay In'.tr : 'Pay Out'.tr,
                  style: kStyleTextTitle,
                ),
                Expanded(
                  child: Text(
                    '', //'${'Transaction Number'.tr} : ',
                    textAlign: TextAlign.end,
                    style: kStyleTextDefault,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            const Divider(
              thickness: 1,
              height: 1,
            ),
            Form(
              key: _keyForm,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile(
                                value: 1,
                                groupValue: _typeInputCash,
                                onChanged: (value) {
                                  _typeInputCash = value as int;
                                  MoneyCount.clear();
                                  _controllerSelectEdit = _controllerManual;
                                  setState(() {});
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Manual'.tr,
                                  style: kStyleTextDefault,
                                ),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile(
                                value: 2,
                                groupValue: _typeInputCash,
                                onChanged: (value) {
                                  _controllerManual.text = "0";
                                  _typeInputCash = value as int;
                                  MoneyCount.init();
                                  _controllerSelectEdit = null;
                                  setState(() {});
                                },
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Money Count'.tr,
                                  style: kStyleTextDefault,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_typeInputCash == 1)
                          CustomTextField(
                            controller: _controllerManual,
                            label: Text('Value'.tr),
                            fillColor: Colors.white,
                            maxLines: 1,
                            inputFormatters: [
                              EnglishDigitsTextInputFormatter(decimal: true),
                            ],
                            validator: (value) {
                              return Validation.isRequired(value);
                            },
                            enableInteractiveSelection: false,
                            keyboardType: const TextInputType.numberWithOptions(),
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _controllerSelectEdit = _controllerManual;
                            },
                          ),
                        CustomTextField(
                          controller: _controllerRemark,
                          label: Text('Remark'.tr),
                          fillColor: Colors.white,
                          maxLines: 1,
                        ),
                        if (_typeInputCash == 2)
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Cash'.tr,
                                    textAlign: TextAlign.center,
                                    style: kStyleTextDefault,
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total'.tr,
                                    textAlign: TextAlign.center,
                                    style: kStyleTextDefault,
                                  ),
                                  Text(
                                    '${MoneyCount.moneyCount.fold(0.0, (previousValue, element) => (previousValue as double) + (element.value * double.parse(element.qty.text)))}',
                                    textAlign: TextAlign.center,
                                    style: kStyleTextDefault.copyWith(color: ColorsApp.red),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Qty'.tr,
                                      textAlign: TextAlign.center,
                                      style: kStyleTextDefault,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Total'.tr,
                                      textAlign: TextAlign.center,
                                      style: kStyleTextDefault,
                                    ),
                                  ),
                                ],
                              ),
                              ListView.builder(
                                itemCount: MoneyCount.moneyCount.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              MoneyCount.moneyCount[index].qty.text = '${int.parse(MoneyCount.moneyCount[index].qty.text) + 1}';
                                            });
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4.h),
                                            child: Text(
                                              MoneyCount.moneyCount[index].name,
                                              textAlign: TextAlign.center,
                                              style: kStyleTextDefault,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: CustomTextFieldNum(
                                          enableInteractiveSelection: false,
                                          controller: MoneyCount.moneyCount[index].qty,
                                          fillColor: _controllerSelectEdit == MoneyCount.moneyCount[index].qty ? ColorsApp.primaryColor.withOpacity(0.2) : null,
                                          onTap: () {
                                            FocusScope.of(context).requestFocus(FocusNode());
                                            _controllerSelectEdit = MoneyCount.moneyCount[index].qty;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          (MoneyCount.moneyCount[index].value * double.parse(MoneyCount.moneyCount[index].qty.text)).toStringAsFixed(2),
                                          textAlign: TextAlign.center,
                                          style: kStyleTextDefault,
                                        ),
                                      ),
                                    ],
                                  );
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
                      child: numPadWidget(_controllerSelectEdit, setState),
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
  }

  _showRefundDialog() {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerVoucherNumber = TextEditingController();
    TextEditingController? _controllerSelectEdit;
    RefundModel _refundModel = RefundModel.init();
    _refundModel.items.add(Item(serial: 'aa', name: 'aa', qty: 5, price: 0));
    _refundModel.items.add(Item(serial: 'c', name: 'aaaa', qty: 3, price: 10));
    Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {
          _controllerSelectEdit = null;
        },
        builder: (context, setState, constraints) => Column(
          children: [
            Container(
              width: 1.sw,
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'Voucher Number'.tr} : ',
                                  textAlign: TextAlign.end,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              Expanded(
                                child: CustomTextFieldNum(
                                  controller: _controllerVoucherNumber,
                                  fillColor: Colors.white,
                                  decimal: false,
                                  validator: (value) {
                                    return Validation.isRequired(value);
                                  },
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'POS No'.tr} : ',
                                  textAlign: TextAlign.end,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              Expanded(
                                child: Text(_refundModel.posNo),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'Original Data'.tr} : ',
                                  textAlign: TextAlign.end,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              Expanded(
                                child: Text(_refundModel.originalDate),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'Original Time'.tr} : ',
                                  textAlign: TextAlign.end,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              Expanded(
                                child: Text(_refundModel.originalTime),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'Table No'.tr} : ',
                                  textAlign: TextAlign.end,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              Expanded(
                                child: Text(_refundModel.originalTime),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${'Customer'.tr} : ',
                                  textAlign: TextAlign.end,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              Expanded(
                                child: Text(_refundModel.originalTime),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    CustomButton(
                      fixed: true,
                      child: Text('Show'.tr),
                      backgroundColor: ColorsApp.orange,
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: CustomDataTable(
                minWidth: constraints.minWidth,
                rows: _refundModel.items
                    .map(
                      (e) => DataRow(
                        cells: [
                          DataCell(Text(e.serial)),
                          DataCell(Text(e.name)),
                          DataCell(Text('${e.qty}')),
                          DataCell(
                            Text('${e.rQty}'),
                            showEditIcon: true,
                            onTap: () async {
                              e.rQty = await _showQtyDialog(rQty: e.rQty, maxQty: e.qty);
                              setState(() {});
                            },
                          ),
                          DataCell(Text('${e.rTotal}')),
                        ],
                      ),
                    )
                    .toList(),
                columns: [
                  DataColumn(label: Text('Serial'.tr)),
                  DataColumn(label: Text('Item'.tr)),
                  DataColumn(label: Text('Qty'.tr)),
                  DataColumn(label: Text('R.Qty'.tr)),
                  DataColumn(label: Text('R.Total'.tr)),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${'Total'.tr} : ',
                          textAlign: TextAlign.end,
                          style: kStyleTextDefault,
                        ),
                        Text(
                          '${'Discount'.tr} : ',
                          textAlign: TextAlign.end,
                          style: kStyleTextDefault,
                        ),
                        Text(
                          '${'Net Total'.tr} : ',
                          textAlign: TextAlign.end,
                          style: kStyleTextDefault,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(''),
                        Text(''),
                        Text(''),
                      ],
                    )
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  fixed: true,
                  backgroundColor: ColorsApp.red,
                  child: Text('Exit'.tr),
                  onPressed: () {
                    Get.back();
                  },
                ),
                SizedBox(width: 10.w),
                CustomButton(
                  fixed: true,
                  child: Text('Ok'.tr),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<int> _showQtyDialog({TextEditingController? controller, int? maxQty, int minQty = 0, required int rQty}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '$rQty');
    var qty = await Get.dialog(
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
                        CustomTextField(
                          controller: controller,
                          label: Text('${'Qty'.tr} ${maxQty != null ? '($maxQty)' : ''}'),
                          fillColor: Colors.white,
                          maxLines: 1,
                          inputFormatters: [
                            EnglishDigitsTextInputFormatter(decimal: false),
                          ],
                          validator: (value) {
                            return Validation.qty(value, minQty, maxQty);
                          },
                          enableInteractiveSelection: false,
                          keyboardType: const TextInputType.numberWithOptions(),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
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
    if (qty == null) {
      return rQty;
    }
    return int.parse(qty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSingleChildScrollView(
        child: Stack(
          children: [
            Image.asset(
              'assets/images/background_home.png',
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
                        color: Colors.white,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${'Branch'.tr} : ',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: kStyleTextDefault,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                mySharedPreferences.username,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: kStyleTextDefault,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                'Shift'.tr,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: kStyleTextDefault,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                DateFormat('yyyy/MM/dd').format(DateTime.now()),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: kStyleTextDefault,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/take_away.png',
                                        width: 150.h,
                                      ),
                                      Text(
                                        'Take Away'.tr,
                                        style: kStyleTextTitle,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                InkWell(
                                  onTap: () {},
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/dine_in.png',
                                        width: 150.h,
                                      ),
                                      Text(
                                        'Dine In'.tr,
                                        style: kStyleTextTitle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(height: 200.h),
                                CustomButton(
                                  child: Text(
                                    'Exit'.tr,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: ColorsApp.red,
                                  margin: EdgeInsets.all(16.w),
                                  onPressed: () {
                                    if (Platform.isAndroid) {
                                      SystemNavigator.pop();
                                    } else if (Platform.isIOS) {
                                      exit(0);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
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
