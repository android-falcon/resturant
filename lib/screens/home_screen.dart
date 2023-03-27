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
import 'package:restaurant_system/utils/assets.dart';
import 'package:restaurant_system/models/all_data/employee_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/end_cash_model.dart';
import 'package:restaurant_system/models/printer_image_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/printer.dart';
import 'package:restaurant_system/screens/history_pay_in_out_screen.dart';
import 'package:restaurant_system/screens/order_screen.dart';
import 'package:restaurant_system/screens/reports_screen.dart';
import 'package:restaurant_system/screens/sorting_categories_screen.dart';
import 'package:restaurant_system/screens/table_screen.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_drawer.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field_num.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/app_config/money_count.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';
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
        HomeMenu(
          name: 'Pay In'.tr,
          icon: Icon(Icons.money, color: ColorsApp.gray),
          onTab: () async {
            if (mySharedPreferences.employee.hasCashInOutPermission) {
              _showInOutDialog(type: InOutType.payIn);
            } else {
              EmployeeModel? employee = await Utils.showLoginDialog();
              if (employee != null) {
                if (employee.hasCashInOutPermission) {
                  _showInOutDialog(type: InOutType.payIn);
                } else {
                  Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                }
              }
            }
          },
        ),
        HomeMenu(
          name: 'Pay Out'.tr,
          icon: const Icon(Icons.monetization_on_outlined, color: ColorsApp.gray),
          onTab: () async {
            if (mySharedPreferences.employee.hasCashInOutPermission) {
              _showInOutDialog(type: InOutType.payOut);
            } else {
              EmployeeModel? employee = await Utils.showLoginDialog();
              if (employee != null) {
                if (employee.hasCashInOutPermission) {
                  _showInOutDialog(type: InOutType.payOut);
                } else {
                  Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                }
              }
            }
          },
        ),
        HomeMenu(
          name: 'History Pay In / Out'.tr,
          icon: const Icon(Icons.history, color: ColorsApp.gray),
          onTab: () async {
            Get.to(() => const HistoryPayInOutScreen());
          },
        ),
        HomeMenu(
          name: 'End Cash'.tr,
          icon: const Icon(Icons.pin_end_rounded, color: ColorsApp.gray),
          onTab: () async {
            if (mySharedPreferences.employee.hasSeeEndCashPermission) {
              EndCashModel? model = await RestApi.getEndCash();
              if (model != null) {
                _showEndCashDialog(endCash: model);
              }
            } else {
              EmployeeModel? employee = await Utils.showLoginDialog();
              if (employee != null) {
                if (employee.hasSeeEndCashPermission) {
                  EndCashModel? model = await RestApi.getEndCash();
                  if (model != null) {
                    _showEndCashDialog(endCash: model);
                  }
                } else {
                  Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                }
              }
            }
          },
        ),
        HomeMenu(
          name: 'Refund'.tr,
          icon: const Icon(Icons.receipt_long, color: ColorsApp.gray),
          onTab: () async {
            if (mySharedPreferences.employee.hasRefundPermission) {
              _showRefundDialog();
            } else {
              EmployeeModel? employee = await Utils.showLoginDialog();
              if (employee != null) {
                if (employee.hasRefundPermission) {
                  _showRefundDialog();
                } else {
                  Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                }
              }
            }
          },
        ),
        HomeMenu(
          name: 'Reprint Invoice'.tr,
          icon: const Icon(Icons.print, color: ColorsApp.gray),
          onTab: () {
            _showReprintInvoiceDialog();
          },
        ),
        HomeMenu(
          name: 'Cash Drawer'.tr,
          icon: const Icon(Icons.cable_sharp, color: ColorsApp.gray),
          onTab: () async {
            var indexPrinter = allDataModel.printers.indexWhere((element) => element.cashNo == mySharedPreferences.cashNo);
            if (indexPrinter != -1) {
              Printer.openCash(allDataModel.printers[indexPrinter].ipAddress, allDataModel.printers[indexPrinter].port);
            }
          },
        ),
        HomeMenu(
          name: 'Daily Close'.tr,
          icon: const Icon(Icons.checklist_rtl, color: ColorsApp.gray),
          onTab: () async {
            if (mySharedPreferences.employee.isMaster) {
              _showDailyCloseDialog();
            } else {
              EmployeeModel? employee = await Utils.showLoginDialog();
              if (employee != null) {
                if (employee.isMaster) {
                  _showDailyCloseDialog();
                } else {
                  Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                }
              }
            }
          },
        ),
        HomeMenu(
          name: 'Rest Order No'.tr,
          icon: const Icon(Icons.clear, color: ColorsApp.gray),
          onTab: () async {
            var result = await Utils.showAreYouSureDialog(title: 'Rest Order No'.tr);
            if (result) {
              RestApi.resetPOSOrderNo();
              mySharedPreferences.orderNo = 1;
            }
          },
        ),
        HomeMenu(
          name: 'Reports'.tr,
          icon: const Icon(Icons.analytics_rounded, color: ColorsApp.gray),
          onTab: () async {
            if (mySharedPreferences.employee.hasReportsPermission) {
              Get.to(() => const ReportsScreen());
            } else {
              EmployeeModel? employee = await Utils.showLoginDialog();
              if (employee != null) {
                if (employee.hasReportsPermission) {
                  Get.to(() => const ReportsScreen());
                } else {
                  Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                }
              }
            }
          },
        ),
        HomeMenu(
          name: 'Sorting'.tr,
          icon: const Icon(Icons.sort_rounded, color: ColorsApp.gray),
          onTab: () async {
            Get.to(() => const SortingCategoriesScreen());
          },
        ),
        HomeMenu(
          name: 'Refresh Data'.tr,
          icon: const Icon(Icons.refresh, color: ColorsApp.gray),
          onTab: () async {
            RestApi.getData();
            RestApi.getCashLastSerials();
          },
        ),
        HomeMenu(
          name: 'Exit'.tr,
          icon: const Icon(Icons.logout_outlined, color: ColorsApp.gray),
          onTab: () async {
            var result = await Utils.showAreYouSureDialog(title: 'Close App'.tr);
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
    loadImageCompany();
  }

  loadImageCompany() async {
    try {
      Assets.kAssetsCompanyLogo = [];
      String imageUrl =
          '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'COMPANY_LOGO')?.imgPath ?? ''}${allDataModel.companyConfig.first.companyLogo}';
      Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl)).buffer.asUint8List();
      Assets.kAssetsCompanyLogo = bytes.toList();
    } catch (e) {}
  }

  Future<int?> _showCashInOutTypeDialog({required InOutType kindType}) async {
    int kind = 0;
    if (kindType == InOutType.payIn) {
      kind = 0;
    } else if (kindType == InOutType.payOut) {
      kind = 1;
    }
    int? _selectedTypeId;
    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: CustomDialog(
          builder: (context, setState, constraints) => Column(
            children: [
              Text(
                'Cash In / Out Types'.tr,
                style: kStyleTextTitle,
              ),
              const Divider(thickness: 2),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allDataModel.cashInOutTypesModel.length,
                itemBuilder: (context, index) => kind != allDataModel.cashInOutTypesModel[index].kind
                    ? Container()
                    : RadioListTile(
                        title: Text(
                          allDataModel.cashInOutTypesModel[index].description,
                          style: kStyleForceQuestion,
                        ),
                        value: allDataModel.cashInOutTypesModel[index].id,
                        groupValue: _selectedTypeId,
                        onChanged: (value) {
                          _selectedTypeId = value as int;
                          setState(() {});
                        },
                      ),
              ),
              Row(
                children: [
                  Expanded(child: Container()),
                  Expanded(
                    child: CustomButton(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Cancel'.tr),
                      backgroundColor: ColorsApp.primaryColor,
                      onPressed: () {
                        _selectedTypeId = null;
                        Get.back();
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Save'.tr),
                      backgroundColor: ColorsApp.primaryColor,
                      onPressed: () {
                        if (_selectedTypeId == null) {
                          Fluttertoast.showToast(msg: 'Please select cash In / Out Type'.tr);
                        } else {
                          Get.back();
                        }
                      },
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    return _selectedTypeId;
  }

  _showDailyCloseDialog() {
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
        if (mySharedPreferences.park.isNotEmpty) {
          Fluttertoast.showToast(msg: 'Daily closing cannot be done due to order park'.tr);
        } else {
          await RestApi.posDailyClose(closeDate: mySharedPreferences.dailyClose.add(const Duration(days: 1)));
          setState(() {});
        }
      },
    );
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
                      child: Utils.numPadWidget(
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
    int? _selectDescId;

    bool result = await Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {
          _controllerSelectEdit = null;
        },
        builder: (context, setState, constraints) {
          moneyCount =
              MoneyCount.moneyCount.fold(0.0, (previousValue, element) => (previousValue) + ((element.value * element.rate) * double.parse(element.qty.text)));
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
                                                    imageUrl:
                                                        '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Currencies')?.imgPath ?? ''}${MoneyCount.moneyCount[index].icon}',
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
                                            fillColor:
                                                _controllerSelectEdit == MoneyCount.moneyCount[index].qty ? ColorsApp.primaryColor.withOpacity(0.2) : null,
                                            onTap: () {
                                              FocusScope.of(context).requestFocus(FocusNode());
                                              _controllerSelectEdit = MoneyCount.moneyCount[index].qty;
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            ((MoneyCount.moneyCount[index].value * MoneyCount.moneyCount[index].rate) *
                                                    double.parse(MoneyCount.moneyCount[index].qty.text))
                                                .toStringAsFixed(3),
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
                        child: Utils.numPadWidget(
                          _controllerSelectEdit,
                          setState,
                          onExit: () async {
                            var result = await Utils.showAreYouSureDialog(title: 'Exit'.tr);
                            if (result) {
                              Get.back(result: false);
                            }
                          },
                          onSubmit: () async {
                            // var result = await Utils.showAreYouSureDialog(title: 'Save'.tr);
                            _selectDescId = await _showCashInOutTypeDialog(kindType: type);
                            if (_selectDescId != null) {
                              if (_typeInputCash == 1 ? double.parse(_controllerManual.text) > 0 : moneyCount > 0) {
                                switch (type) {
                                  case InOutType.payIn:
                                    RestApi.payInOut(
                                      value: _typeInputCash == 1 ? double.parse(_controllerManual.text) : moneyCount,
                                      remark: _controllerRemark.text,
                                      type: 1,
                                      descId: _selectDescId!,
                                    );
                                    break;
                                  case InOutType.payOut:
                                    RestApi.payInOut(
                                      value: _typeInputCash == 1 ? double.parse(_controllerManual.text) : moneyCount,
                                      remark: _controllerRemark.text,
                                      type: 2,
                                      descId: _selectDescId!,
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
          width: mySharedPreferences.printerWidth.toDouble(),
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
                    width: mySharedPreferences.printerWidth.toDouble(),
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
                                style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
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
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                  Text(
                                    '${'Remark'.tr} : ${_controllerRemark.text}',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                  Text(
                                    '${'Type'.tr} : ${_selectDescId == null ? '' : allDataModel.cashInOutTypesModel.firstWhereOrNull((element) => element.id == _selectDescId)?.description ?? ''}',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                  Text(
                                    '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose)}',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                  Text(
                                    '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
                        child: Utils.numPadWidget(
                          _controllerSelectEdit,
                          setState,
                          onExit: () async {
                            var result = await Utils.showAreYouSureDialog(title: 'Exit'.tr);
                            if (result) {
                              Get.back();
                            }
                          },
                          onSubmit: () async {
                            var result = await Utils.showAreYouSureDialog(title: 'Save'.tr);
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
          width: mySharedPreferences.printerWidth.toDouble(),
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
                    width: mySharedPreferences.printerWidth.toDouble(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'End Cash'.tr,
                                style: kStyleLargePrinter.copyWith(fontSize: mySharedPreferences.sizeLargePrinter.toDouble()),
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
                                      style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Input'.tr} : ${double.parse(_controllerTotalCash.text).toStringAsFixed(3)}',
                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                      ),
                                      Text(
                                        '${'Actual Value'.tr} : ${endCash.totalCash.toStringAsFixed(3)}',
                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${'Different'.tr} : ${(double.parse(_controllerTotalCash.text) - double.parse(endCash.totalCash.toString())).toStringAsFixed(3)}',
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.black, thickness: 2),
                                  Center(
                                    child: Text(
                                      'Total Credit Card'.tr,
                                      style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Input'.tr} : ${double.parse(_controllerTotalCreditCard.text).toStringAsFixed(3)}',
                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                      ),
                                      Text(
                                        '${'Actual Value'.tr} : ${endCash.totalCreditCard.toStringAsFixed(3)}',
                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${'Different'.tr} : ${double.parse(double.parse(_controllerTotalCreditCard.text).toStringAsFixed(3)) - double.parse(endCash.totalCreditCard.toStringAsFixed(3))}',
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.black, thickness: 2),
                                  Center(
                                    child: Text(
                                      'Net Total'.tr,
                                      style: kStyleTitlePrinter.copyWith(fontSize: mySharedPreferences.sizeTitlePrinter.toDouble()),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${'Input'.tr} : ${double.parse(_controllerNetTotal.text).toStringAsFixed(3)}',
                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                      ),
                                      Text(
                                        '${'Actual Value'.tr} : ${endCash.netTotal.toStringAsFixed(3)}',
                                        style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Text(
                                      '${'Different'.tr} : ${double.parse(double.parse(_controllerNetTotal.text).toStringAsFixed(3)) - double.parse(endCash.netTotal.toStringAsFixed(3))}',
                                      style: kStyleDataPrinter.copyWith(fontWeight: FontWeight.bold, fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Divider(color: Colors.black, thickness: 2),
                                  Text(
                                    '${'Date'.tr} : ${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose)}',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
                                  ),
                                  Text(
                                    '${'Time'.tr} : ${DateFormat('HH:mm:ss a').format(DateTime.now())}',
                                    style: kStyleDataPrinter.copyWith(fontSize: mySharedPreferences.sizeDataPrinter.toDouble()),
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
    TextEditingController _controllerVoucherNumber = TextEditingController();
    CartModel? _reprintModel;
    bool result = await Get.dialog(
      CustomDialog(
        height: 400.h,
        width: 250.w,
        gestureDetectorOnTap: () {},
        builder: (context, setState, constraints) => Column(
          children: [
            Text(
              'Reprint Invoice'.tr,
              textAlign: TextAlign.end,
              style: kStyleTextTitle.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'Voucher Number'.tr} : ',
                    textAlign: TextAlign.center,
                    style: kStyleTextDefault,
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
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
                      ),
                      SizedBox(width: 10.w),
                      CustomButton(
                        fixed: true,
                        child: Text('Show'.tr),
                        backgroundColor: ColorsApp.orange,
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _reprintModel = await RestApi.getInvoice(invNo: int.parse(_controllerVoucherNumber.text));
                          _reprintModel = Utils.calculateOrder(cart: _reprintModel!, orderType: _reprintModel!.orderType, invoiceKind: InvoiceKind.invoicePay);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'Original Data'.tr} : ',
                    textAlign: TextAlign.center,
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
            SizedBox(height: 30.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${'Original Time'.tr} : ',
                    textAlign: TextAlign.center,
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
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50.w,
                  height: 50.h,
                ),
                Expanded(
                  child: CustomButton(
                    fixed: true,
                    backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
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
    if (result) {
      await Printer.printInvoicesDialog(cart: _reprintModel!, reprint: true, kitchenPrinter: false, showOrderNo: false, invNo: '${_reprintModel!.invNo}');
    }
  }

  _showRefundDialog() {
    TextEditingController _controllerVoucherNumber = TextEditingController();
    CartModel? _refundModel;
    Get.dialog(
      CustomDialog(
        gestureDetectorOnTap: () {},
        builder: (context, setState, constraints) => Column(
          children: [
            Container(
              width: 1.sw,
              constraints: BoxConstraints(maxHeight: Get.height, maxWidth: Get.width),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.r),
                border: Border.all(width: 2, color: ColorsApp.primaryColor),
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
                        _refundModel = Utils.calculateOrder(cart: _refundModel!, orderType: _refundModel!.orderType, invoiceKind: InvoiceKind.invoiceReturn);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 250.h,
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
                      separatorBuilder: (context, index) =>
                          _refundModel!.items[index].parentUuid.isNotEmpty ? Container() : const Divider(color: Colors.black, height: 1),
                      itemBuilder: (context, index) {
                        if (_refundModel!.items[index].parentUuid.isNotEmpty) {
                          return Container();
                        } else {
                          var subItem = _refundModel!.items
                              .where((element) => element.parentUuid.isNotEmpty && element.parentUuid == _refundModel!.items[index].uuid)
                              .toList();
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
                                        (_refundModel!.items[index].returnedPrice +
                                                subItem.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedPrice))
                                            .toStringAsFixed(3),
                                        style: kStyleDataTable,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: InkWell(
                                        onTap: () async {
                                          _refundModel!.items[index].returnedQty = await _showQtyDialog(
                                              decimal: false, rQty: _refundModel!.items[index].returnedQty, maxQty: _refundModel!.items[index].qty);
                                          for (var element in subItem) {
                                            element.returnedQty = _refundModel!.items[index].returnedQty;
                                          }
                                          _refundModel = Utils.calculateOrder(
                                              cart: _refundModel!, orderType: _refundModel!.orderType, invoiceKind: InvoiceKind.invoiceReturn);
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
                                        (_refundModel!.items[index].returnedTotal +
                                                subItem.fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedTotal))
                                            .toStringAsFixed(3),
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
            //                       _refundModel = Utils.calculateOrder(cart: _refundModel!, orderType: _refundModel!.orderType, invoiceKind: InvoiceKind.invoiceReturn);
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
                    _refundModel == null
                        ? Container(
                            width: 100.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(3.r),
                            ))
                        : Container(
                            width: 100.w,
                            height: 30.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Center(
                                  child: Text(
                                    _refundModel!.items
                                        .fold(0.0, (previousValue, element) => (previousValue as double) + element.returnedTotal)
                                        .toStringAsFixed(3),
                                    style: kStyleTextTitle,
                                  ),
                                ),
                              ],
                            ),
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
                    backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
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
                            var result = await Utils.showAreYouSureDialog(title: 'Refund'.tr);
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

  Future<double> _showQtyDialog({TextEditingController? controller, double? maxQty, double minQty = 0, required double rQty, bool decimal = true}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '${decimal ? rQty : rQty.toInt()}');
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
                      child: Utils.numPadWidget(
                        controller,
                        setState,
                        decimal: decimal,
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
        appBar: AppBar(
          backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.backgroundDialog,
          iconTheme: IconThemeData(color: companyType == CompanyType.umniah ? ColorsApp.primaryColor : ColorsApp.black),
          title: Text(
            '${'Branch'.tr}: ${allDataModel.companyConfig.first.companyName}  \t\t\t${DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose)}',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: companyType == CompanyType.umniah ? kStyleTextButton : kStyleTextDefault,
          ),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.all(2.sp),
            child: CachedNetworkImage(
              imageUrl:
                  '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'COMPANY_LOGO')?.imgPath ?? ''}${allDataModel.companyConfig.first.companyLogo}',
            ),
          ),
        ),
        endDrawer: CustomDrawer(
          menu: _menu,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20.h),
                Row(
                  children: [
                    SizedBox(
                      width: 10.w,
                    ),
                    Image.asset(
                      Assets.kAssetsHomeScreen,
                      height: 250.h,
                      width: 170.w,
                    ),
                    Column(
                      children: [
                        Image.asset(
                          Assets.kAssetsChoose,
                          height: 40.h,
                          width: 100.w,
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.0),
                                onTap: () {
                                  Get.to(() => const OrderScreen(type: OrderType.takeAway));
                                },
                                child: Container(
                                  width: 70.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(color: ColorsApp.primaryColor),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        Assets.kAssetsTakeAway,
                                        height: 130.h,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Take Away'.tr,
                                          style: kStyleButtonPayment,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6.w),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.0),
                                onTap: () {
                                  Get.to(() => const TableScreen());
                                },
                                child: Container(
                                  width: 70.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15.0),
                                    border: Border.all(color: ColorsApp.primaryColor),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        Assets.kAssetsDineIn,
                                        height: 130.h,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                          'Dine In'.tr,
                                          style: kStyleButtonPayment,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
