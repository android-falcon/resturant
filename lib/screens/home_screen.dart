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

import '../utils/drawer.dart';

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
       appBar: AppBar(
         backgroundColor: UMNIA_FALG==1?ColorsApp.black:ColorsApp.backgroundDialog,
         iconTheme: IconThemeData(color: UMNIA_FALG==1?ColorsApp.orange_2:ColorsApp.black),
         title: Text( getTitleText(),
         textAlign: TextAlign.center,
         overflow: TextOverflow.ellipsis,
         maxLines: 1,
         style: UMNIA_FALG==1?kStyleTextButton:kStyleTextDefault,),
         centerTitle: true,


       ),
        drawer:
        ClipPath(
          // clipper: OvalRightBorderClipper(),
          child: Container(
            width: 120.w,
            child: Drawer(

              child:AppDrawer(),
            ),
          ),
        ),
        body: Stack(

          children: [

            Container(
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        SizedBox(height: 20.h),

                        Row(

                      children: [
                        SizedBox(width: 10.w,),
                        Image.asset(
                          'assets/images/takeway108.png',
                          height: 250.h,
                          width: 170.w,
                        ),
                        Column(

                          children: [
                            Image.asset(
                              'assets/images/choose109.png',
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
                                    onTap: () {
                                      Get.to(() => OrderScreen(type: OrderType.takeAway));
                                    },
                                    child: Container(

                                      width: 70.w,
                                      decoration:BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15.0,

                                          ),
                                          border: Border.all(color: ColorsApp.orange_2)
                                      ),
                                      child: Column(

                                        children: [
                                          Image.asset(
                                            'assets/images/take_away_.png',
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
                                  padding: EdgeInsets.symmetric(horizontal:6.w),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() => TableScreen());
                                    },
                                    child: Container(
                                      width: 70.w,
                                      decoration:BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            15.0,
                                          ),
                                          border: Border.all(color: ColorsApp.orange_2)
                                      ),
                                      child: Column(
                                        children: [
                                          Image.asset(
                                            'assets/images/dine_in_.png',
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
                        ]
                    )
                      ],
                    ),
                  ),
                  // Container(
                  //   height: 1.sh,
                  //   width: 80.w,
                  //   constraints: BoxConstraints(maxHeight: Get.height, maxWidth: Get.width),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(3.r),
                  //     border: Border.all(width: 2, color: ColorsApp.blue),
                  //     gradient: const LinearGradient(
                  //       colors: [
                  //         ColorsApp.primaryColor,
                  //         ColorsApp.accentColor,
                  //       ],
                  //       begin: Alignment.centerLeft,
                  //       end: Alignment.centerRight,
                  //     ),
                  //   ),
                  //   child: ListView.separated(
                  //     itemCount: _menu.length,
                  //     shrinkWrap: true,
                  //     separatorBuilder: (context, index) => Divider(
                  //       height: 1.h,
                  //       thickness: 2,
                  //     ),
                  //     itemBuilder: (context, index) => InkWell(
                  //       onTap: _menu[index].onTab,
                  //       child: Container(
                  //         padding: EdgeInsets.all(6.w),
                  //         width: double.infinity,
                  //         child: Text(
                  //           _menu[index].name,
                  //           style: kStyleTextTitle,
                  //           textAlign: TextAlign.center,
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getTitleText() {
   var today= DateFormat('yyyy-MM-dd').format(mySharedPreferences.dailyClose);
  var title=  '${'Branch'.tr}: ${allDataModel.companyConfig.first.companyName}  \t\t\t' +today;
  return title;
  }

  getLogo() {
    return   Image.asset(
      'assets/images/choose109.png',
      height: 40.h,
      width: 100.w,
    );
  }
}
