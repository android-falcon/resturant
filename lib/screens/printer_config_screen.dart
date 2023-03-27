import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

class PrinterConfigScreen extends StatefulWidget {
  const PrinterConfigScreen({Key? key}) : super(key: key);

  @override
  State<PrinterConfigScreen> createState() => _PrinterConfigScreenState();
}

class _PrinterConfigScreenState extends State<PrinterConfigScreen> {
  final TextEditingController _controllerWidth = TextEditingController(text: '${mySharedPreferences.printerWidth}');
  final TextEditingController _controllerDataPrinter = TextEditingController(text: '${mySharedPreferences.sizeDataPrinter}');
  final TextEditingController _controllerTitlePrinter = TextEditingController(text: '${mySharedPreferences.sizeTitlePrinter}');
  final TextEditingController _controllerLargePrinter = TextEditingController(text: '${mySharedPreferences.sizeLargePrinter}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 2),
            child: Column(
              children: [
                CustomTextField(
                  borderColor: ColorsApp.primaryColor,
                  controller: _controllerWidth,
                  label: Text('Width'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.primaryColor,
                  controller: _controllerDataPrinter,
                  label: Text('Data Printer'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.primaryColor,
                  controller: _controllerTitlePrinter,
                  label: Text('Title Printer'.tr),
                ),
                CustomTextField(
                  borderColor: ColorsApp.primaryColor,
                  controller: _controllerLargePrinter,
                  label: Text('Large Printer'.tr),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          backgroundColor: ColorsApp.primaryColor,
                          child: Text(
                            'Save'.tr,
                            style: const TextStyle(color: Colors.white),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            mySharedPreferences.printerWidth = _controllerWidth.text.isEmpty ? 0 : int.parse(_controllerWidth.text);
                            mySharedPreferences.sizeDataPrinter = _controllerDataPrinter.text.isEmpty ? 0 : int.parse(_controllerDataPrinter.text);
                            mySharedPreferences.sizeTitlePrinter = _controllerTitlePrinter.text.isEmpty ? 0 : int.parse(_controllerTitlePrinter.text);
                            mySharedPreferences.sizeLargePrinter = _controllerLargePrinter.text.isEmpty ? 0 : int.parse(_controllerLargePrinter.text);
                            Get.back();
                          },
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          backgroundColor: ColorsApp.redLight,
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
