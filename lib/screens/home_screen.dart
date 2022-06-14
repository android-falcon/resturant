import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/refund_model.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
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
      AlertDialog(
        contentPadding: EdgeInsets.all(4.w),
        backgroundColor: ColorsApp.backgroundDialog,
        content: StatefulBuilder(
          builder: (context, setState) => GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              if (_typeInputCash == 1) {
                _controllerSelectEdit = _controllerManual;
              } else {
                _controllerSelectEdit = null;
                setState(() {});
              }
            },
            child: SizedBox(
              width: 0.95.sw,
              height: 0.95.sh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('${'Date'.tr} : ${DateFormat('yyyy/MM/dd').format(DateTime.now())}'),
                        ),
                        Text(
                          type == PayDialogType.payIn ? 'Pay In'.tr : 'Pay Out'.tr,
                          style: kStyleTextTitle,
                        ),
                        const Expanded(
                          child: Text(
                            '', //'${'Transaction Number'.tr} : ',
                            textAlign: TextAlign.end,
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
                                        title: Text('Manual'.tr),
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
                                        title: Text('Money Count'.tr),
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
                                          ),
                                          Text(
                                            '${MoneyCount.moneyCount.fold(0.0, (previousValue, element) => (previousValue as double) + (element.value * double.parse(element.qty.text)))}',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: ColorsApp.red),
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
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              'Total'.tr,
                                              textAlign: TextAlign.center,
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
            ),
          ),
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

    Get.dialog(
      AlertDialog(
        contentPadding: EdgeInsets.all(4.w),
        backgroundColor: ColorsApp.backgroundDialog,
        content: StatefulBuilder(
          builder: (context, setState) => GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              _controllerSelectEdit = null;
              setState(() {});
            },
            child: SizedBox(
              width: 0.95.sw,
              height: 0.95.sh,
              child: SingleChildScrollView(
                child: Column(
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
                      child: Table(
                        children: [
                          _buildRowTable(isHeader: true),
                          _buildRowTable(row: Item(serial: 'aa', name: 'aa', qty: 0, price: 0)),
                          _buildRowTable(isFooter: true,row: Item(serial: 'aa', name: 'aa', qty: 0, price: 0)),
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
                                ),
                                Text(
                                  '${'Discount'.tr} : ',
                                  textAlign: TextAlign.end,
                                ),
                                Text(
                                  '${'Net Total'.tr} : ',
                                  textAlign: TextAlign.end,
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
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  TableRow _buildRowTable({Item? row, bool isHeader = false, isFooter = false}) {
    return TableRow(
      decoration: isHeader
          ? BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(3.r), topRight: Radius.circular(3.r)),
            )
          : isFooter
              ? const BoxDecoration(
                  border: Border(left: BorderSide(), right: BorderSide(), bottom: BorderSide()),

                )
              : const BoxDecoration(
                  border: Border(left: BorderSide(), right: BorderSide()),
                ),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              isHeader ? 'Serial'.tr : row!.serial,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isHeader ? ColorsApp.red : Colors.black),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              isHeader ? 'Item'.tr : row!.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isHeader ? ColorsApp.red : Colors.black),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              isHeader ? 'Qty'.tr : '${row!.qty}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isHeader ? ColorsApp.red : Colors.black),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              isHeader ? 'R.Qty'.tr : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isHeader ? ColorsApp.red : Colors.black),
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
            child: Text(
              isHeader ? 'R.Total'.tr : '',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: isHeader ? FontWeight.bold : FontWeight.normal, fontSize: 12, color: isHeader ? ColorsApp.red : Colors.black),
            ),
          ),
        ),
      ],
    );
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
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                mySharedPreferences.username,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                'Shift'.tr,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            const VerticalDivider(),
                            Expanded(
                              child: Text(
                                DateFormat('yyyy/MM/dd').format(DateTime.now()),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
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
