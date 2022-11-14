import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/loading_dialog.dart';
import 'package:restaurant_system/screens/widgets/num_pad.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_discount_type.dart';
import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/validation.dart';

bool isNotEmpty(String? s) => s != null && s.isNotEmpty;

bool isEmpty(String? s) => s == null || s.isEmpty;

bool listsAreEqual(List one, List two) {
  var i = -1;
  if (one.isEmpty && two.isEmpty) {
    return true;
  }
  if (one.length != two.length) {
    return false;
  }
  return one.every((element) {
    i++;

    return two[i] == element;
  });
}

CartModel calculateOrder({required CartModel cart, required OrderType orderType, InvoiceKind invoiceKind = InvoiceKind.invoicePay}) {
  if (allDataModel.companyConfig.first.taxCalcMethod == 0) {
    // خاضع
    switch (invoiceKind) {
      case InvoiceKind.invoicePay:
        for (var element in cart.items) {
          element.total = element.priceChange * element.qty;
          element.totalLineDiscount = (element.lineDiscountType == DiscountType.percentage ? element.priceChange * (element.lineDiscount / 100) : element.lineDiscount) * element.qty;
        }
        break;
      case InvoiceKind.invoiceReturn:
        for (var element in cart.items) {
          element.returnedPrice = element.priceChange - element.lineDiscount - element.discount;
          element.returnedTotal = element.returnedPrice * element.returnedQty;
          element.total = element.priceChange * element.returnedQty;
          element.totalLineDiscount = (element.lineDiscountType == DiscountType.percentage ? element.priceChange * (element.lineDiscount / 100) : element.lineDiscount) * element.returnedQty;
        }
        break;
    }
    cart.total = cart.items.fold(0.0, (sum, item) => sum + item.total);
    cart.totalLineDiscount = cart.items.fold(0.0, (sum, item) => sum + item.totalLineDiscount);
    cart.totalDiscount = cart.discountType == DiscountType.percentage ? (cart.total - cart.totalLineDiscount) * (cart.discount / 100) : cart.discount;
    cart.service = orderType == OrderType.takeAway ? 0 : cart.total * (allDataModel.companyConfig.first.servicePerc / 100);
    cart.serviceTax = orderType == OrderType.takeAway ? 0 : cart.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
    double totalDiscountAvailableItem = cart.items.fold(0.0, (sum, item) => sum + (item.discountAvailable ? (item.total - item.totalLineDiscount) : 0));
    for (var element in cart.items) {
      if (element.discountAvailable) {
        element.discount = cart.totalDiscount * ((element.total - element.totalLineDiscount) / totalDiscountAvailableItem);
      } else {
        element.discount = 0;
      }
      element.tax = element.taxType == 2 ? 0 : (element.total - element.totalLineDiscount - element.discount) * (element.taxPercent / 100);
      element.service = cart.service * (element.total / cart.total);
      element.serviceTax = element.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
    }
    cart.subTotal = cart.total - cart.totalDiscount - cart.totalLineDiscount;
    cart.itemsTax = cart.items.fold(0.0, (sum, item) => sum + item.tax);
    cart.tax = cart.itemsTax + cart.serviceTax;
    cart.amountDue = cart.subTotal + cart.deliveryCharge + cart.service + cart.tax;
  } else {
    // شامل
    switch (invoiceKind) {
      case InvoiceKind.invoicePay:
        for (var element in cart.items) {
          element.total = (element.priceChange / (1 + (element.taxPercent / 100))) * element.qty;
          element.totalLineDiscount = (element.lineDiscountType == DiscountType.percentage ? element.total * (element.lineDiscount / 100) : element.lineDiscount) * element.qty;
        }
        break;
      case InvoiceKind.invoiceReturn:
        for (var element in cart.items) {
          element.returnedPrice = (element.priceChange / (1 + (element.taxPercent / 100))) - element.lineDiscount - element.discount;
          element.returnedTotal = element.returnedPrice * element.returnedQty;
          element.total = (element.priceChange / (1 + (element.taxPercent / 100))) * element.returnedQty;
          element.totalLineDiscount = (element.lineDiscountType == DiscountType.percentage ? element.total * (element.lineDiscount / 100) : element.lineDiscount) * element.returnedQty;
        }
        break;
    }
    cart.total = cart.items.fold(0.0, (sum, item) => sum + item.total);
    cart.totalLineDiscount = cart.items.fold(0.0, (sum, item) => sum + item.totalLineDiscount);
    cart.totalDiscount = cart.discountType == DiscountType.percentage ? (cart.total - cart.totalLineDiscount) * (cart.discount / 100) : cart.discount;
    cart.service = orderType == OrderType.takeAway ? 0 : cart.total * (allDataModel.companyConfig.first.servicePerc / 100);
    cart.serviceTax = orderType == OrderType.takeAway ? 0 : cart.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
    double totalDiscountAvailableItem = cart.items.fold(0.0, (sum, item) => sum + (item.discountAvailable ? (item.total - item.totalLineDiscount) : 0));
    for (var element in cart.items) {
      if (element.discountAvailable) {
        element.discount = cart.totalDiscount * ((element.total - element.totalLineDiscount) / totalDiscountAvailableItem);
      } else {
        element.discount = 0;
      }
      element.tax = element.taxType == 2 ? 0 : (element.total - element.totalLineDiscount - element.discount) * (element.taxPercent / 100);
      element.service = cart.service * (element.total / cart.total);
      element.serviceTax = element.service * (allDataModel.companyConfig.first.serviceTaxPerc / 100);
    }
    cart.subTotal = cart.total - cart.totalDiscount - cart.totalLineDiscount;
    cart.itemsTax = cart.items.fold(0.0, (sum, item) => sum + item.tax);
    cart.tax = cart.itemsTax + cart.serviceTax;
    cart.amountDue = cart.subTotal + cart.deliveryCharge + cart.service + cart.tax;
  }
  return cart;
}

