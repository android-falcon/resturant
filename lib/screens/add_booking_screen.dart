import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/screens/widgets/custom__drop_down.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/global_variable.dart';
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
  final _controllerBookingDate = TextEditingController();
  final _controllerNote = TextEditingController();
  int? selectedBookingType;
  final String dateFormat = 'yyyy-MM-dd HH:mm';

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
                CustomDropDown(
                  isExpanded: true,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  hint: 'Booking Type'.tr,
                  items: allDataModel.bookingTypesModel.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                  selectItem: selectedBookingType,
                  onChanged: (value) {
                    selectedBookingType = value as int;
                    setState(() {});
                  },
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
                CustomTextField(
                  controller: _controllerBookingDate,
                  label: Text('Date'.tr),
                  textDirection: TextDirection.ltr,
                  readOnly: true,
                  validator: (value) {
                    return Validation.isRequired(value);
                  },
                  onTap: () async {
                    var selectedDate = _controllerBookingDate.text.isNotEmpty ? intl.DateFormat(dateFormat).parse(_controllerBookingDate.text) : DateTime.now();
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(hour: selectedDate.hour, minute: selectedDate.minute),
                      );
                      if (pickedTime != null) {
                        pickedDate = pickedDate.copyWith(hour: pickedTime.hour, minute: pickedTime.minute);
                        String formattedDate = intl.DateFormat(dateFormat).format(pickedDate);
                        _controllerBookingDate.text = formattedDate; //set output date to TextField value.
                      }
                    }
                  },
                ),
                CustomTextField(
                  label: Text('Note'.tr),
                  controller: _controllerNote,
                ),
                CustomButton(
                  backgroundColor: ColorsApp.primaryColor,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  onPressed: () async {
                    if (_keyForm.currentState!.validate()) {
                      if(selectedBookingType == null){
                        Fluttertoast.showToast(msg: 'Please select booking type');
                      } else {
                        var result = await RestApi.saveBooking(
                          hours: int.parse(_controllerHours.text),
                          persons: int.parse(_controllerPersons.text),
                          phoneNumber: _controllerPhoneNumber.text,
                          name: _controllerName.text,
                          bookingDate: DateTime.now().toIso8601String(),
                          note: _controllerNote.text,
                          bookingType: selectedBookingType!,
                        );
                        if (result) {
                          Get.back();
                        }
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
