import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/all_data/category_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/combo_items_force_question_model.dart';
import 'package:restaurant_system/models/all_data/employee_model.dart';
import 'package:restaurant_system/models/all_data/item_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/item_with_questions_model.dart';
import 'package:restaurant_system/models/all_data/void_reason_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:restaurant_system/models/printer_invoice_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/printer.dart';
import 'package:restaurant_system/screens/pay_screen.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_drawer.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/measure_size_widget.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';
import 'package:restaurant_system/utils/enums/enum_device_type.dart';
import 'package:restaurant_system/utils/enums/enum_discount_type.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:restaurant_system/utils/validation.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';

class OrderScreen extends StatefulWidget {
  final OrderType type;
  final DineInModel? dineIn;

  const OrderScreen({Key? key, required this.type, this.dineIn}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<HomeMenu> _menu = [];
  bool _dineInChangedOrder = false;
  bool _isShowItem = false;
  bool _isShowTotal = false;
  int _selectedCategoryId = 0;
  late CartModel _cartModel;
  int _indexItemSelect = -1;
  double maxHeightItem = 0;
  int indexTable = -1;

  @override
  initState() {
    super.initState();
    _menu = <HomeMenu>[
      if (widget.type == OrderType.takeAway)
        HomeMenu(
          name: 'Park List'.tr,
          icon: Icon(Icons.local_parking_outlined, color: ColorsApp.primaryColor),
          onTab: () async {
            if (_cartModel.items.isNotEmpty) {
              Fluttertoast.showToast(msg: 'The cart must be emptied, in order to be able to get park'.tr);
            } else {
              var result = await _showParkDialog();
              if (result != null) {
                _cartModel = result;
                _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
                setState(() {});
              }
            }
          },
        ),
      if (widget.type == OrderType.takeAway)
        HomeMenu(
          name: 'Delivery Company'.tr,
          icon: const Icon(Icons.delivery_dining_outlined, color: ColorsApp.gray),
          onTab: () async {
            if (_cartModel.items.isNotEmpty) {
              Fluttertoast.showToast(msg: 'The cart must be emptied, in order to be able to change the delivery company'.tr);
            } else {
              await _showDeliveryCompanyDialog();
              if (_cartModel.deliveryCompanyId == 0) {
                for (var element in allDataModel.items) {
                  element.companyPrice = 0;
                }
              } else {
                for (var element in allDataModel.items) {
                  var indexDeliveryCompanyItemPrice = allDataModel.deliveryCompanyItemPriceModel.indexWhere((elementDeliveryCompany) => elementDeliveryCompany.itemId == element.id && elementDeliveryCompany.deliveryCoId == _cartModel.deliveryCompanyId);
                  if (indexDeliveryCompanyItemPrice != -1) {
                    element.companyPrice = allDataModel.deliveryCompanyItemPriceModel[indexDeliveryCompanyItemPrice].price;
                  } else {
                    element.companyPrice = element.price;
                  }
                }
              }
              setState(() {});
            }
          },
        ),
    ];
    if (widget.type == OrderType.dineIn) {
      _cartModel = widget.dineIn!.cart;
    } else {
      _cartModel = CartModel.init(orderType: widget.type);
      mySharedPreferences.orderNo++;
      _cartModel.orderNo = mySharedPreferences.orderNo;
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.dineIn != null) {
      RestApi.unlockTable(widget.dineIn!.tableId);
    }
  }

  Future<double> _showDeliveryDialog({TextEditingController? controller, required double delivery}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '$delivery');
    if (controller.text.endsWith('.0')) {
      controller.text = controller.text.replaceFirst('.0', '');
    }
    var _delivery = await Get.dialog(
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
                          label: Text('Delivery'.tr),
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
    return _delivery == null ? _delivery : double.parse(_delivery);
  }

  Future<Map<String, dynamic>> _showDiscountDialog({TextEditingController? controller, required double discount, required double price, required DiscountType type}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '$discount');
    if (controller.text.endsWith('.0')) {
      controller.text = controller.text.replaceFirst('.0', '');
    }
    var _discount = await Get.dialog(
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
                          label: Text('${'Discount'.tr} ${DiscountType.value == type ? '(${price.toStringAsFixed(3)})' : '(%)'}'),
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
                            return Validation.discount(type, controller!.text, price);
                          },
                        ),
                        CheckboxListTile(
                          title: Text('Percentage'.tr),
                          value: type == DiscountType.percentage,
                          onChanged: (value) {
                            type = value! ? DiscountType.percentage : DiscountType.value;
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Utils.numPadWidget(
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
    return {
      'discount': _discount == null ? _discount : double.parse(_discount),
      'type': type,
    };
  }

  Future<double> _showPriceChangeDialog({TextEditingController? controller, required double itemPrice, required double priceChange}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '$priceChange');
    if (controller.text.endsWith('.0')) {
      controller.text = controller.text.replaceFirst('.0', '');
    }
    var _priceChange = await Get.dialog(
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
                          label: Text('${'Price Change'.tr} (${itemPrice.toStringAsFixed(3)})'),
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
                            return Validation.priceChange(double.parse(value!));
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
    return _priceChange == null ? priceChange : double.parse(_priceChange);
  }

  Future<void> _showDeliveryCompanyDialog() async {
    await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            Text(
              'Delivery Company'.tr,
              style: kStyleTextTitle,
            ),
            const Divider(thickness: 2),
            StaggeredGrid.count(
              crossAxisCount: 3,
              children: [
                CustomButton(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No Delivery Company'.tr,
                    style: kStyleTextDefault,
                  ),
                  backgroundColor:  ColorsApp.primaryColor.withOpacity(0.2),
                  onPressed: () {
                    _cartModel.deliveryCompanyId = 0;
                    Get.back();
                  },
                ),
                ...allDataModel.deliveryCompanyModel
                    .map((e) => CustomButton(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            e.coName,
                            style: kStyleTextDefault,
                          ),
                          backgroundColor:  ColorsApp.primaryColor.withOpacity(0.2),
                          onPressed: () {
                            _cartModel.deliveryCompanyId = e.id;
                            Get.back();
                          },
                        ))
                    .toList()
              ],
            ),
            SizedBox(height: 80.h),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Exit'.tr),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<CartModel?> _showParkDialog() async {
    CartModel? _parkCart;
    await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            Text(
              'Park'.tr,
              style: kStyleTextTitle,
            ),
            const Divider(thickness: 2),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    15.0,
                  ),
                  border: Border.all(color: ColorsApp.primaryColor)),
              height: 250.h,
              child: StaggeredGrid.count(
                crossAxisCount: 3,
                children: [
                  ...mySharedPreferences.park
                      .map((e) => Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              side: const BorderSide(width: 1),
                            ),
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5.r),
                              onTap: () async {
                                _parkCart = e;
                                var park = mySharedPreferences.park;
                                park.remove(e);
                                mySharedPreferences.park = park;
                                Get.back();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                child: Text(
                                  e.parkName,
                                  style: kStyleTextTitle,
                                ),
                              ),
                            ),
                          ))
                      .toList()
                ],
              ),
            ),
            SizedBox(
              height: 50.h,
            ),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Exit'.tr),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return _parkCart;
  }

  Future<String> _showAddParkDialog() async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    TextEditingController _controllerPark = TextEditingController();
    await Get.dialog(
      CustomDialog(
        width: 250.w,
        height: 300.h,
        builder: (context, setState, constraints) => Form(
          key: _keyForm,
          child: Column(
            children: [
              Text(
                'Add to Park'.tr,
                style: kStyleTextTitle,
              ),
              const Divider(thickness: 2),
              SizedBox(height: 20.h),
              CustomTextField(
                borderColor: ColorsApp.primaryColor,
                controller: _controllerPark,
                label: Text('Name'.tr),
                fillColor: Colors.white,
                validator: (value) {
                  return Validation.isRequired(value);
                },
              ),
              SizedBox(height: 50.h),
              Row(
                children: [
                  Expanded(child: Container()),
                  Expanded(
                    child: CustomButton(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Save'.tr),
                      backgroundColor: ColorsApp.primaryColor,
                      onPressed: () {
                        if (_keyForm.currentState!.validate()) {
                          Get.back();
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Exit'.tr),
                      backgroundColor: ColorsApp.redLight,
                      onPressed: () {
                        _controllerPark.text = '';
                        Get.back();
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
    return _controllerPark.text;
  }

  Future<List<CartItemModifierModel>> _showModifierDialog({required List<ItemWithModifireModel> modifiersItem, required List<CategoryWithModifireModel> modifiersCategory, required List<CartItemModifierModel> addedModifiers}) async {
    int _selectedModifierId = 0;
    List<CartItemModifierModel> modifiers = [];
    modifiers.addAll(List<CartItemModifierModel>.from(modifiersItem.map((e) => CartItemModifierModel(id: e.modifiresId, name: e.name, modifier: ''))));
    modifiers.addAll(List<CartItemModifierModel>.from(modifiersCategory.map((e) => CartItemModifierModel(id: e.modifireId, name: e.name, modifier: ''))));
    modifiers.addAll(List<CartItemModifierModel>.from(addedModifiers.map((e) => CartItemModifierModel(id: e.id, name: e.name, modifier: e.modifier))));
    var _modifiers = await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            Text(
              'Modifier'.tr,
              style: kStyleTextTitle,
            ),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Extra'.tr),
                    onPressed: () {
                      if (_selectedModifierId != 0) {
                        modifiers.firstWhere((element) => element.id == _selectedModifierId).modifier = 'Extra'.tr;
                        setState(() {});
                      } else {
                        Fluttertoast.showToast(msg: 'Please select a modifier'.tr);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('No'.tr),
                    onPressed: () {
                      if (_selectedModifierId != 0) {
                        modifiers.firstWhere((element) => element.id == _selectedModifierId).modifier = 'No'.tr;
                        setState(() {});
                      } else {
                        Fluttertoast.showToast(msg: 'Please select a modifier'.tr);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Little'.tr),
                    onPressed: () {
                      if (_selectedModifierId != 0) {
                        modifiers.firstWhere((element) => element.id == _selectedModifierId).modifier = 'Little'.tr;
                        setState(() {});
                      } else {
                        Fluttertoast.showToast(msg: 'Please select a modifier'.tr);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Half'.tr),
                    onPressed: () {
                      if (_selectedModifierId != 0) {
                        modifiers.firstWhere((element) => element.id == _selectedModifierId).modifier = 'Half'.tr;
                        setState(() {});
                      } else {
                        Fluttertoast.showToast(msg: 'Please select a modifier'.tr);
                      }
                    },
                  ),
                ),
              ],
            ),
            const Divider(thickness: 2),
            StaggeredGrid.count(
              crossAxisCount: 3,
              children: modifiers
                  .map((e) => CustomButton(
                        child: Text(
                          '(${e.id}) - ${e.name} ${e.modifier.isNotEmpty ? '* ${e.modifier}' : ''}',
                          style: kStyleTextDefault,
                        ),
                        backgroundColor: ColorsApp.backgroundDialog,
                        side: _selectedModifierId == e.id ? const BorderSide(width: 1) : null,
                        onPressed: () {
                          _selectedModifierId = e.id;
                          setState(() {});
                        },
                      ))
                  .toList(),
            ),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Save'.tr),
                    backgroundColor: ColorsApp.green,
                    onPressed: () {
                      Get.back(result: modifiers.where((element) => element.modifier.isNotEmpty).toList());
                    },
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Exit'.tr),
                    backgroundColor: ColorsApp.red,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    _dineInChangedOrder = true;
    return _modifiers ?? [];
  }

  Future<List<CartItemQuestionModel>?> _showForceQuestionDialog({required List<ItemWithQuestionsModel> questionsItem}) async {
    List<CartItemQuestionModel> answersModifire = List<CartItemQuestionModel>.from(questionsItem.map((e) => CartItemQuestionModel(id: e.forceQuestionId, question: e.qtext, modifiers: [])));
    bool isCancel = false;
    int i = 0;
    while (i < answersModifire.length) {
      var modifireForceQuestions = allDataModel.modifireForceQuestions.indexWhere((element) => element.forceQuestion.id == answersModifire[i].id && element.modifires.isNotEmpty && element.modifires.any((modifiresElement) => modifiresElement.active == 1));
      if (modifireForceQuestions == -1) {
        i++;
      } else {
        await Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              builder: (context, setState, constraints) => Column(
                children: [
                  Text(
                    'Force Question'.tr,
                    style: kStyleTextTitle,
                  ),
                  const Divider(thickness: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      '(${answersModifire[i].id}) - ${answersModifire[i].question}',
                      style: kStyleTextTitle,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'Answers'.tr} :',
                        style: kStyleForceQuestion,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires.length,
                        itemBuilder: (context, indexModifire) {
                          if (allDataModel.modifireForceQuestions[modifireForceQuestions].forceQuestion.isMultible == 1) {
                            return CheckboxListTile(
                              title: Text(
                                allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name,
                                style: kStyleForceQuestion,
                              ),
                              value: answersModifire[i].modifiers.any((element) => element == CartItemModifierModel(id: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].id, name: '', modifier: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name)),
                              onChanged: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].active == 0
                                  ? null
                                  : (value) {
                                      var _modifire = allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire];
                                      if (value!) {
                                        answersModifire[i].modifiers.add(CartItemModifierModel(id: _modifire.id, name: '', modifier: _modifire.name));
                                      } else {
                                        answersModifire[i].modifiers.remove(CartItemModifierModel(id: _modifire.id, name: '', modifier: _modifire.name));
                                      }
                                      log('modifiers : ${answersModifire[i].modifiers}');
                                      setState(() {});
                                    },
                            );
                          } else {
                            return RadioListTile(
                              title: Text(
                                allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name,
                                style: kStyleForceQuestion,
                              ),
                              value: CartItemModifierModel(id: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].id, name: '', modifier: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name),
                              groupValue: answersModifire[i].modifiers.isEmpty ? '' : answersModifire[i].modifiers.first,
                              onChanged: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].active == 0
                                  ? null
                                  : (value) {
                                      if (answersModifire[i].modifiers.isEmpty) {
                                        answersModifire[i].modifiers.add(value as CartItemModifierModel);
                                      } else {
                                        answersModifire[i].modifiers[0] = value as CartItemModifierModel;
                                      }
                                      log('modifiers : ${answersModifire[i].modifiers}');
                                      setState(() {});
                                    },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      if (i > 0)
                        Expanded(
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Previous'.tr),
                            backgroundColor: ColorsApp.primaryColor,
                            onPressed: () {
                              i--;
                              Get.back();
                            },
                          ),
                        ),
                      if (i + 1 < answersModifire.length)
                        Expanded(
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Next'.tr),
                            backgroundColor: ColorsApp.primaryColor,
                            onPressed: () {
                              if (answersModifire[i].modifiers.isNotEmpty) {
                                i++;
                                Get.back();
                              } else {
                                Fluttertoast.showToast(msg: 'Please answer a question'.tr);
                              }
                            },
                          ),
                        ),
                      if (i + 1 == answersModifire.length)
                        Expanded(
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Save'.tr),
                            backgroundColor: ColorsApp.primaryColor,
                            onPressed: () {
                              if (answersModifire[i].modifiers.isNotEmpty) {
                                i++;
                                Get.back();
                              } else {
                                Fluttertoast.showToast(msg: 'Please answer a question'.tr);
                              }
                            },
                          ),
                        ),
                      Expanded(
                        child: CustomButton(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Cancel'.tr),
                          backgroundColor: ColorsApp.primaryColor,
                          onPressed: () {
                            i = answersModifire.length;
                            isCancel = true;
                            Get.back();
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
      }
    }
    if (isCancel) {
      return null;
    } else {
      answersModifire.removeWhere((element) => element.modifiers.isEmpty);
      return answersModifire;
    }
  }

  Future<List<CartItemModel>?> _showQuestionSubItemDialog({required List<ComboItemsForceQuestionModel> questionsSubItems, required String parentRandomId}) async {
    List<CartItemModel> answersSubItem = [];
    int i = 0;
    bool isCancel = false;
    while (i < questionsSubItems.length) {
      var indexSubItemsForceQuestions = allDataModel.subItemsForceQuestions.indexWhere((element) => element.subItemsForceQuestion.id == questionsSubItems[i].subItemsForceQuestionId && element.items.isNotEmpty);
      if (indexSubItemsForceQuestions == -1) {
        i++;
      } else {
        await Get.dialog(
          WillPopScope(
            onWillPop: () async => false,
            child: CustomDialog(
              builder: (context, setState, constraints) => Column(
                children: [
                  Text(
                    'Sub Items Question'.tr,
                    style: kStyleTextTitle,
                  ),
                  const Divider(thickness: 2),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      '(${allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].subItemsForceQuestion.id}) - ${allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].subItemsForceQuestion.qText}',
                      style: kStyleTextTitle,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'Answers'.tr} :',
                        style: kStyleForceQuestion,
                      ),
                      StaggeredGrid.count(
                        crossAxisCount: 2,
                        children: allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].items
                            .map((e) => Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.r),
                                    side: answersSubItem.any((element) => element.id == e.id) ? const BorderSide(width: 1) : BorderSide.none,
                                  ),
                                  elevation: 0,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(5.r),
                                    onTap: () async {
                                      var indexSubItem = answersSubItem.indexWhere((element) => element.id == e.id);
                                      if (indexSubItem != -1) {
                                        answersSubItem.removeAt(indexSubItem);
                                      } else {
                                        if (allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].subItemsForceQuestion.isMultible == 0) {
                                          answersSubItem.removeWhere((elementSubItem) => allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].items.any((element) => elementSubItem.id == element.id));
                                        }
                                        answersSubItem.add(CartItemModel(
                                          uuid: const Uuid().v1(),
                                          parentUuid: parentRandomId,
                                          orderType: widget.type,
                                          id: e.id,
                                          categoryId: e.category.id,
                                          taxType: e.taxTypeId,
                                          taxPercent: e.taxPercent.percent,
                                          name: e.menuName,
                                          qty: 1,
                                          price: e.inMealPrice,
                                          priceChange: e.inMealPrice,
                                          total: e.inMealPrice,
                                          tax: 0,
                                          discountAvailable: e.discountAvailable == 1,
                                          openPrice: e.openPrice == 1,
                                          rowSerial: 0,
                                        ));
                                      }
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                      child: Row(
                                        children: [
                                          CachedNetworkImage(
                                            imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Items')?.imgPath ?? ''}${e.itemPicture}',
                                            height: 50.h,
                                            width: 50.w,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => SizedBox(
                                              height: 50.h,
                                              width: 50.w,
                                            ),
                                            errorWidget: (context, url, error) => SizedBox(
                                              height: 50.h,
                                              width: 50.w,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  e.menuName,
                                                  style: kStyleTextTitle,
                                                ),
                                                Text(
                                                  e.description,
                                                  style: kStyleTextDefault,
                                                ),
                                                Text(
                                                  e.inMealPrice.toStringAsFixed(3),
                                                  style: kStyleTextTitle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Container()),
                      if (i > 0)
                        Expanded(
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Previous'.tr),
                            backgroundColor: ColorsApp.primaryColor,
                            onPressed: () {
                              i--;
                              Get.back();
                            },
                          ),
                        ),
                      if (i + 1 < questionsSubItems.length)
                        Expanded(
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Next'.tr),
                            backgroundColor: ColorsApp.primaryColor,
                            onPressed: () {
                              if (allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].subItemsForceQuestion.isMandatory == 1) {
                                if (answersSubItem.any((elementSubItem) => allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].items.any((element) => elementSubItem.id == element.id))) {
                                  i++;
                                  Get.back();
                                } else {
                                  Fluttertoast.showToast(msg: 'This question is mandatory'.tr);
                                }
                              } else {
                                i++;
                                Get.back();
                              }
                            },
                          ),
                        ),
                      if (i + 1 == questionsSubItems.length)
                        Expanded(
                          child: CustomButton(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Save'.tr),
                            backgroundColor: ColorsApp.primaryColor,
                            onPressed: () {
                              if (allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].subItemsForceQuestion.isMandatory == 1) {
                                if (answersSubItem.any((elementSubItem) => allDataModel.subItemsForceQuestions[indexSubItemsForceQuestions].items.any((element) => elementSubItem.id == element.id))) {
                                  i++;
                                  Get.back();
                                } else {
                                  Fluttertoast.showToast(msg: 'This question is mandatory'.tr);
                                }
                              } else {
                                i++;
                                Get.back();
                              }
                            },
                          ),
                        ),
                      Expanded(
                        child: CustomButton(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Cancel'.tr),
                          backgroundColor: ColorsApp.primaryColor,
                          onPressed: () {
                            i = questionsSubItems.length;
                            isCancel = true;
                            Get.back();
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
      }
    }
    return isCancel ? null : answersSubItem;
  }

  Future<double> _showQtyDialog({TextEditingController? controller, double? maxQty, double minQty = 0, required double rQty}) async {
    GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
    controller ??= TextEditingController(text: '0');
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
    _dineInChangedOrder = true;
    return double.parse(qty);
  }

  Future<String> _showNoteItemDialog({required String note}) async {
    TextEditingController _controllerNote = TextEditingController(text: note);
    await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            SizedBox(height: 20.h),
            CustomTextField(
              controller: _controllerNote,
              label: Text('Note'.tr),
              fillColor: Colors.white,
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Save'.tr),
                    backgroundColor: ColorsApp.green,
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Exit'.tr),
                    backgroundColor: ColorsApp.red,
                    onPressed: () {
                      _controllerNote.text = note;
                      Get.back();
                    },
                  ),
                ),
                Expanded(child: Container()),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return _controllerNote.text;
  }

  Future<bool> _showExitOrderScreenDialog() async {
    bool? exit = await Get.defaultDialog(
      title: 'Are you sure you will exit the order screen?'.tr,
      titleStyle: kStyleTextTitle,
      content: const Text(''),
      textCancel: 'Cancel'.tr,
      textConfirm: 'Confirm'.tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(result: true);
      },
      barrierDismissible: true,
    );
    if (exit == null) {
      return false;
    }
    return exit;
  }

  Future<VoidReasonModel?> _showVoidReasonDialog() async {
    int? _selectedVoidReasonId;
    await Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: CustomDialog(
          builder: (context, setState, constraints) => Column(
            children: [
              Text(
                'Void Reason'.tr,
                style: kStyleTextTitle,
              ),
              const Divider(thickness: 2),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allDataModel.voidReason.length,
                itemBuilder: (context, index) => RadioListTile(
                  title: Text(
                    allDataModel.voidReason[index].reasonName,
                    style: kStyleForceQuestion,
                  ),
                  value: allDataModel.voidReason[index].id,
                  groupValue: _selectedVoidReasonId,
                  onChanged: (value) {
                    _selectedVoidReasonId = value as int;
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
                        _selectedVoidReasonId = null;
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
                        if (_selectedVoidReasonId == null) {
                          Fluttertoast.showToast(msg: 'Please select void reason'.tr);
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
    return _selectedVoidReasonId == null ? null : allDataModel.voidReason.firstWhere((element) => element.id == _selectedVoidReasonId);
  }

  Future<void> _actionPopUpItemSelected(String value, int index) async {
    _indexItemSelect = index;
    setState(() {});
    switch (value) {
      case 'Qty':
        if (_indexItemSelect != -1) {
          if (!_cartModel.items[_indexItemSelect].dineInSavedOrder) {
            _cartModel.items[_indexItemSelect].qty = await _showQtyDialog(rQty: _cartModel.items[_indexItemSelect].qty, minQty: 0);
            for (var element in _cartModel.items) {
              if (_cartModel.items[_indexItemSelect].uuid == element.parentUuid) {
                element.qty = _cartModel.items[_indexItemSelect].qty;
              }
            }
            _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
            setState(() {});
          } else {
            Fluttertoast.showToast(msg: 'The quantity of this item cannot be modified'.tr);
          }
        } else {
          Fluttertoast.showToast(msg: 'Please select the item you want to change quantity'.tr);
        }
        break;
      case 'Modifier':
        if (_indexItemSelect != -1) {
          var modifiersItem = allDataModel.itemWithModifires.where((element) => element.itemsId == _cartModel.items[_indexItemSelect].id).toList();
          var modifiersCategory = allDataModel.categoryWithModifires.where((element) => element.categoryId == _cartModel.items[_indexItemSelect].categoryId).toList();
          modifiersCategory.removeWhere((elementCategory) => modifiersItem.any((elementItem) => elementItem.modifiresId == elementCategory.modifireId));
          modifiersCategory.removeWhere((elementCategory) => allDataModel.modifires.any((element) => element.id == elementCategory.modifireId && element.active == 0));
          modifiersItem.removeWhere((elementItem) => allDataModel.modifires.any((element) => element.id == elementItem.modifiresId && element.active == 0));
          if (modifiersItem.isNotEmpty || modifiersCategory.isNotEmpty) {
            modifiersCategory.removeWhere((elementCategory) => _cartModel.items[_indexItemSelect].modifiers.any((element) => element.id == elementCategory.modifireId));
            modifiersItem.removeWhere((elementItem) => _cartModel.items[_indexItemSelect].modifiers.any((element) => element.id == elementItem.modifiresId));
            var modifiers = await _showModifierDialog(modifiersItem: modifiersItem, modifiersCategory: modifiersCategory, addedModifiers: _cartModel.items[_indexItemSelect].modifiers);
            if (modifiers.isNotEmpty) {
              _cartModel.items[_indexItemSelect].modifiers = modifiers;
            }
            setState(() {});
          } else {
            Fluttertoast.showToast(msg: 'This item cannot be modified'.tr);
          }
        } else {
          Fluttertoast.showToast(msg: 'Please select the item you want to modifier'.tr);
        }
        break;
      case 'Void':
        var permission = false;
        if (mySharedPreferences.employee.hasVoidPermission) {
          permission = true;
        } else {
          EmployeeModel? employee = await Utils.showLoginDialog();
          if (employee != null) {
            if (employee.hasVoidPermission) {
              permission = true;
            } else {
              Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
            }
          }
        }
        if (permission) {
          if (_indexItemSelect != -1) {
            VoidReasonModel? result;
            if (allDataModel.companyConfig[0].useVoidReason) {
              result = await _showVoidReasonDialog();
            } else {
              var areYouSure = await Utils.showAreYouSureDialog(title: 'Void'.tr);
              if (areYouSure) {
                result = VoidReasonModel.fromJson({});
              }
            }
            if (result != null) {
              RestApi.saveVoidItem(item: _cartModel.items[_indexItemSelect], reason: result.reasonName);
              if (_cartModel.orderType == OrderType.dineIn && _cartModel.items[_indexItemSelect].dineInSavedOrder) {
                List<CartItemModel> voidItems = [];
                voidItems.add(_cartModel.items[_indexItemSelect]);
                voidItems.addAll(_cartModel.items.where((element) => element.parentUuid == _cartModel.items[_indexItemSelect].uuid));
                Printer.printKitchenVoidItemsDialog(cart: _cartModel, itemsVoid: voidItems);
              }

              _cartModel.items.removeWhere((element) => element.parentUuid == _cartModel.items[_indexItemSelect].uuid);
              _cartModel.items.removeAt(_indexItemSelect);
              _indexItemSelect = -1;
              if (_cartModel.items.isEmpty) {
                _cartModel.deliveryCharge = 0;
                _cartModel.discount = 0;
              } else if (_cartModel.items.every((element) => !element.discountAvailable)) {
                _cartModel.discount = 0;
              }
              _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
              _dineInChangedOrder = true;
              setState(() {});
            }
          } else {
            Fluttertoast.showToast(msg: 'Please select the item you want to remove'.tr);
          }
        }
        break;
      case 'Line Discount':
        var permission = false;
        if (mySharedPreferences.employee.hasLineDiscPermission) {
          permission = true;
        } else {
          EmployeeModel? employee = await Utils.showLoginDialog();
          if (employee != null) {
            if (employee.hasLineDiscPermission) {
              permission = true;
            } else {
              Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
            }
          }
        }
        if (permission) {
          if (_indexItemSelect != -1) {
            if (_cartModel.items[_indexItemSelect].discountAvailable) {
              var result = await _showDiscountDialog(
                discount: _cartModel.items[_indexItemSelect].lineDiscount,
                price: _cartModel.items[_indexItemSelect].priceChange,
                type: _cartModel.items[_indexItemSelect].lineDiscountType,
              );
              _cartModel.items[_indexItemSelect].lineDiscount = result['discount'];
              _cartModel.items[_indexItemSelect].lineDiscountType = result['type'];
              _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
              _dineInChangedOrder = true;
              setState(() {});
            } else {
              Fluttertoast.showToast(msg: 'Line discount is not available for this item'.tr);
            }
          } else {
            Fluttertoast.showToast(msg: 'Please select the item you want to line discount'.tr);
          }
        }
        break;
      case 'Price Change':
        var permission = false;
        if (mySharedPreferences.employee.hasPriceChangePermission) {
          permission = true;
        } else {
          EmployeeModel? employee = await Utils.showLoginDialog();
          if (employee != null) {
            if (employee.hasPriceChangePermission) {
              permission = true;
            } else {
              Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
            }
          }
        }
        if (permission) {
          if (_indexItemSelect != -1) {
            if (_cartModel.items[_indexItemSelect].openPrice) {
              _cartModel.items[_indexItemSelect].priceChange = await _showPriceChangeDialog(itemPrice: _cartModel.items[_indexItemSelect].price, priceChange: _cartModel.items[_indexItemSelect].priceChange);
              _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
              _dineInChangedOrder = true;
              setState(() {});
            } else {
              Fluttertoast.showToast(msg: 'Price change is not available for this item'.tr);
            }
          } else {
            Fluttertoast.showToast(msg: 'Please select the item you want to price change'.tr);
          }
        }
    }
    // if (value == 'edit') {
    //   message = 'You selected edit for $name';
    //   // You can navigate the user to edit page.
    // } else if (value == 'delete') {
    //   message = 'You selected delete for $name';
    //   // You can delete the item.
    // } else {
    //   message = 'Not implemented';
    // }
  }

  _saveDineIn() async {
    Utils.showLoadingDialog();
    await Printer.printInvoicesDialog(cart: _cartModel, showPrintButton: false, cashPrinter: false, kitchenPrinter: true, showInvoiceNo: false);
    widget.dineIn!.cart = _cartModel;
    for (var item in widget.dineIn!.cart.items) {
      item.dineInSavedOrder = true;
    }
    await RestApi.saveTableOrder(cart: widget.dineIn!.cart);
    _dineInChangedOrder = false;
    Utils.hideLoadingDialog();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isShowItem) {
          _isShowItem = false;
          setState(() {});
          return false;
        } else {
          var result = await _showExitOrderScreenDialog();
          if (result && widget.type == OrderType.dineIn && _cartModel.items.isEmpty) {
            var result = await RestApi.closeTable(widget.dineIn!.tableId);
            if (result) {
              widget.dineIn!.cart = _cartModel;
              widget.dineIn!.isOpen = false;
            }
          }
          return result;
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: ClipPath(
          // clipper: OvalRightBorderClipper(),
          child: SizedBox(
            width: 120.w,
            child: CustomDrawer(
              menu: _menu,
            ),
          ),
        ),
        body: CustomSingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 50.h,
                color: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.backgroundDialog,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (_isShowItem) {
                          maxHeightItem = 0;
                          _isShowItem = false;
                          setState(() {});
                        } else {
                          if (widget.type == OrderType.dineIn || _cartModel.items.isEmpty) {
                            _showExitOrderScreenDialog().then((value) async {
                              if (value) {
                                if (widget.type == OrderType.dineIn && _cartModel.items.isEmpty) {
                                  var result = await RestApi.closeTable(widget.dineIn!.tableId);
                                  if (result) {
                                    widget.dineIn!.cart = _cartModel;
                                    widget.dineIn!.isOpen = false;
                                    Get.back();
                                  }
                                } else {
                                  Get.back();
                                }
                              }
                            });
                          } else {
                            if (allDataModel.companyConfig[0].useVoidReason) {
                              _showVoidReasonDialog().then((value) {
                                if (value != null) {
                                  RestApi.saveVoidAllItems(items: _cartModel.items, reason: value.reasonName);
                                  Get.back();
                                }
                              });
                            } else {
                              _showExitOrderScreenDialog().then((value) {
                                if (value) {
                                  RestApi.saveVoidAllItems(items: _cartModel.items, reason: '');
                                }
                              });
                            }
                          }
                        }
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 20,
                        color: companyType == CompanyType.umniah ? ColorsApp.primaryColor : ColorsApp.black,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.type == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault.copyWith(color: companyType == CompanyType.umniah ? Colors.white : null),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '${'VocNo'.tr} : ${mySharedPreferences.inVocNo}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault.copyWith(color: companyType == CompanyType.umniah ? Colors.white : null),
                      ),
                    ),
                    if (widget.type == OrderType.dineIn)
                      Expanded(
                        child: Text(
                          '${'Table'.tr} : ${widget.dineIn!.tableNo}',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault.copyWith(color: companyType == CompanyType.umniah ? Colors.white : null),
                        ),
                      ),
                    if (widget.type == OrderType.dineIn)
                      const VerticalDivider(
                        width: 1,
                        thickness: 2,
                      ),
                    if (widget.type == OrderType.dineIn)
                      Expanded(
                        child: Text(
                          '${'Check'.tr} : ',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault.copyWith(color: companyType == CompanyType.umniah ? Colors.white : null),
                        ),
                      ),
                    if (widget.type == OrderType.dineIn)
                      const VerticalDivider(
                        width: 1,
                        thickness: 2,
                      ),
                    Expanded(
                      child: Text(
                        DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault.copyWith(color: companyType == CompanyType.umniah ? Colors.white : null),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _scaffoldKey.currentState?.openEndDrawer();
                      },
                      icon: Icon(Icons.menu, color: companyType == CompanyType.umniah ? ColorsApp.primaryColor : ColorsApp.black),
                    ),
                    if (widget.type == OrderType.dineIn)
                      Row(
                        children: [
                          SizedBox(width: 4.w),
                          const VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Image.asset(
                            kAssetsGuests,
                            height: 45.h,
                          ),
                          Text(
                            '${widget.dineIn!.cart.totalSeats}',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: kStyleTextDefault,
                          ),
                          SizedBox(width: 4.w),
                        ],
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: StaggeredGrid.count(
                          crossAxisCount: _isShowItem
                              ? 2
                              : companyType == CompanyType.umniah
                                  ? 3
                                  : 2,
                          children: _isShowItem
                              ? allDataModel.items
                                  .where((element) => element.category.id == _selectedCategoryId)
                                  .map(
                                    (e) => Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.r),
                                      ),
                                      elevation: 0,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(5.r),
                                        onTap: () async {
                                          bool itemIsAdded = false;
                                          var indexItem = _cartModel.items.lastIndexWhere((element) => element.id == e.id && element.parentUuid == '' && element.modifiers.isEmpty);
                                          var questionsItem = allDataModel.itemWithQuestions.where((element) => element.itemsId == e.id).toList();
                                          var questionsSubItems = allDataModel.comboItemsForceQuestion.where((element) => element.itemId == e.id).toList();
                                          if (indexItem != -1 && questionsItem.isEmpty && questionsSubItems.isEmpty) {
                                            if (widget.type == OrderType.dineIn && _cartModel.items[indexItem].dineInSavedOrder) {
                                              itemIsAdded = false;
                                            } else {
                                              itemIsAdded = true;
                                            }
                                          }
                                          if (itemIsAdded) {
                                            _cartModel.items[indexItem].qty += 1;
                                          } else {
                                            _cartModel.items.add(CartItemModel(
                                              uuid: const Uuid().v1(),
                                              parentUuid: '',
                                              orderType: widget.type,
                                              id: e.id,
                                              categoryId: e.category.id,
                                              taxType: e.taxTypeId,
                                              taxPercent: e.taxPercent.percent,
                                              name: e.menuName,
                                              qty: 1,
                                              price: _cartModel.deliveryCompanyId == 0 ? e.price : e.companyPrice,
                                              priceChange: _cartModel.deliveryCompanyId == 0 ? e.price : e.companyPrice,
                                              total: _cartModel.deliveryCompanyId == 0 ? e.price : e.companyPrice,
                                              tax: 0,
                                              discountAvailable: e.discountAvailable == 1,
                                              openPrice: e.openPrice == 1,
                                              rowSerial: _cartModel.items.length + 1,
                                            ));
                                            int indexAddedItem = _cartModel.items.length - 1;
                                            if (questionsSubItems.isNotEmpty) {
                                              var cartSubItems = await _showQuestionSubItemDialog(questionsSubItems: questionsSubItems, parentRandomId: _cartModel.items[indexAddedItem].uuid);
                                              if (cartSubItems == null) {
                                                _cartModel.items = _cartModel.items.sublist(0, indexAddedItem);
                                              } else {
                                                _cartModel.items[indexAddedItem].isCombo = true;
                                                if (cartSubItems.isNotEmpty) {
                                                  // _cartModel.items[indexAddedItem].price = cartSubItems.fold(_cartModel.items[indexAddedItem].price, (sum, element) => sum + element.price);
                                                  // _cartModel.items[indexAddedItem].priceChange = cartSubItems.fold(_cartModel.items[indexAddedItem].priceChange, (sum, element) => sum + element.priceChange);
                                                  _cartModel.items[indexAddedItem].openPrice = false;
                                                  _cartModel.items.addAll(cartSubItems);
                                                }
                                              }
                                            }
                                            if (questionsItem.isNotEmpty && indexAddedItem < _cartModel.items.length) {
                                              var questions = await _showForceQuestionDialog(questionsItem: questionsItem);
                                              if (questions == null) {
                                                _cartModel.items = _cartModel.items.sublist(0, indexAddedItem);
                                              } else {
                                                _cartModel.items[indexAddedItem].questions = questions;
                                              }
                                            }
                                          }
                                          _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
                                          _dineInChangedOrder = true;
                                          setState(() {});
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Stack(
                                                children: [
                                                  // e.itemPicture.isNotEmpty?
                                                  //   CachedNetworkImage(
                                                  //     imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Items')?.imgPath ?? ''}${e.itemPicture}',
                                                  //     height: 80.h,
                                                  //       width: 300.h,
                                                  //       fit: BoxFit.fill,
                                                  //
                                                  //     placeholder: (context, url) => Container(),
                                                  //     errorWidget: (context, url, error) => Container(),
                                                  //   ):
                                                  Image.asset(
                                                    kAssetsItem,
                                                    height: 80.h,
                                                    width: 300.h,
                                                    fit: BoxFit.fill,
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8.h),
                                                    child: Align(
                                                      alignment: Alignment.topRight,
                                                      child: Image.asset(
                                                        kAssetsFavorite,
                                                        height: 30.h,
                                                        width: 30.w,
                                                        fit: BoxFit.fitHeight,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              // if (e.itemPicture.isNotEmpty)
                                              //   CachedNetworkImage(
                                              //     imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Items')?.imgPath ?? ''}${e.itemPicture}',
                                              //     height: 50.h,
                                              //     width: 50.w,
                                              //     fit: BoxFit.contain,
                                              //     placeholder: (context, url) => Container(),
                                              //     errorWidget: (context, url, error) => Container(),
                                              //   ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  Text(
                                                    e.menuName,
                                                    maxLines: 2,
                                                    style: kStyleTextTitle,
                                                    textAlign: TextAlign.left,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  // if (e.description.isNotEmpty)
                                                  //   Text(
                                                  //     e.description,
                                                  //     style: kStyleTextDefault,
                                                  //   ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        _cartModel.deliveryCompanyId == 0 ? e.price.toStringAsFixed(3) + " JD" : e.companyPrice.toStringAsFixed(3) + " JD",
                                                        style: kStyleTextTitle.copyWith(color: ColorsApp.primaryColor),
                                                      ),
                                                      SizedBox(
                                                        width: 10.w,
                                                      ),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: ColorsApp.primaryColor,
                                                          borderRadius: BorderRadius.circular(15.r),
                                                          border: Border.all(color: ColorsApp.primaryColor),
                                                        ),
                                                        width: 30.w,
                                                        height: 40.h,
                                                        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                        child: Center(
                                                          child: Text(
                                                            'Add + '.tr,
                                                            style: kStyleTextDefault.copyWith(color: Colors.white),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList()
                              : allDataModel.categories
                                  .map((e) => InkWell(
                                        onTap: () async {
                                          _selectedCategoryId = e.id;
                                          _isShowItem = true;
                                          setState(() {});
                                        },
                                        child: companyType == CompanyType.umniah
                                            ? Card(
                                                color: ColorsApp.gray_light,
                                                shadowColor: ColorsApp.gray_light,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.r),
                                                ),
                                                elevation: 0,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          Image.asset(
                                                            'assets/images/Image_1.png',
                                                            height: 80.h,
                                                            width: 100.w,
                                                            fit: BoxFit.fitHeight,
                                                          ),
                                                          Align(
                                                            alignment: Alignment.topRight,
                                                            child: Image.asset(
                                                              'assets/images/Favorite.png',
                                                              height: 30.h,
                                                              width: 30.w,
                                                              fit: BoxFit.fitHeight,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                      // CachedNetworkImage(
                                                      //   imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Categories')?.imgPath ?? ''}${e.categoryPic}',
                                                      //   height: 50.h,
                                                      //   width: 50.w,
                                                      //   fit: BoxFit.contain,
                                                      //   placeholder: (context, url) => SizedBox(
                                                      //     height: 50.h,
                                                      //     width: 50.w,
                                                      //   ),
                                                      //   errorWidget: (context, url, error) => SizedBox(
                                                      //     height: 50.h,
                                                      //     width: 50.w,
                                                      //   ),
                                                      // ),
                                                      SizedBox(
                                                        height: 10.h,
                                                      ),
                                                      Text(
                                                        '${e.categoryName}',
                                                        maxLines: 2,
                                                        textAlign: TextAlign.center,
                                                        style: kStyleTextTitle,
                                                      ),
                                                      SizedBox(
                                                        height: 10.h,
                                                      ),
                                                      CustomButton(
                                                        borderRadius: 8,
                                                        width: 50.w,
                                                        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                                        child: Text(
                                                          'View Items'.tr,
                                                          style: kStyleTextButton,
                                                        ),
                                                        fixed: true,
                                                        backgroundColor: ColorsApp.primaryColor,
                                                        onPressed: () async {
                                                          _selectedCategoryId = e.id;
                                                          _isShowItem = true;
                                                          setState(() {});
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Card(
                                                color: ColorsApp.gray_light,
                                                shadowColor: ColorsApp.gray_light,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.r),
                                                ),
                                                elevation: 0,
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                                  child: Stack(
                                                    children: [
                                                      CachedNetworkImage(
                                                        imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Categories')?.imgPath ?? ''}${e.categoryPic}',
                                                        height: 120.h,
                                                        width: 300.h,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Image.asset(
                                                          kAssetsCategory,
                                                          height: 120.h,
                                                          width: 300.h,
                                                          fit: BoxFit.cover,
                                                        ),
                                                        errorWidget: (context, url, error) => Image.asset(
                                                          kAssetsCategory,
                                                          height: 120.h,
                                                          width: 300.h,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment.topRight,
                                                        child: Padding(
                                                          padding: EdgeInsets.only(top: 8.h),
                                                          child: Image.asset(
                                                            kAssetsFavorite,
                                                            height: 30.h,
                                                            width: 30.w,
                                                            fit: BoxFit.fitHeight,
                                                          ),
                                                        ),
                                                      ),
                                                      Column(
                                                        children: [
                                                          SizedBox(height: 55.h),
                                                          Opacity(
                                                            opacity: 0.7,
                                                            child: Container(
                                                              decoration: BoxDecoration(color: ColorsApp.orangeLight, borderRadius: BorderRadius.all(Radius.circular(5.r))),
                                                              height: 65.h,
                                                              child: Center(
                                                                child: Text(
                                                                  e.categoryName,
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  textAlign: TextAlign.center,
                                                                  style: kStyleButtonPayment.copyWith(color: ColorsApp.primaryColor, fontSize: 20.sp),
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
                                      ))
                                  .toList(),
                        ),
                      ),
                    ),
                    Container(
                      width: 130.w,
                      color: ColorsApp.orangeLight,
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5.h,
                          ),
                          Row(
                            children: [
                              if (mySharedPreferences.employee.hasDiscPermission)
                                Expanded(
                                  child: Container(
                                    width: 50.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: ColorsApp.primaryColor),
                                      borderRadius: BorderRadius.circular(
                                        10.0,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        var permission = false;
                                        if (mySharedPreferences.employee.hasDiscPermission) {
                                          permission = true;
                                        } else {
                                          EmployeeModel? employee = await Utils.showLoginDialog();
                                          if (employee != null) {
                                            if (employee.hasDiscPermission) {
                                              permission = true;
                                            } else {
                                              Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                                            }
                                          }
                                        }
                                        if (permission) {
                                          if (_cartModel.items.any((element) => element.discountAvailable)) {
                                            var result = await _showDiscountDialog(
                                              discount: _cartModel.discount,
                                              price: _cartModel.total,
                                              type: _cartModel.discountType,
                                            );
                                            _cartModel.discount = result['discount'];
                                            _cartModel.discountType = result['type'];
                                            _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
                                            _dineInChangedOrder = true;
                                            setState(() {});
                                          } else {
                                            Fluttertoast.showToast(msg: 'No items accept discount in order'.tr);
                                          }
                                        }
                                      },
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                'Discount'.tr,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: kStyleTextOrange,
                                              ),
                                            ),
                                            Image.asset(
                                              kAssetsArrowRight,
                                              height: 20.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(
                                width: 5.w,
                              ),
                              if (mySharedPreferences.employee.hasVoidAllPermission)
                                Expanded(
                                    child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: ColorsApp.primaryColor),
                                      borderRadius: BorderRadius.circular(
                                        10.0,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () async {
                                        var permission = false;
                                        if (mySharedPreferences.employee.hasVoidAllPermission) {
                                          permission = true;
                                        } else {
                                          EmployeeModel? employee = await Utils.showLoginDialog();
                                          if (employee != null) {
                                            if (employee.hasVoidAllPermission) {
                                              permission = true;
                                            } else {
                                              Fluttertoast.showToast(msg: 'The account you are logged in with does not have permission');
                                            }
                                          }
                                        }
                                        if (permission) {
                                          if (_cartModel.items.isEmpty) {
                                            Fluttertoast.showToast(msg: 'There must be items'.tr);
                                          } else {
                                            VoidReasonModel? result;
                                            if (allDataModel.companyConfig[0].useVoidReason) {
                                              result = await _showVoidReasonDialog();
                                            } else {
                                              var areYouSure = await Utils.showAreYouSureDialog(
                                                title: 'Void All'.tr,
                                              );
                                              if (areYouSure) {
                                                result = VoidReasonModel.fromJson({});
                                              }
                                            }
                                            if (result != null) {
                                              RestApi.saveVoidAllItems(items: _cartModel.items, reason: result.reasonName);
                                              List<CartItemModel> voidItems = [];
                                              voidItems.addAll(_cartModel.items.where((element) => element.dineInSavedOrder));
                                              if (_cartModel.orderType == OrderType.dineIn && voidItems.isNotEmpty) {
                                                Printer.printKitchenVoidItemsDialog(cart: _cartModel, itemsVoid: voidItems);
                                              }
                                              _indexItemSelect = -1;
                                              _cartModel.items = [];
                                              _cartModel.deliveryCharge = 0;
                                              _cartModel.discount = 0;
                                              _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
                                              _dineInChangedOrder = true;
                                              setState(() {});
                                            }
                                          }
                                        }
                                      },
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Center(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  'Void All'.tr,
                                                  textAlign: TextAlign.center,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: kStyleTextOrange,
                                                ),
                                              ),
                                              Image.asset(
                                                kAssetsArrowRight,
                                                height: 20.h,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                              SizedBox(
                                width: 5.w,
                              ),
                              if (widget.type == OrderType.takeAway)
                                Expanded(
                                    child: Container(
                                  width: 50.w,
                                  height: 30.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: ColorsApp.primaryColor),
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: InkWell(
                                      onTap: () async {
                                        if (_cartModel.items.isNotEmpty) {
                                          _cartModel.deliveryCharge = await _showDeliveryDialog(delivery: _cartModel.deliveryCharge);
                                          _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
                                          setState(() {});
                                        } else {
                                          Fluttertoast.showToast(msg: 'Delivery price cannot be added and there are no selected items'.tr);
                                        }
                                      },
                                      child: Text(
                                        'Delivery'.tr,
                                        style: kStyleTextOrange,
                                      ),
                                    ),
                                  ),
                                )),
                              SizedBox(
                                width: 5.w,
                              ),
                              Expanded(
                                child: CustomButton(
                                  margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                  child: Text(
                                    'Park'.tr,
                                    style: kStyleTextButton,
                                  ),
                                  fixed: true,
                                  backgroundColor: companyType == CompanyType.umniah ? ColorsApp.darkBlue : ColorsApp.redLight,
                                  onPressed: () async {
                                    if (_cartModel.items.isNotEmpty) {
                                      var result = await _showAddParkDialog();
                                      if (result.isNotEmpty) {
                                        _cartModel.parkName = result;
                                        var park = mySharedPreferences.park;
                                        park.add(_cartModel);
                                        mySharedPreferences.park = park;
                                        _cartModel = CartModel.init(orderType: OrderType.takeAway);
                                        _cartModel = Utils.calculateOrder(cart: _cartModel, orderType: widget.type);
                                        setState(() {});
                                      }
                                    } else {
                                      Fluttertoast.showToast(msg: 'Please add items to complete an park'.tr);
                                    }
                                  },
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5.h,
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(3.r),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        child: Padding(
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
                                      ),
                                      const Divider(color: Colors.grey, height: 1),
                                      ListView.separated(
                                        itemCount: _cartModel.items.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (context, index) => _cartModel.items[index].parentUuid.isNotEmpty ? Container() : const Divider(color: Colors.black, height: 1),
                                        itemBuilder: (context, index) {
                                          if (_cartModel.items[index].parentUuid.isNotEmpty) {
                                            return Container();
                                          } else {
                                            var subItem = _cartModel.items.where((element) => element.parentUuid == _cartModel.items[index].uuid).toList();
                                            return InkWell(
                                              onTap: () {
                                                _indexItemSelect = index;
                                                setState(() {});
                                              },
                                              onLongPress: () async {
                                                var note = await _showNoteItemDialog(note: _cartModel.items[index].note);
                                                _cartModel.items[index].note = note;
                                              },
                                              child: Container(
                                                color: index == _indexItemSelect ? ColorsApp.primaryColor : null,
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              '${_cartModel.items[index].qty}',
                                                              style: kStyleDataTable,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                              _cartModel.items[index].name,
                                                              style: kStyleDataTable,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              _cartModel.items[index].priceChange.toStringAsFixed(3),
                                                              style: kStyleDataTable,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              (_cartModel.items[index].priceChange * _cartModel.items[index].qty).toStringAsFixed(3),
                                                              style: kStyleDataTable,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          PopupMenuButton(
                                                            itemBuilder: (context) {
                                                              return [
                                                                PopupMenuItem(
                                                                  value: 'Qty',
                                                                  child: Text(
                                                                    'Qty'.tr,
                                                                    style: kStyleTextDefault,
                                                                  ),
                                                                ),
                                                                PopupMenuItem(
                                                                  value: 'Modifier',
                                                                  child: Text(
                                                                    'Modifier'.tr,
                                                                    style: kStyleTextDefault,
                                                                  ),
                                                                ),
                                                                PopupMenuItem(
                                                                  value: 'Void',
                                                                  child: Text(
                                                                    'Void'.tr,
                                                                    style: kStyleTextDefault,
                                                                  ),
                                                                ),
                                                                PopupMenuItem(
                                                                  value: 'Line Discount',
                                                                  child: Text(
                                                                    'Line Discount'.tr,
                                                                    style: kStyleTextDefault,
                                                                  ),
                                                                ),
                                                                PopupMenuItem(
                                                                  value: 'Price Change',
                                                                  child: Text(
                                                                    'Price Change'.tr,
                                                                    style: kStyleTextDefault,
                                                                  ),
                                                                ),
                                                              ];
                                                            },
                                                            onSelected: (String value) {
                                                              _actionPopUpItemSelected(value, index);
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                                      child: Column(
                                                        children: [
                                                          ListView.builder(
                                                            itemCount: _cartModel.items[index].questions.length,
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemBuilder: (context, indexQuestions) => Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        _cartModel.items[index].questions[indexQuestions].question.trim(),
                                                                        style: kStyleDataTableModifiers,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                ListView.builder(
                                                                  itemCount: _cartModel.items[index].questions[indexQuestions].modifiers.length,
                                                                  shrinkWrap: true,
                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                  itemBuilder: (context, indexModifiers) => Column(
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              '* ${_cartModel.items[index].questions[indexQuestions].modifiers[indexModifiers].modifier}',
                                                                              style: kStyleDataTableModifiers,
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
                                                            itemCount: _cartModel.items[index].modifiers.length,
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemBuilder: (context, indexModifiers) => Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    '${_cartModel.items[index].modifiers[indexModifiers].name}\n* ${_cartModel.items[index].modifiers[indexModifiers].modifier}',
                                                                    style: kStyleDataTableModifiers,
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
                                                                        style: kStyleDataTableModifiers,
                                                                        textAlign: TextAlign.center,
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        subItem[indexSubItem].priceChange.toStringAsFixed(3),
                                                                        style: kStyleDataTableModifiers,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        (subItem[indexSubItem].priceChange * subItem[indexSubItem].qty).toStringAsFixed(3),
                                                                        style: kStyleDataTableModifiers,
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
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(children: [
                            const Divider(color: Colors.black, height: 20),
                            Align(
                              alignment: Alignment.topCenter,
                              child: InkWell(
                                onTap: () {
                                  _isShowTotal = !_isShowTotal;
                                  setState(() {});
                                },
                                child: Container(
                                  child: Image.asset(
                                    kAssetsArrowBottom,
                                    height: 20.h,
                                  ),
                                ),
                              ),
                            ),
                          ]),
                          _isShowTotal
                              ? Container(
                                  margin: EdgeInsets.symmetric(vertical: 4.h),
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: ColorsApp.orangeLight,
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
                                            _cartModel.total.toStringAsFixed(3),
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
                                            _cartModel.totalLineDiscount.toStringAsFixed(3),
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
                                            _cartModel.totalDiscount.toStringAsFixed(3),
                                            style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      const Divider(color: Colors.black),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Sub Total'.tr,
                                              style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Text(
                                            _cartModel.subTotal.toStringAsFixed(3),
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
                                            _cartModel.deliveryCharge.toStringAsFixed(3),
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
                                            _cartModel.service.toStringAsFixed(3),
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
                                            _cartModel.tax.toStringAsFixed(3),
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
                                            _cartModel.amountDue.toStringAsFixed(3),
                                            style: kStyleTextDefault.copyWith(color: ColorsApp.red, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          SizedBox(
                            height: 5.h,
                          ),
                          Container(
                            width: 150.w,
                            height: 35.h,
                            decoration: BoxDecoration(
                                color: ColorsApp.backgroundDialog,
                                borderRadius: BorderRadius.circular(
                                  5.0,
                                ),
                                border: Border.all(color: ColorsApp.black)),
                            child: Center(
                              child: Text(
                                'Amount Due'.tr + '\t\t\t' + _cartModel.amountDue.toStringAsFixed(3),
                                style: kStyleTextDefault.copyWith(color: ColorsApp.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              if (widget.type == OrderType.takeAway)
                                Expanded(
                                  child: CustomButton(
                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                    child: Text(
                                      'Cash'.tr,
                                      style: kStyleTextButton,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.primaryColor,
                                    onPressed: () async {
                                      if (_cartModel.items.isNotEmpty) {
                                        Get.to(() => PayScreen(
                                              cart: _cartModel,
                                              openTypeDialog: 1,
                                            ));
                                      } else {
                                        Fluttertoast.showToast(msg: 'Please add items to complete an order'.tr);
                                      }
                                    },
                                  ),
                                ),
                              if (widget.type == OrderType.takeAway)
                                Expanded(
                                  child: CustomButton(
                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                    child: Text(
                                      'Visa'.tr,
                                      style: kStyleTextButton,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.primaryColor,
                                    onPressed: () async {
                                      if (_cartModel.items.isNotEmpty) {
                                        Get.to(() => PayScreen(
                                              cart: _cartModel,
                                              openTypeDialog: 0,
                                            ));
                                      } else {
                                        Fluttertoast.showToast(msg: 'Please add items to complete an order'.tr);
                                      }
                                    },
                                  ),
                                ),
                              if (widget.type == OrderType.takeAway)
                                Expanded(
                                  child: CustomButton(
                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                    child: Text(
                                      'Multi Pay'.tr,
                                      style: kStyleTextButton,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.primaryColor,
                                    onPressed: () {
                                      if (_cartModel.items.isNotEmpty) {
                                        Get.to(() => PayScreen(
                                              cart: _cartModel,
                                              openTypeDialog: 2,
                                            ));
                                      } else {
                                        Fluttertoast.showToast(msg: 'Please add items to complete an order'.tr);
                                      }
                                    },
                                  ),
                                ),
                              if (widget.type == OrderType.dineIn)
                                Expanded(
                                  child: CustomButton(
                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                    child: Text(
                                      'Order'.tr,
                                      style: kStyleTextButton,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.red,
                                    onPressed: () async {
                                      if (_cartModel.items.isEmpty) {
                                        Fluttertoast.showToast(msg: 'Please add items'.tr);
                                      } else {
                                        await _saveDineIn();
                                        Get.back();
                                      }
                                    },
                                  ),
                                ),
                              if (widget.type == OrderType.dineIn)
                                Expanded(
                                  child: CustomButton(
                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                    child: Text(
                                      'Check Out'.tr,
                                      style: kStyleTextButton,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.green,
                                    onPressed: () async {
                                      if (_cartModel.items.isEmpty) {
                                        Fluttertoast.showToast(msg: 'Please add items'.tr);
                                      } else if (_dineInChangedOrder) {
                                        Fluttertoast.showToast(msg: 'Please save order'.tr);
                                      } else {
                                        // await _saveDineIn();
                                        Get.to(() => PayScreen(cart: widget.dineIn!.cart, tableId: widget.dineIn!.tableId));
                                      }
                                    },
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
            ],
          ),
        ),
      ),
    );
  }
}
