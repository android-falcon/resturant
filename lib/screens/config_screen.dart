import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
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
  final TextEditingController _controllerOutVocNo = TextEditingController(text: '${mySharedPreferences.outVocNo}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomSingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              CustomTextField(
                controller: _controllerBaseUrl,
                label: Text('Base URL'.tr),
              ),
              CustomTextField(
                controller: _controllerPosNo,
                label: Text('POS No'.tr),
              ),
              CustomTextField(
                controller: _controllerCashNo,
                label: Text('Cash No'.tr),
              ),
              CustomTextField(
                controller: _controllerStoreNo,
                label: Text('Store No'.tr),
              ),
              CustomTextField(
                controller: _controllerInVocNo,
                label: Text('In Voc No'.tr),
              ),
              CustomTextField(
                controller: _controllerOutVocNo,
                label: Text('Out Voc No'.tr),
              ),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      child: Text('Save'.tr),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        mySharedPreferences.clearData();
                        mySharedPreferences.baseUrl = _controllerBaseUrl.text;
                        mySharedPreferences.posNo = _controllerPosNo.text.isEmpty ? 0 : int.parse(_controllerPosNo.text);
                        mySharedPreferences.cashNo = _controllerCashNo.text.isEmpty ? 0 : int.parse(_controllerCashNo.text);
                        mySharedPreferences.storeNo = _controllerStoreNo.text.isEmpty ? 0 : int.parse(_controllerStoreNo.text);
                        mySharedPreferences.inVocNo = _controllerInVocNo.text.isEmpty ? 0 : int.parse(_controllerInVocNo.text);
                        mySharedPreferences.outVocNo = _controllerOutVocNo.text.isEmpty ? 0 : int.parse(_controllerOutVocNo.text);
                        Get.back();
                      },
                    ),
                  ),
                  Expanded(
                    child: CustomButton(
                      child: Text('Cancel'.tr),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        Get.back();
                      },
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