showLoginDialog() async {
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  await Get.dialog(
    CustomDialog(
      gestureDetectorOnTap: () {},
      builder: (context, setState, constraints) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _keyForm,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomTextField(
                    controller: _controllerUsername,
                    label: Text('Username'.tr),
                    maxLines: 1,
                    validator: (value) {
                      return Validation.isRequired(value);
                    },
                  ),
                  CustomTextField(
                    controller: _controllerPassword,
                    label: Text('Password'.tr),
                    obscureText: true,
                    isPass: true,
                    maxLines: 1,
                    validator: (value) {
                      return Validation.isRequired(value);
                    },
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
                          child: Text('Sign In'.tr),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (_keyForm.currentState!.validate()) {
                              var indexEmployee = allDataModel.employees.indexWhere((element) => element.username == _controllerUsername.text && element.password == _controllerPassword.text && !element.isKitchenUser);
                              if (indexEmployee != -1) {
                                mySharedPreferences.employee = allDataModel.employees[indexEmployee];
                                Get.back();
                              } else {
                                Fluttertoast.showToast(msg: 'Incorrect username or password'.tr, timeInSecForIosWeb: 3);
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
          ),
        ],
      ),
    ),
    barrierDismissible: false,
  );
}

showLoadingDialog([String? text]) {
  log('showLoadingIndicator Called !!');
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: LoadingDialog(
        title: text ?? 'Loading ...'.tr,
      ),
    ),
    barrierDismissible: false,
    useSafeArea: false,
  );
}

hideLoadingDialog() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}

Future<bool> showAreYouSureDialog({required String title}) async {
  var result = await Get.defaultDialog(
    title: title,
    titleStyle: kStyleTextTitle,
    content: Text('Are you sure?'.tr),
    textCancel: 'Cancel'.tr,
    textConfirm: 'Confirm'.tr,
    confirmTextColor: Colors.white,
    onConfirm: () {
      Get.back(result: true);
    },
    barrierDismissible: true,
  );
  return result ?? false;
}

Widget numPadWidget(
  TextEditingController? controller,
  void Function(Function()) setState, {
  bool decimal = true,
  Function()? onSubmit,
  Function()? onExit,
}) {
  void addNumber(TextEditingController? controller, int number) {
    if (controller != null) {
      if (controller.text.contains('.')) {
        var split = controller.text.split('.');
        if (split[1].length < 3) {
          controller.text += '$number';
        }
      } else {
        controller.text += '$number';
        controller.text = '${int.parse(controller.text)}';
      }
    }
  }

  return NumPad(
    controller: controller,
    onSubmit: onSubmit,
    onExit: onExit ??
        () {
          Get.back();
        },
    onPressed1: () {
      addNumber(controller, 1);
      setState(() {});
    },
    onPressed2: () {
      addNumber(controller, 2);
      setState(() {});
    },
    onPressed3: () {
      addNumber(controller, 3);
      setState(() {});
    },
    onPressed4: () {
      addNumber(controller, 4);
      setState(() {});
    },
    onPressed5: () {
      addNumber(controller, 5);
      setState(() {});
    },
    onPressed6: () {
      addNumber(controller, 6);
      setState(() {});
    },
    onPressed7: () {
      addNumber(controller, 7);
      setState(() {});
    },
    onPressed8: () {
      addNumber(controller, 8);
      setState(() {});
    },
    onPressed9: () {
      addNumber(controller, 9);
      setState(() {});
    },
    onPressedDot: () {
      if (decimal) {
        if (controller != null) {
          if (!controller.text.contains('.')) {
            controller.text += '.';
          }
        }
        setState(() {});
      }
    },
    onPressed0: () {
      addNumber(controller, 0);
      setState(() {});
    },
    onPressedDelete: () {
      if (controller != null) {
        if (controller.text.length > 1) {
          var split = controller.text.split('');
          split.removeLast();
          controller.text = split.join();
        } else {
          controller.text = '0';
        }
      }
      setState(() {});
    },
  );
}
