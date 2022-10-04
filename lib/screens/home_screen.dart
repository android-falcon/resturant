import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/all_data/item_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/order_screen.dart';
import 'package:restaurant_system/screens/table_screen.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field_num.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/app_config/money_count.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/enums/enum_in_out_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
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
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _menu = <HomeMenu>[
        // HomeMenu(
        //   name: 'Time Card'.tr,
        //   onTab: () {
        //     _showTimeCardDialog();
        //   },
        // ),
        // HomeMenu(
        //   name: 'Cash In'.tr,
        //   onTab: () {
        //     _showInOutDialog(type: InOutType.cashIn);
        //   },
        // ),
        // HomeMenu(
        //   name: 'Cash Out'.tr,
        //   onTab: () {
        //     _showInOutDialog(type: InOutType.cashOut);
        //   },
        // ),
        if (mySharedPreferences.employee.hasCashInOutPermission)
          HomeMenu(
            name: 'Pay In'.tr,
            onTab: () {
              _showInOutDialog(type: InOutType.payIn);
            },
          ),
        if (mySharedPreferences.employee.hasCashInOutPermission)
          HomeMenu(
            name: 'Pay Out'.tr,
            onTab: () {
              _showInOutDialog(type: InOutType.payOut);
            },
          ),
        if (mySharedPreferences.employee.hasRefundPermission)
          HomeMenu(
            name: 'Refund'.tr,
            onTab: () {
              _showRefundDialog();
            },
          ),
        HomeMenu(
          name: 'Cash Drawer'.tr,
          onTab: () async {},
        ),
        if (mySharedPreferences.employee.isMaster)
          HomeMenu(
            name: 'Daily Close'.tr,
            onTab: () {
              Get.defaultDialog(
                title: 'Daily Close'.tr,
                titleStyle: kStyleTextTitle,
                content: Column(
                  children: [
                    Text('Are you sure?'.tr),
                    Text('${'Daily Close Date'.tr} : ${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose)}'),
                    Text('${'New Daily Close Date'.tr} : ${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose.add(const Duration(days: 1)))}'),
                  ],
                ),
                textCancel: 'Cancel'.tr,
                textConfirm: 'Confirm'.tr,
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  await RestApi.posDailyClose(closeDate: mySharedPreferences.dailyClose.add(const Duration(days: 1)));
                  setState(() {});
                },
              );
            },
          ),
        HomeMenu(
          name: 'Rest Order No'.tr,
          onTab: () async {
            var result = await showAreYouSureDialog(title: 'Rest Order No'.tr);
            if (result) {
              RestApi.resetPOSOrderNo();
              mySharedPreferences.orderNo = 1;
            }
          },
        ),
        HomeMenu(
          name: 'Refresh Data'.tr,
          onTab: () async {
            RestApi.getData();
          },
        ),
        HomeMenu(
          name: 'Exit'.tr,
          onTab: () async {
            var result = await showAreYouSureDialog(title: 'Close App'.tr);
            if (result) {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            }
          },
        ),
      ];
      setState(() {});
    });
  }

  _showTimeCardDialog() {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerEmployeeId = TextEditingController();

    Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'Date'.tr} : ${DateFormat('yyyy-MM-dd hh:mm a').format(mySharedPreferences.dailyClose)}',
                    style: kStyleTextDefault,
                  ),
                ),
                Text(
                  'Time Card'.tr,
                  style: kStyleTextTitle,
                ),
                Expanded(
                  child: Text(
                    '',
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
                        CustomTextField(
                          margin: EdgeInsets.only(top: 10.h),
                          controller: _controllerEmployeeId,
                          label: Text('Employee Id'.tr),
                          fillColor: Colors.white,
                          maxLines: 1,
                          inputFormatters: [
                            EnglishDigitsTextInputFormatter(decimal: false),
                          ],
                          validator: (value) {
                            return Validation.isRequired(value);
                          },
                          enableInteractiveSelection: false,
                          keyboardType: const TextInputType.numberWithOptions(),
                          onTap: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                          },
                        ),
                        CustomButton(
                          child: Text('Search'.tr),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: numPadWidget(
                        _controllerEmployeeId,
                        setState,
                        decimal: false,
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
  }

  _showInOutDialog({required InOutType type}) {
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
        builder: (context, setState, constraints) {
          double moneyCount = MoneyCount.moneyCount.fold(0.0, (previousValue, element) => (previousValue) + ((element.value * element.rate) * double.parse(element.qty.text)));
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose)}',
                      style: kStyleTextDefault,
                    ),
                  ),
                  Text(
                    type == InOutType.payIn
                        ? 'Pay In'.tr
                        : type == InOutType.payOut
                            ? 'Pay Out'.tr
                            : type == InOutType.cashIn
                                ? 'Cash In'
                                : type == InOutType.cashOut
                                    ? 'Cash Out'
                                    : '',
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
                                      moneyCount.toStringAsFixed(3),
                                      textAlign: TextAlign.center,
                                      style: kStyleTextDefault.copyWith(color: ColorsApp.red),
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
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
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                MoneyCount.moneyCount[index].qty.text = '${int.parse(MoneyCount.moneyCount[index].qty.text) + 1}';
                                              });
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4.h),
                                              child: Row(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Currencies')?.imgPath ?? ''}${MoneyCount.moneyCount[index].icon}',
                                                    height: 20.h,
                                                    fit: BoxFit.contain,
                                                    placeholder: (context, url) => Container(),
                                                    errorWidget: (context, url, error) => Container(),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      MoneyCount.moneyCount[index].name,
                                                      textAlign: TextAlign.center,
                                                      style: kStyleTextDefault,
                                                    ),
                                                  ),
                                                ],
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
                                            ((MoneyCount.moneyCount[index].value * MoneyCount.moneyCount[index].rate) * double.parse(MoneyCount.moneyCount[index].qty.text)).toStringAsFixed(3),
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
                        child: numPadWidget(
                          _controllerSelectEdit,
                          setState,
                          onExit: () async {
                            var result = await showAreYouSureDialog(title: 'Exit'.tr);
                            if (result) {
                              Get.back();
                            }
                          },
                          onSubmit: () async {
                            var result = await showAreYouSureDialog(title: 'Save'.tr);
                            if (result) {
                              if (_typeInputCash == 1 ? double.parse(_controllerManual.text) > 0 : moneyCount > 0) {
                                switch (type) {
                                  case InOutType.payIn:
                                    RestApi.payInOut(
                                      value: _typeInputCash == 1 ? double.parse(_controllerManual.text) : moneyCount,
                                      remark: _controllerRemark.text,
                                      type: 1,
                                    );
                                    Get.back();
                                    break;
                                  case InOutType.payOut:
                                    RestApi.payInOut(
                                      value: _typeInputCash == 1 ? double.parse(_controllerManual.text) : moneyCount,
                                      remark: _controllerRemark.text,
                                      type: 2,
                                    );
                                    Get.back();
                                    break;
                                  case InOutType.cashIn:
                                    break;
                                  case InOutType.cashOut:
                                    break;
                                }
                              } else {
                                Fluttertoast.showToast(msg: 'The value must be greater than zero'.tr);
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
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  _showRefundDialog() {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerVoucherNumber = TextEditingController();
    CartModel? _refundModel;
    TextEditingController? _controllerSelectEdit;
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
                                  onChanged: (value) {
                                    _refundModel = null;
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
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
                                child: Text(
                                  '${mySharedPreferences.posNo}',
                                  style: kStyleTextDefault,
                                ),
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
                                child: Text(
                                  _refundModel == null ? '' : DateFormat('yyyy-MM-dd').format(DateTime.parse(_refundModel!.invDate)),
                                  style: kStyleTextDefault,
                                ),
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
                                child: Text(
                                  _refundModel == null ? '' : DateFormat('hh:mm:ss a').format(DateTime.parse(_refundModel!.invDate)),
                                  style: kStyleTextDefault,
                                ),
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
                                child: Text(
                                  '',
                                  style: kStyleTextDefault,
                                ),
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
                                child: Text(
                                  '',
                                  style: kStyleTextDefault,
                                ),
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
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _refundModel = await RestApi.getRefundInvoice(invNo: int.parse(_controllerVoucherNumber.text));
                        _refundModel = calculateOrder(cart: _refundModel!, orderType: _refundModel!.orderType, invoiceKind: InvoiceKind.invoiceReturn);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(),
                borderRadius: BorderRadius.circular(3.r),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Serial'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Text(
                            'Item'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Qty'.tr,
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
                          flex: 2,
                          child: Text(
                            'R.Qty'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'R.Total'.tr,
                            style: kStyleHeaderTable,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black, height: 1),
                  if (_refundModel != null)
                    ListView.separated(
                      itemCount: _refundModel!.items.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => _refundModel!.items[index].parentUuid.isNotEmpty ? Container() : const Divider(color: Colors.black, height: 1),
                      itemBuilder: (context, index) {
                        if (_refundModel!.items[index].parentUuid.isNotEmpty) {
                          return Container();
                        } else {
                          var subItem = _refundModel!.items.where((element) => element.parentUuid.isNotEmpty && element.parentUuid == _refundModel!.items[index].uuid).toList();
                          return Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${_refundModel!.items[index].id}',
                                        style: kStyleDataTable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Text(
                                        _refundModel!.items[index].name,
                                        style: kStyleDataTable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${_refundModel!.items[index].qty}',
                                        style: kStyleDataTable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (_refundModel!.items[index].returnedPrice + subItem.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedPrice)).toStringAsFixed(3),
                                        style: kStyleDataTable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: InkWell(
                                        onTap: () async {
                                          _refundModel!.items[index].returnedQty = await _showQtyDialog(rQty: _refundModel!.items[index].returnedQty, maxQty: _refundModel!.items[index].qty);
                                          for (var element in subItem) {
                                            element.returnedQty = _refundModel!.items[index].returnedQty;
                                          }
                                          _refundModel = calculateOrder(cart: _refundModel!, orderType: _refundModel!.orderType, invoiceKind: InvoiceKind.invoiceReturn);
                                          setState(() {});
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${_refundModel!.items[index].returnedQty}',
                                              style: kStyleDataTable,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(width: 10),
                                            const Icon(Icons.edit),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        (_refundModel!.items[index].returnedTotal + subItem.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedTotal)).toStringAsFixed(3),
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
                                    if (subItem.isNotEmpty)
                                      ListView.builder(
                                        itemCount: subItem.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, indexSubItem) {
                                          return Row(
                                            children: [
                                              Expanded(child: Container()),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  subItem[indexSubItem].name,
                                                  style: kStyleDataTableModifiers,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Expanded(child: Container()),
                                              Expanded(child: Container()),
                                              Expanded(flex: 2, child: Container()),
                                              Expanded(child: Container()),
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
            ),
            // Padding(
            //   padding: EdgeInsets.symmetric(vertical: 4.h),
            //   child: CustomDataTable(
            //     minWidth: constraints.minWidth,
            //     rows: _refundModel == null
            //         ? []
            //         : _refundModel!.items.where((element) => element.parentUuid.isEmpty).map(
            //             (e) {
            //               var subItem = _refundModel!.items.where((element) => element.parentUuid == e.uuid).toList();
            //               return DataRow(
            //                 cells: [
            //                   DataCell(Text('${e.id}')),
            //                   DataCell(Column(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       Text(e.name),
            //                       if (subItem.isNotEmpty)
            //                         ...subItem.map(
            //                           (e) => Text(
            //                             e.name,
            //                             style: kStyleDataTableModifiers,
            //                             textAlign: TextAlign.center,
            //                             maxLines: 1,
            //                             overflow: TextOverflow.ellipsis,
            //                           ),
            //                         ),
            //                     ],
            //                   )),
            //                   DataCell(Text('${e.qty}')),
            //                   DataCell(Text((e.returnedPrice + subItem.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedPrice)).toStringAsFixed(3))),
            //                   DataCell(
            //                     Text('${e.returnedQty}'),
            //                     showEditIcon: true,
            //                     onTap: () async {
            //                       e.returnedQty = await _showQtyDialog(rQty: e.returnedQty, maxQty: e.qty);
            //                       for (var element in subItem) {
            //                         element.returnedQty = e.returnedQty;
            //                       }
            //                       _refundModel = calculateOrder(cart: _refundModel!, orderType: _refundModel!.orderType, invoiceKind: InvoiceKind.invoiceReturn);
            //                       setState(() {});
            //                     },
            //                   ),
            //                   DataCell(Text((e.returnedTotal + subItem.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedTotal)).toStringAsFixed(3))),
            //                 ],
            //               );
            //             },
            //           ).toList(),
            //     columns: [
            //       DataColumn(label: Text('Serial'.tr)),
            //       DataColumn(label: Text('Item'.tr)),
            //       DataColumn(label: Text('Qty'.tr)),
            //       DataColumn(label: Text('Price'.tr)),
            //       DataColumn(label: Text('R.Qty'.tr)),
            //       DataColumn(label: Text('R.Total'.tr)),
            //     ],
            //   ),
            // ),
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
                          '${'Return Total'.tr} : ',
                          textAlign: TextAlign.end,
                          style: kStyleTextTitle,
                        ),
                      ],
                    ),
                    if (_refundModel != null)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _refundModel!.items.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedTotal).toStringAsFixed(3),
                            style: kStyleTextTitle,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 50.w),
                Expanded(
                  child: CustomButton(
                    fixed: true,
                    backgroundColor: ColorsApp.red,
                    child: Text(
                      'Exit'.tr,
                      style: kStyleTextButton,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: CustomButton(
                    fixed: true,
                    backgroundColor: ColorsApp.green,
                    child: Text(
                      'Ok'.tr,
                      style: kStyleTextButton,
                    ),
                    onPressed: _refundModel == null
                        ? null
                        : () async {
                            var result = await showAreYouSureDialog(title: 'Refund'.tr);
                            if (result) {
                              if (_refundModel!.items.any((element) => element.returnedQty > 0)) {
                                _refundModel!.items.removeWhere((element) => element.returnedQty == 0);
                                RestApi.invoice(cart: _refundModel!, invoiceKind: InvoiceKind.invoiceReturn);
                                RestApi.returnInvoiceQty(invNo: int.parse(_controllerVoucherNumber.text), refundModel: _refundModel!);
                                Get.back();
                              }
                            }
                          },
                  ),
                ),
                SizedBox(width: 50.w),
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

  _calculateRefundOrder() {}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                              const SizedBox(width: 20),
                              CachedNetworkImage(
                                imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'COMPANY_LOGO')?.imgPath ?? ''}${allDataModel.companyConfig.first.companyLogo}',
                                fit: BoxFit.contain,
                                placeholder: (context, url) => Container(),
                                errorWidget: (context, url, error) => Container(),
                              ),
                              Expanded(
                                child: Text(
                                  '${'Branch'.tr}: ${allDataModel.companyConfig.first.companyName}',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: kStyleTextDefault,
                                ),
                              ),
                              const VerticalDivider(),
                              Expanded(
                                child: Text(
                                  DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: kStyleTextDefault,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => OrderScreen(type: OrderType.takeAway));
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/take_away.png',
                                      height: 150.h,
                                    ),
                                    Text(
                                      'Take Away'.tr,
                                      style: kStyleTextTitle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() => TableScreen());
                                },
                                child: Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/dine_in.png',
                                      height: 150.h,
                                    ),
                                    Text(
                                      'Dine In'.tr,
                                      style: kStyleTextTitle,
                                    ),
                                  ],
                                ),
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
      ),
    );
  }
}
