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
import 'package:restaurant_system/models/all_data/item_model.dart';
import 'package:restaurant_system/models/all_data/item_sub_items_model.dart';
import 'package:restaurant_system/models/all_data/item_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/item_with_questions_model.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/dine_in_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/pay_screen.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/measure_size_widget.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enum_discount_type.dart';
import 'package:restaurant_system/utils/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/utils.dart';
import 'package:restaurant_system/utils/validation.dart';
import 'package:uuid/uuid.dart';

class OrderScreen extends StatefulWidget {
  final OrderType type;
  final int? tableId;

  const OrderScreen({Key? key, required this.type, this.tableId}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isShowItem = false;
  int _selectedCategoryId = 0;
  late CartModel _cartModel;
  int _indexItemSelect = -1;
  double maxHeightItem = 0;
  List<DineInModel> dineInSaved = [];
  int indexTable = -1;

  @override
  initState() {
    super.initState();
    if (widget.type == OrderType.dineIn) {
      dineInSaved = mySharedPreferences.dineIn;
      indexTable = dineInSaved.indexWhere((element) => element.tableId == widget.tableId!);
      if (indexTable != -1) {
        _cartModel = dineInSaved[indexTable].cart;
      }
    } else {
      _cartModel = CartModel.init(orderType: widget.type);
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
    return _priceChange == null ? priceChange : double.parse(_priceChange);
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
    return _modifiers ?? [];
  }

  Future<List<CartItemQuestionModel>> _showForceQuestionDialog({required List<ItemWithQuestionsModel> questionsItem}) async {
    List<CartItemQuestionModel> answersModifire = List<CartItemQuestionModel>.from(questionsItem.map((e) => CartItemQuestionModel(id: e.forceQuestionId, question: e.qtext, modifiers: [])));

    int i = 0;
    while (i < answersModifire.length) {
      log('ananan $i');
      var modifireForceQuestions = allDataModel.modifireForceQuestions.indexWhere((element) => element.forceQuestion.id == answersModifire[i].id && element.modifires.isNotEmpty);
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
                      '(${answersModifire[i].id}) - ${answersModifire[i].question}?',
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
                              value: answersModifire[i].modifiers.any((element) => element == allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name),
                              onChanged: (value) {
                                if (value!) {
                                  answersModifire[i].modifiers.add(allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name);
                                } else {
                                  answersModifire[i].modifiers.remove(allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name);
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
                              value: allDataModel.modifireForceQuestions[modifireForceQuestions].modifires[indexModifire].name,
                              groupValue: answersModifire[i].modifiers.isEmpty ? '' : answersModifire[i].modifiers.first,
                              onChanged: (value) {
                                if (answersModifire[i].modifiers.isEmpty) {
                                  answersModifire[i].modifiers.add(value as String);
                                } else {
                                  answersModifire[i].modifiers[0] = value as String;
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
    answersModifire.removeWhere((element) => element.modifiers.isEmpty);
    return answersModifire;
  }

  Future<List<CartItemModel>> _showSubItemDialog({required List<ItemSubItemsModel> subItems, required String parentRandomId, required int parentQty}) async {
    List<CartItemModel> _cartSubItem = [];
    List<ItemModel> _subItems = allDataModel.items.where((item) => subItems.any((subItem) => item.id == subItem.subitemId)).toList();
    await Get.dialog(
      CustomDialog(
        builder: (context, setState, constraints) => Column(
          children: [
            Text(
              'Sub Item'.tr,
              style: kStyleTextTitle,
            ),
            const Divider(thickness: 2),
            StaggeredGrid.count(
              crossAxisCount: 2,
              children: _subItems
                  .map((e) => Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          side: _cartSubItem.any((element) => element.id == e.id) ? const BorderSide(width: 1) : BorderSide.none,
                        ),
                        elevation: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5.r),
                          onTap: () async {
                            var indexSubItem = _cartSubItem.indexWhere((element) => element.id == e.id);
                            if (indexSubItem != -1) {
                              _cartSubItem.removeAt(indexSubItem);
                            } else {
                              _cartSubItem.add(CartItemModel(
                                uuid: const Uuid().v1(),
                                parentUuid: parentRandomId,
                                orderType: widget.type,
                                id: e.id,
                                categoryId: e.category.id,
                                taxType: e.taxType.id,
                                taxPercent: e.taxPercent.percent,
                                name: e.menuName,
                                qty: parentQty,
                                price: e.price,
                                priceChange: e.price,
                                total: e.price * parentQty,
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
                                        e.price.toStringAsFixed(2),
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
                      _cartSubItem = [];
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
    return _cartSubItem;
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

  _calculateOrder() {
    if (allDataModel.companyConfig.first.taxCalcMethod == 0) {
      // خاضع
      for (var element in _cartModel.items) {
        element.total = element.priceChange * element.qty;
        element.totalLineDiscount = (element.lineDiscountType == DiscountType.percentage ? element.priceChange * (element.lineDiscount / 100) : element.lineDiscount) * element.qty;
      }
      _cartModel.total = _cartModel.items.fold(0.0, (sum, item) => sum + item.total);
      _cartModel.totalLineDiscount = _cartModel.items.fold(0.0, (sum, item) => sum + item.totalLineDiscount);
      _cartModel.totalDiscount = _cartModel.discountType == DiscountType.percentage ? _cartModel.total * (_cartModel.discount / 100) : _cartModel.discount;
      _cartModel.service = widget.type == OrderType.takeAway ? 0 : _cartModel.total * (allDataModel.companyConfig.first.servicePerc / 100);
      _cartModel.serviceTax = widget.type == OrderType.takeAway ? 0 : _cartModel.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
      double totalDiscountAvailableItem = _cartModel.items.fold(0.0, (sum, item) => sum + (item.discountAvailable ? item.total : 0));
      for (var element in _cartModel.items) {
        if (element.discountAvailable) {
          element.discount = _cartModel.totalDiscount * (element.total / totalDiscountAvailableItem);
        } else {
          element.discount = 0;
        }
        element.tax = element.taxType == 2 ? 0 : (element.total - element.totalLineDiscount - element.discount) * (element.taxPercent / 100);
        element.service = _cartModel.service * (element.total / _cartModel.total);
        element.serviceTax = element.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
      }
      _cartModel.subTotal = _cartModel.total - _cartModel.totalDiscount - _cartModel.totalLineDiscount;
      _cartModel.itemsTax = _cartModel.items.fold(0.0, (sum, item) => sum + item.tax);
      _cartModel.tax = _cartModel.itemsTax + _cartModel.serviceTax;
      _cartModel.amountDue = _cartModel.subTotal + _cartModel.deliveryCharge + _cartModel.service + _cartModel.tax;

    } else {
      // شامل
      for (var element in _cartModel.items) {
        element.total = (element.priceChange - (element.priceChange * (element.taxPercent / 100))) * element.qty;
        element.totalLineDiscount = (element.lineDiscountType == DiscountType.percentage ? element.total * (element.lineDiscount / 100) : element.lineDiscount) * element.qty;
      }
      _cartModel.total = _cartModel.items.fold(0.0, (sum, item) => sum + item.total);
      _cartModel.totalLineDiscount = _cartModel.items.fold(0.0, (sum, item) => sum + item.totalLineDiscount);
      _cartModel.totalDiscount = _cartModel.discountType == DiscountType.percentage ? _cartModel.total * (_cartModel.discount / 100) : _cartModel.discount;
      _cartModel.service = widget.type == OrderType.takeAway ? 0 : _cartModel.total * (allDataModel.companyConfig.first.servicePerc / 100);
      _cartModel.serviceTax = widget.type == OrderType.takeAway ? 0 : _cartModel.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
      double totalDiscountAvailableItem = _cartModel.items.fold(0.0, (sum, item) => sum + (item.discountAvailable ? item.total : 0));
      for (var element in _cartModel.items) {
        if (element.discountAvailable) {
          element.discount = _cartModel.totalDiscount * (element.total / totalDiscountAvailableItem);
        } else {
          element.discount = 0;
        }
        element.tax = element.taxType == 2 ? 0 : (element.total - element.totalLineDiscount - element.discount) * (element.taxPercent / 100);
        element.service = _cartModel.service * (element.total / _cartModel.total);
        element.serviceTax = element.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
      }
      _cartModel.subTotal = _cartModel.total - _cartModel.totalDiscount - _cartModel.totalLineDiscount;
      _cartModel.itemsTax = _cartModel.items.fold(0.0, (sum, item) => sum + item.tax);
      _cartModel.tax = _cartModel.itemsTax + _cartModel.serviceTax;
      _cartModel.amountDue = _cartModel.subTotal + _cartModel.deliveryCharge + _cartModel.service + _cartModel.tax;
    }
    setState(() {});
  }

  _saveDineIn() {
    if (!dineInSaved[indexTable].isOpen) {
      RestApi.openTable(dineInSaved[indexTable].tableId);
      dineInSaved[indexTable].isOpen = true;
    }
    dineInSaved[indexTable].cart = _cartModel;
    mySharedPreferences.dineIn = dineInSaved;
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
          return await _showExitOrderScreenDialog();
        }
      },
      child: Scaffold(
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
                        if (_isShowItem) {
                          maxHeightItem = 0;
                          _isShowItem = false;
                          setState(() {});
                        } else {
                          _showExitOrderScreenDialog().then((value) {
                            if (value) {
                              Get.back();
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.type == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault,
                    ),
                    SizedBox(width: 4.w),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: Text(
                        '${'VocNo'.tr} : ${mySharedPreferences.inVocNo}',
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
                    if (widget.type == OrderType.dineIn)
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
                    if (widget.type == OrderType.dineIn)
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
                        DateFormat('yyyy-MM-dd').format(DateTime.now()),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault,
                      ),
                    ),
                    if (widget.type == OrderType.dineIn)
                      Row(
                        children: [
                          const VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Image.asset(
                            'assets/images/waiter.png',
                            height: 45.h,
                          ),
                          Text(
                            'Ali Ahmad',
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: kStyleTextDefault,
                          ),
                        ],
                      ),
                    // if (widget.type == OrderType.dineIn)
                    //   Row(
                    //     children: [
                    //       SizedBox(width: 4.w),
                    //       const VerticalDivider(
                    //         width: 1,
                    //         thickness: 2,
                    //       ),
                    //       Image.asset(
                    //         'assets/images/kitchen.png',
                    //         height: 45.h,
                    //       ),
                    //       Text(
                    //         '2',
                    //         textAlign: TextAlign.center,
                    //         overflow: TextOverflow.ellipsis,
                    //         maxLines: 1,
                    //         style: kStyleTextDefault,
                    //       ),
                    //     ],
                    //   ),
                    if (widget.type == OrderType.dineIn)
                      Row(
                        children: [
                          SizedBox(width: 4.w),
                          const VerticalDivider(
                            width: 1,
                            thickness: 2,
                          ),
                          Image.asset(
                            'assets/images/guests.png',
                            height: 45.h,
                          ),
                          Text(
                            '2',
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
                          crossAxisCount: _isShowItem ? 2 : 3,
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
                                          // var indexItem = _cartModel.items.indexWhere((element) => element.id == e.id && !element.isDeleted);
                                          // if (indexItem != -1) {
                                          //   var questionsItem = allDataModel.itemWithQuestions.where((element) => element.itemsId == _cartModel.items[indexItem].id).toList();
                                          //   if (questionsItem.isNotEmpty) {
                                          //     var questions = await _showForceQuestionDialog(questionsItem: questionsItem);
                                          //     var items = _cartModel.items.where((element) => element.id == e.id).toList();
                                          //     var equalItem = items.indexWhere((element) => listsAreEqual(element.questions, questions));
                                          //     if (equalItem != -1) {
                                          //       items[equalItem].qty += 1;
                                          //       items[equalItem].total = items[equalItem].qty * items[equalItem].priceChange;
                                          //     } else {
                                          //       _cartModel.items.add(CartItemModel(
                                          //         orderType: widget.type,
                                          //         id: e.id,
                                          //         categoryId: e.category.id,
                                          //         taxType: e.taxType.id,
                                          //         taxPercent: e.taxPercent.percent,
                                          //         name: e.menuName,
                                          //         qty: 1,
                                          //         price: e.price,
                                          //         priceChange: e.price,
                                          //         total: e.price,
                                          //         tax: 0,
                                          //         discountAvailable: e.discountAvailable == 1,
                                          //         openPrice: e.openPrice == 1,
                                          //         rowSerial: _cartModel.items.length + 1,
                                          //       ));
                                          //       _cartModel.items.last.questions = questions;
                                          //     }
                                          //   } else {
                                          //     _cartModel.items[indexItem].qty += 1;
                                          //     _cartModel.items[indexItem].total = _cartModel.items[indexItem].qty * _cartModel.items[indexItem].priceChange;
                                          //   }
                                          // } else {
                                          _cartModel.items.add(CartItemModel(
                                            uuid: const Uuid().v1(),
                                            parentUuid: '',
                                            orderType: widget.type,
                                            id: e.id,
                                            categoryId: e.category.id,
                                            taxType: e.taxType.id,
                                            taxPercent: e.taxPercent.percent,
                                            name: e.menuName,
                                            qty: 1,
                                            price: e.price,
                                            priceChange: e.price,
                                            total: e.price,
                                            tax: 0,
                                            discountAvailable: e.discountAvailable == 1,
                                            openPrice: e.openPrice == 1,
                                            rowSerial: _cartModel.items.length + 1,
                                          ));

                                          var questionsItem = allDataModel.itemWithQuestions.where((element) => element.itemsId == e.id).toList();
                                          if (questionsItem.isNotEmpty) {
                                            var questions = await _showForceQuestionDialog(questionsItem: questionsItem);
                                            _cartModel.items.last.questions = questions;
                                          }
                                          // }

                                          _calculateOrder();
                                          setState(() {});
                                        },
                                        child: SizedBox(
                                          height: maxHeightItem == 0 ? null : maxHeightItem,
                                          child: MeasureSize(
                                            onChange: (size) {
                                              if (size.height > maxHeightItem) {
                                                maxHeightItem = size.height;
                                                setState(() {});
                                              }
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
                                                          e.price.toStringAsFixed(2),
                                                          style: kStyleTextTitle,
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
                                  )
                                  .toList()
                              : allDataModel.categories
                                  .map((e) => Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.r),
                                        ),
                                        elevation: 0,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(5.r),
                                          onTap: () {
                                            _selectedCategoryId = e.id;
                                            _isShowItem = true;
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CachedNetworkImage(
                                                  imageUrl: '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'Categories')?.imgPath ?? ''}${e.categoryPic}',
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
                                                Text(
                                                  '${e.categoryName}\n',
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  style: kStyleTextTitle,
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
                      width: 110.w,
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      child: Column(
                        children: [
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
                                        itemCount: _cartModel.items.length,
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (context, index) => const Divider(color: Colors.black, height: 1),
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
                                                              _cartModel.items[index].priceChange.toStringAsFixed(2),
                                                              style: kStyleDataTable,
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              _cartModel.items[index].total.toStringAsFixed(2),
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
                                                            itemCount: _cartModel.items[index].questions.length,
                                                            shrinkWrap: true,
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            itemBuilder: (context, indexQuestions) => Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Text(
                                                                        '• ${_cartModel.items[index].questions[indexQuestions].question.trim()}?',
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
                                                                              '   * ${_cartModel.items[index].questions[indexQuestions].modifiers[indexModifiers]}',
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
                                                                    '• ${_cartModel.items[index].modifiers[indexModifiers].name} * ${_cartModel.items[index].modifiers[indexModifiers].modifier}',
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
                                                                      child: Text(
                                                                        '• ',
                                                                        style: kStyleDataTableModifiers,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 3,
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
                                                                        subItem[indexSubItem].priceChange.toStringAsFixed(2),
                                                                        style: kStyleDataTableModifiers,
                                                                        textAlign: TextAlign.center,
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child: Text(
                                                                        subItem[indexSubItem].total.toStringAsFixed(2),
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
                                            _cartModel.discount.toStringAsFixed(3),
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
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (widget.type == OrderType.takeAway)
                                Expanded(
                                  child: CustomButton(
                                    margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                                    child: Text(
                                      'Pay'.tr,
                                      style: kStyleTextButton,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.green,
                                    onPressed: () {
                                      if (_cartModel.items.isNotEmpty) {
                                        Get.to(() => PayScreen(cart: _cartModel));
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
                                    onPressed: () {
                                      _saveDineIn();
                                      Get.back();
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
              Container(
                width: double.infinity,
                height: 50.h,
                color: ColorsApp.accentColor,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_indexItemSelect != -1) {
                            var subItems = allDataModel.itemSubItems.where((element) => element.itemsId == _cartModel.items[_indexItemSelect].id).toList();
                            if (subItems.isNotEmpty) {
                              var cartSubItems = await _showSubItemDialog(subItems: subItems, parentRandomId: _cartModel.items[_indexItemSelect].uuid, parentQty: _cartModel.items[_indexItemSelect].qty);
                              _cartModel.items.addAll(cartSubItems);
                              setState(() {});
                            } else {
                              Fluttertoast.showToast(msg: 'This item cannot be sub item'.tr);
                            }
                          } else {
                            Fluttertoast.showToast(msg: 'Please select the item you want to sub item'.tr);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Sub Item'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_indexItemSelect != -1) {
                            _cartModel.items[_indexItemSelect].qty = await _showQtyDialog(rQty: _cartModel.items[_indexItemSelect].qty, minQty: 1);
                            for (var element in _cartModel.items) {
                              if (element.uuid == _cartModel.items[_indexItemSelect].parentUuid) {
                                element.qty = _cartModel.items[_indexItemSelect].qty;
                              }
                            }
                            _calculateOrder();
                          } else {
                            Fluttertoast.showToast(msg: 'Please select the item you want to change quantity'.tr);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Qty'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
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
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Modifier'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_indexItemSelect != -1) {
                            Get.defaultDialog(
                              title: '${'Are you sure to remove the'.tr} ${_cartModel.items[_indexItemSelect].name} ${'item'.tr}?',
                              titleStyle: kStyleTextTitle,
                              content: Container(),
                              textCancel: 'Cancel'.tr,
                              textConfirm: 'Confirm'.tr,
                              confirmTextColor: Colors.white,
                              onConfirm: () {
                                _cartModel.items.removeWhere((element) => element.parentUuid == _cartModel.items[_indexItemSelect].uuid);
                                _cartModel.items.removeAt(_indexItemSelect);
                                _indexItemSelect = -1;
                                Get.back();
                              },
                            ).then((value) {
                              _calculateOrder();
                            });
                          } else {
                            Fluttertoast.showToast(msg: 'Please select the item you want to remove'.tr);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Void'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          _cartModel.deliveryCharge = await _showDeliveryDialog(delivery: _cartModel.deliveryCharge);
                          _calculateOrder();
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Delivery'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_indexItemSelect != -1) {
                            if (_cartModel.items[_indexItemSelect].discountAvailable) {
                              var result = await _showDiscountDialog(
                                discount: _cartModel.items[_indexItemSelect].lineDiscount,
                                price: _cartModel.items[_indexItemSelect].priceChange,
                                type: _cartModel.items[_indexItemSelect].lineDiscountType,
                              );
                              _cartModel.items[_indexItemSelect].lineDiscount = result['discount'];
                              _cartModel.items[_indexItemSelect].lineDiscountType = result['type'];
                              _calculateOrder();
                            } else {
                              Fluttertoast.showToast(msg: 'Line discount is not available for this item'.tr);
                            }
                          } else {
                            Fluttertoast.showToast(msg: 'Please select the item you want to line discount'.tr);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Line Discount'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_cartModel.items.any((element) => element.discountAvailable)) {
                            var result = await _showDiscountDialog(
                              discount: _cartModel.discount,
                              price: _cartModel.total,
                              type: _cartModel.discountType,
                            );
                            _cartModel.discount = result['discount'];
                            _cartModel.discountType = result['type'];
                            _calculateOrder();
                          } else {
                            Fluttertoast.showToast(msg: 'No items accept discount in order'.tr);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Discount'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    if (widget.type == OrderType.dineIn)
                      Expanded(
                        child: InkWell(
                          onTap: () {},
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Center(
                              child: Text(
                                'Split'.tr,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: kStyleTextDefault,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (_indexItemSelect != -1) {
                            if (_cartModel.items[_indexItemSelect].openPrice) {
                              _cartModel.items[_indexItemSelect].priceChange = await _showPriceChangeDialog(itemPrice: _cartModel.items[_indexItemSelect].price, priceChange: _cartModel.items[_indexItemSelect].priceChange);
                              _calculateOrder();
                            } else {
                              Fluttertoast.showToast(msg: 'Price change is not available for this item'.tr);
                            }
                          } else {
                            Fluttertoast.showToast(msg: 'Please select the item you want to price change'.tr);
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: Center(
                            child: Text(
                              'Price Change'.tr,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: kStyleTextDefault,
                            ),
                          ),
                        ),
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
