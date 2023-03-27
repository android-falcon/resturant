import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/all_data/company_config_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/config_screen.dart';
import 'package:restaurant_system/screens/home_screen.dart';
import 'package:restaurant_system/screens/network_log_screen.dart';
import 'package:restaurant_system/screens/printer_config_screen.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/validation.dart';
import 'package:restaurant_system/utils/assets.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      RestApi.getData();
      RestApi.getCashLastSerials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.kAssetsLoginBackground),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 5),
                  child: Form(
                    key: _keyForm,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                              child: Text(
                                'Log In'.tr,
                                textAlign: TextAlign.right,
                                style: kStyleTextTable.copyWith(fontSize: 18.sp),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                              child: Text(
                                'Username'.tr,
                                textAlign: TextAlign.right,
                                style: kStyleHint.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          controller: _controllerUsername,
                          fillColor: ColorsApp.gray_light,
                          borderColor: ColorsApp.gray_light,
                          maxLines: 1,
                          validator: (value) {
                            return Validation.isRequired(value);
                          },
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5, top: 5),
                              child: Text(
                                'Password'.tr,
                                textAlign: TextAlign.right,
                                style: kStyleHint.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        CustomTextField(
                          controller: _controllerPassword,
                          fillColor: ColorsApp.gray_light,
                          borderColor: ColorsApp.gray_light,
                          obscureText: true,
                          isPass: true,
                          maxLines: 1,
                          validator: (value) {
                            return Validation.isRequired(value);
                          },
                        ),
                        CustomButton(
                          child: Text(
                            'Log In'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: ColorsApp.primaryColor,
                          borderRadius: 5,
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(FocusNode());
                            if (_controllerUsername.text.isEmpty && _controllerPassword.text == "Printer@admin") {
                              _controllerPassword.text = '';
                              Get.to(() => const PrinterConfigScreen());
                            } else if (_controllerUsername.text.isEmpty && _controllerPassword.text == "Falcons@admin") {
                              _controllerPassword.text = '';
                              Get.to(() => const ConfigScreen())!.then((value) {
                                RestApi.restDio.options.baseUrl = mySharedPreferences.baseUrl;
                                RestApi.getData();
                                RestApi.getCashLastSerials();
                              });
                            } else if (_controllerUsername.text.isEmpty && _controllerPassword.text == "NetworkLog@admin") {
                              _controllerPassword.text = '';
                              Get.to(() => const NetworkLogScreen());
                            } else if (_keyForm.currentState!.validate()) {
                              var indexEmployee = allDataModel.employees.indexWhere((element) => element.username == _controllerUsername.text && element.password == _controllerPassword.text && !element.isKitchenUser);
                              if (indexEmployee != -1) {
                                mySharedPreferences.employee = allDataModel.employees[indexEmployee];
                                mySharedPreferences.dailyClose = allDataModel.posClose;
                                if (allDataModel.companyConfig.isEmpty) {
                                  allDataModel.companyConfig.add(CompanyConfigModel.fromJson({}));
                                }
                                var indexPointOfSales = allDataModel.pointOfSalesModel.indexWhere((element) => element.posNo == mySharedPreferences.posNo);
                                if (indexPointOfSales != -1) {
                                  mySharedPreferences.orderNo = allDataModel.pointOfSalesModel[indexPointOfSales].orderNo;
                                }
                                Get.offAll(() => const HomeScreen());
                              } else {
                                Fluttertoast.showToast(msg: 'Incorrect username or password'.tr, timeInSecForIosWeb: 3);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(Assets.kAssetsLoginBack),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10, left: 10, right: 5, top: 60),
                        child: RichText(
                          text: TextSpan(
                            text: 'Welcome',
                            style: kStyleHint.copyWith(fontSize: 30.sp, color: companyType == CompanyType.umniah ? Colors.white : ColorsApp.black),
                            // children:  <TextSpan>[
                            //   TextSpan(text: 'Welcom'.tr, style: kStyleHint.copyWith(fontSize: 30.sp,color: ColorsApp.orange_light)),
                            //
                            // ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                      child: Text(
                        'Restaurant Management System.'.tr,
                        textAlign: TextAlign.left,
                        style: kStyleTextDefault.copyWith(color: ColorsApp.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
