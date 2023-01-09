import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _controllerBaseUrl = TextEditingController(text: mySharedPreferences.baseUrl);
  final TextEditingController _controllerPosNo = TextEditingController(text: '${mySharedPreferences.posNo}');
  final TextEditingController _controllerCashNo = TextEditingController(text: '${mySharedPreferences.cashNo}');
  final TextEditingController _controllerStoreNo = TextEditingController(text: '${mySharedPreferences.storeNo}');
  final TextEditingController _controllerInVocNo = TextEditingController(text: '${mySharedPreferences.inVocNo}');
  final TextEditingController _controllerOutVocNo = TextEditingController(text: '${mySharedPreferences.payInOutNo}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView (
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
            child: Column(
              children: [
                CustomTextField(
                  borderColor: ColorsApp.orange_2,
                  controller: _controllerBaseUrl,
                  label: Text('Base URL'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.orange_2,
                  controller: _controllerPosNo,
                  label: Text('POS No'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.orange_2,
                  controller: _controllerCashNo,
                  label: Text('Cash No'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.orange_2,
                  controller: _controllerStoreNo,
                  label: Text('Store No'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.orange_2,
                  controller: _controllerInVocNo,
                  label: Text('In Voc No'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.orange_2,
                  controller: _controllerOutVocNo,
                  label: Text('Pay In Out No'.tr),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          backgroundColor: ColorsApp.orange_2,
                          child: Text(
                            'Save'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            mySharedPreferences.clearData();
                            mySharedPreferences.baseUrl = _controllerBaseUrl.text;
                            mySharedPreferences.posNo = _controllerPosNo.text.isEmpty ? 0 : int.parse(_controllerPosNo.text);
                            mySharedPreferences.cashNo = _controllerCashNo.text.isEmpty ? 0 : int.parse(_controllerCashNo.text);
                            mySharedPreferences.storeNo = _controllerStoreNo.text.isEmpty ? 0 : int.parse(_controllerStoreNo.text);
                            mySharedPreferences.inVocNo = _controllerInVocNo.text.isEmpty ? 0 : int.parse(_controllerInVocNo.text);
                            mySharedPreferences.payInOutNo = _controllerOutVocNo.text.isEmpty ? 0 : int.parse(_controllerOutVocNo.text);
                            Get.back();
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          backgroundColor: ColorsApp.red_light,
                          child: Text(
                            'Cancel'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            Get.back();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
