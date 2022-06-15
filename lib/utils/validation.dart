import 'package:get/get.dart';
import 'package:restaurant_system/utils/utils.dart';

class Validation {
  static String? isRequired(value){
    if(isEmpty(value)){
      return 'This field is required'.tr;
    }
    return null;
  }

  static String? qty(value, minQty, maxQty){
    if(isEmpty(value)){
      return 'This field is required'.tr;
    } else if(minQty != null && int.parse(value) < minQty){
      return '${'Quantity must be greater than or equal to'.tr} $minQty';
    } else if(maxQty != null && int.parse(value) > maxQty){
      return '${'Quantity must be less than or equal to'.tr} $maxQty';
    }
    return null;
  }
}