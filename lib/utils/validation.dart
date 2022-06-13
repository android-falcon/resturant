import 'package:get/get.dart';
import 'package:restaurant_system/utils/utils.dart';

class Validation {
  static String? isRequired(value){
    if(isEmpty(value)){
      return 'This field is required'.tr;
    }
    return null;
  }
}