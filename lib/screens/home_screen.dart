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
import 'package:restaurant_system/models/end_cash_model.dart';
import 'package:restaurant_system/models/printer_image_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/printer.dart';
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
import 'package:screenshot/screenshot.dart';

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
        // if (mySharedPreferences.employee.hasCashInOutPermission)
          HomeMenu(
            name: 'Pay In'.tr,
            onTab: () {
              //if (mySharedPreferences.employee.hasCashInOutPermission) {
                _showInOutDialog(type: InOutType.payIn);
              // } else {
              //   showLoginDialog();
              // }
            },
          ),
        if (mySharedPreferences.employee.hasCashInOutPermission)
          HomeMenu(
            name: 'Pay Out'.tr,
            onTab: () {
              _showInOutDialog(type: InOutType.payOut);
            },
          ),
        HomeMenu(
          name: 'End Cash'.tr,
          onTab: () async {
            EndCashModel? model = await RestApi.getEndCash();
            if (model != null) {
              _showEndCashDialog(endCash: model);
            }
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
          name: 'Reprint Invoice'.tr,
          onTab: () {
            _showReprintInvoiceDialog();
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
                  if(mySharedPreferences.park.isNotEmpty){
                    Fluttertoast.showToast(msg: 'Daily closing cannot be done due to order park'.tr);
                  } else {
                    await RestApi.posDailyClose(closeDate: mySharedPreferences.dailyClose.add(const Duration(days: 1)));
                    setState(() {});
                  }

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

  _showInOutDialog({required InOutType type}) async {
    var indexPrinter = allDataModel.printers.indexWhere((element) => element.cashNo == mySharedPreferences.cashNo);
    PrinterImageModel? _printer;
    if (indexPrinter != -1) {
      _printer = PrinterImageModel(ipAddress: allDataModel.printers[indexPrinter].ipAddress, port: allDataModel.printers[indexPrinter].port);
    }

    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerManual = TextEditingController(text: '0');
    TextEditingController _controllerRemark = TextEditingController();
    TextEditingController? _controllerSelectEdit = _controllerManual;
    int _typeInputCash = 1;
    double moneyCount = 0;

    bool result = await Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {
          _controllerSelectEdit = null;
        },
        builder: (context, setState, constraints) {
          moneyCount = MoneyCount.moneyCount.fold(0.0, (previousValue, element) => (previousValue) + ((element.value * element.rate) * double.parse(element.qty.text)));
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
                              Get.back(result: false);
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
                                    break;
                                  case InOutType.payOut:
                                    RestApi.payInOut(
                                      value: _typeInputCash == 1 ? double.parse(_controllerManual.text) : moneyCount,
                                      remark: _controllerRemark.text,
                                      type: 2,
                                    );
                                    break;
                                  case InOutType.cashIn:
                                    break;
                                  case InOutType.cashOut:
                                    break;
                                }
                                Get.back(result: true);
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

    if (_printer != null && result) {
      ScreenshotController _screenshotController = ScreenshotController();

      Future.delayed(const Duration(milliseconds: 100)).then((value) async {
        var screenshot = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
        _printer!.image = screenshot;
        await Printer.payInOut(printerImageModel: _printer);
      });

      await Get.dialog(
        CustomDialog(
          width: 150.w,
          builder: (context, setState, constraints) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomButton(
                      fixed: true,
                      child: Text('Print'.tr),
                      onPressed: () async {
                        await Printer.payInOut(printerImageModel: _printer!);
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
                  controller: _screenshotController,
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
                                type == InOutType.payIn
                                    ? 'Pay In'.tr
                                    : type == InOutType.payOut
                                        ? 'Pay Out'.tr
                                        : type == InOutType.cashIn
                                            ? 'Cash In'
                                            : type == InOutType.cashOut
                                                ? 'Cash Out'
                                                : '',
                                style: kStyleLargePrinter,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.black, thickness: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${'Value'.tr} : ${_typeInputCash == 1 ? double.parse(_controllerManual.text).toStringAsFixed(3) : moneyCount.toStringAsFixed(3)}',
                                    style: kStyleDataPrinter,
                                  ),
                                  Text(
                                    '${'Remark'.tr} : ${_controllerRemark.text}',
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
                          ],
                        ),
                        const Divider(color: Colors.black, thickness: 2),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  _showEndCashDialog({required EndCashModel endCash}) async {
    var indexPrinter = allDataModel.printers.indexWhere((element) => element.cashNo == mySharedPreferences.cashNo);
    PrinterImageModel? _printer;
    if (indexPrinter != -1) {
      _printer = PrinterImageModel(ipAddress: allDataModel.printers[indexPrinter].ipAddress, port: allDataModel.printers[indexPrinter].port);
    }

    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerTotalCash = TextEditingController(text: '0');
    TextEditingController _controllerTotalCreditCard = TextEditingController(text: '0');
    TextEditingController _controllerTotalCredit = TextEditingController(text: '0');
    TextEditingController _controllerNetTotal = TextEditingController(text: '0');
    TextEditingController? _controllerSelectEdit = _controllerTotalCash;

    var result = await Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {
          _controllerSelectEdit = null;
        },
        builder: (context, setState, constraints) {
          double netTotal = double.parse(_controllerTotalCash.text) + double.parse(_controllerTotalCreditCard.text) + double.parse(_controllerTotalCredit.text);
          _controllerNetTotal.text = netTotal.toStringAsFixed(3);
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
                    'End Cash'.tr,
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
                          CustomTextField(
                            controller: _controllerTotalCash,
                            label: Text('Total Cash'.tr),
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
                              _controllerSelectEdit = _controllerTotalCash;
                              setState(() {});
                            },
                          ),
                          CustomTextField(
                            controller: _controllerTotalCreditCard,
                            label: Text('Total Credit Card'.tr),
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
                              _controllerSelectEdit = _controllerTotalCreditCard;
                              setState(() {});
                            },
                          ),
                          // CustomTextField(
                          //   controller: _controllerTotalCredit,
                          //   label: Text('Total Credit'.tr),
                          //   fillColor: Colors.white,
                          //   maxLines: 1,
                          //   inputFormatters: [
                          //     EnglishDigitsTextInputFormatter(decimal: true),
                          //   ],
                          //   validator: (value) {
                          //     return Validation.isRequired(value);
                          //   },
                          //   enableInteractiveSelection: false,
                          //   keyboardType: const TextInputType.numberWithOptions(),
                          //   onTap: () {
                          //     FocusScope.of(context).requestFocus(FocusNode());
                          //     _controllerSelectEdit = _controllerTotalCredit;
                          //     setState(() {});
                          //   },
                          // ),
                          CustomTextField(
                            controller: _controllerNetTotal,
                            label: Text('Net Total'.tr),
                            fillColor: Colors.white,
                            maxLines: 1,
                            readOnly: true,
                            enabled: false,
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
                              var resultEndCash = await RestApi.endCash(
                                totalCash: double.parse(_controllerTotalCash.text),
                                totalCreditCard: double.parse(_controllerTotalCreditCard.text),
                                totalCredit: double.parse(_controllerTotalCredit.text),
                                netTotal: double.parse(_controllerNetTotal.text),
                              );
                              if (resultEndCash) {
                                Get.back(result: true);
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

    if (result != null && result && _printer != null) {
      ScreenshotController _screenshotController = ScreenshotController();

      Future.delayed(const Duration(milliseconds: 100)).then((value) async {
        var screenshot = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
        _printer!.image = screenshot;
        await Printer.payInOut(printerImageModel: _printer);
      });

      await Get.dialog(
        CustomDialog(
          width: 150.w,
          builder: (context, setState, constraints) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomButton(
                      fixed: true,
                      child: Text('Print'.tr),
                      onPressed: () async {
                        await Printer.payInOut(printerImageModel: _printer!);
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
                  controller: _screenshotController,
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
                                'End Cash'.tr,
                                style: kStyleLargePrinter,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Divider(color: Colors.black, thickness: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      'Total Cash'.tr,
                                      style: kStyleTitlePrinter,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Input'.tr} : ${double.parse(_controllerTotalCash.text).toStringAsFixed(3)}',
                                        style: kStyleDataPrinter,
                                      ),
                                      Text(
                                        '${'Actual Value'.tr} : ${endCash.totalCash.toStringAsFixed(3)}',
                                        style: kStyleDataPrinter,
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${'Different'.tr} : ${(double.parse(_controllerTotalCash.text) - double.parse(endCash.totalCash.toString())).toStringAsFixed(3)}',
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.black, thickness: 2),
                                  Center(
                                    child: Text(
                                      'Total Credit Card'.tr,
                                      style: kStyleTitlePrinter,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Input'.tr} : ${double.parse(_controllerTotalCreditCard.text).toStringAsFixed(3)}',
                                        style: kStyleDataPrinter,
                                      ),
                                      Text(
                                        '${'Actual Value'.tr} : ${endCash.totalCreditCard.toStringAsFixed(3)}',
                                        style: kStyleDataPrinter,
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${'Different'.tr} : ${double.parse(double.parse(_controllerTotalCreditCard.text).toStringAsFixed(3)) - double.parse(endCash.totalCreditCard.toStringAsFixed(3))}',
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.black, thickness: 2),
                                  Center(
                                    child: Text(
                                      'Net Total'.tr,
                                      style: kStyleTitlePrinter,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Input'.tr} : ${double.parse(_controllerNetTotal.text).toStringAsFixed(3)}',
                                        style: kStyleDataPrinter,
                                      ),
                                      Text(
                                        '${'Actual Value'.tr} : ${endCash.netTotal.toStringAsFixed(3)}',
                                        style: kStyleDataPrinter,
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${'Different'.tr} : ${double.parse(double.parse(_controllerNetTotal.text).toStringAsFixed(3)) - double.parse(endCash.netTotal.toStringAsFixed(3))}',
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.black, thickness: 2),
                                  Text(
                                    '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose)}',
                                    style: kStyleDataPrinter,
                                  ),
                                  Text(
                                    '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                    style: kStyleDataPrinter,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.black, thickness: 2),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  _showReprintInvoiceDialog() async {
    var indexPrinter = allDataModel.printers.indexWhere((element) => element.cashNo == mySharedPreferences.cashNo);
    PrinterImageModel? _printer;
    if (indexPrinter != -1) {
      _printer = PrinterImageModel(ipAddress: allDataModel.printers[indexPrinter].ipAddress, port: allDataModel.printers[indexPrinter].port);
    }
    TextEditingController _controllerVoucherNumber = TextEditingController();
    CartModel? _reprintModel;
    bool result = await Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {},
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
                                    _reprintModel = null;
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
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
                                  _reprintModel == null ? '' : DateFormat('yyyy-MM-dd').format(DateTime.parse(_reprintModel!.invDate)),
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
                                  _reprintModel == null ? '' : DateFormat('hh:mm:ss a').format(DateTime.parse(_reprintModel!.invDate)),
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
                        _reprintModel = await RestApi.getInvoice(invNo: int.parse(_controllerVoucherNumber.text));
                        _reprintModel = calculateOrder(cart: _reprintModel!, orderType: _reprintModel!.orderType, invoiceKind: InvoiceKind.invoicePay);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
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
                      Get.back(result: false);
                    },
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  child: CustomButton(
                    fixed: true,
                    backgroundColor: ColorsApp.green,
                    child: Text(
                      'Print'.tr,
                      style: kStyleTextButton,
                    ),
                    onPressed: _reprintModel == null
                        ? null
                        : () async {
                            Get.back(result: true);
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
    if (_printer != null && result) {
      ScreenshotController _screenshotController = ScreenshotController();

      Future.delayed(const Duration(milliseconds: 100)).then((value) async {
        var screenshot = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
        _printer!.image = screenshot;
        await Printer.payInOut(printerImageModel: _printer);
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
                    fixed: true,
                    child: Text('Print'.tr),
                    onPressed: () async {
                      await Printer.payInOut(printerImageModel: _printer!);
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
                controller: _screenshotController,
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
                              'Reprint'.tr,
                              style: kStyleLargePrinter,
                            ),
                            Text(
                              _reprintModel!.orderType == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
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
                                if (_reprintModel!.orderType == OrderType.dineIn)
                                  Text(
                                    '${'Table No'.tr} : ${_reprintModel!.tableId}',
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
                            itemCount: _reprintModel!.items.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
                            itemBuilder: (context, index) {
                              if (_reprintModel!.items[index].parentUuid.isNotEmpty) {
                                return Container();
                              } else {
                                var subItem = _reprintModel!.items.where((element) => element.parentUuid == _reprintModel!.items[index].uuid).toList();
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              _reprintModel!.items[index].name,
                                              style: kStyleDataPrinter,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              '${_reprintModel!.items[index].qty}',
                                              style: kStyleDataPrinter,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              _reprintModel!.items[index].total.toStringAsFixed(3),
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
                                            itemCount: _reprintModel!.items[index].questions.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, indexQuestions) => Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '- ${_reprintModel!.items[index].questions[indexQuestions].question.trim()}',
                                                        style: kStyleDataPrinter,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                ListView.builder(
                                                  itemCount: _reprintModel!.items[index].questions[indexQuestions].modifiers.length,
                                                  shrinkWrap: true,
                                                  physics: const NeverScrollableScrollPhysics(),
                                                  itemBuilder: (context, indexModifiers) => Column(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '  • ${_reprintModel!.items[index].questions[indexQuestions].modifiers[indexModifiers]}',
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
                                            itemCount: _reprintModel!.items[index].modifiers.length,
                                            shrinkWrap: true,
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, indexModifiers) => Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '• ${_reprintModel!.items[index].modifiers[indexModifiers].name} * ${_reprintModel!.items[index].modifiers[indexModifiers].modifier}',
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
                                  _reprintModel!.total.toStringAsFixed(3),
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
                                  _reprintModel!.totalDiscount.toStringAsFixed(3),
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
                                  _reprintModel!.totalLineDiscount.toStringAsFixed(3),
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
                                  _reprintModel!.deliveryCharge.toStringAsFixed(3),
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
                                  _reprintModel!.service.toStringAsFixed(3),
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
                                  _reprintModel!.tax.toStringAsFixed(3),
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
                                  _reprintModel!.amountDue.toStringAsFixed(3),
                                  style: kStyleTitlePrinter.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.black, thickness: 2),
                            if (_reprintModel!.cash != 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Cash'.tr,
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    _reprintModel!.cash.toStringAsFixed(3),
                                    style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            if (_reprintModel!.credit != 0)
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Credit'.tr,
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    _reprintModel!.credit.toStringAsFixed(3),
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

  Future<double> _showQtyDialog({TextEditingController? controller, double? maxQty, double minQty = 0, required double rQty}) async {
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
                            EnglishDigitsTextInputFormatter(decimal: true),
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
    return double.parse(qty);
  }

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
