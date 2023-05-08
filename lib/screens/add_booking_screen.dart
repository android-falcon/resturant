import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/validation.dart';

class AddBookingScreen extends StatefulWidget {
  const AddBookingScreen({Key? key}) : super(key: key);

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen> {
  final _keyForm = GlobalKey<FormState>();
  final _controllerPhoneNumber = TextEditingController();
  final _controllerName = TextEditingController();
  final _controllerHours = TextEditingController();
  final _controllerPersons = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Booking'.tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(2.w),
          child: Form(
            key: _keyForm,
            child: Column(
              children: [
                CustomTextField(
                  label: Text('Name'.tr),
                  controller: _controllerName,
                  validator: (value) => Validation.isRequired(value),
                ),
                CustomTextField(
                  label: Text('Phone Number'.tr),
                  controller: _controllerPhoneNumber,
                  validator: (value) => Validation.isRequired(value),
                ),
                CustomTextField(
                  label: Text('Hours'.tr),
                  controller: _controllerHours,
                  maxLines: 1,
                  inputFormatters: [
                    EnglishDigitsTextInputFormatter(decimal: false),
                  ],
                  validator: (value) {
                    return Validation.isRequired(value);
                  },
                  enableInteractiveSelection: false,
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
                CustomTextField(
                  label: Text('Persons'.tr),
                  controller: _controllerPersons,
                  maxLines: 1,
                  inputFormatters: [
                    EnglishDigitsTextInputFormatter(decimal: false),
                  ],
                  validator: (value) {
                    return Validation.isRequired(value);
                  },
                  enableInteractiveSelection: false,
                  keyboardType: const TextInputType.numberWithOptions(),
                ),
                CustomButton(
                  backgroundColor: ColorsApp.primaryColor,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  onPressed: () async {
                    if (_keyForm.currentState!.validate()) {
                      var result =  await RestApi.saveBooking(
                        hours: int.parse(_controllerHours.text),
                        persons: int.parse(_controllerPersons.text),
                        phoneNumber: _controllerPhoneNumber.text,
                        name: _controllerName.text,
                        bookingDate: DateTime.now().toIso8601String(),
                      );
                      if(result){
                        Get.back();
                      }

                    }
                  },
                  child: Text(
                    'Save'.tr,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
