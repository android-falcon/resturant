import 'package:get/get.dart';
import 'package:restaurant_system/utils/enum_discount_type.dart';
import 'package:restaurant_system/utils/utils.dart';

class Validation {
  static String? isRequired(value) {
    if (isEmpty(value)) {
      return 'This field is required'.tr;
    }
    return null;
  }

  static String? qty(value, minQty, maxQty) {
    if (isEmpty(value)) {
      return 'This field is required'.tr;
    } else if (minQty != null && int.parse(value) < minQty) {
      return '${'Quantity must be greater than or equal to'.tr} $minQty';
    } else if (maxQty != null && int.parse(value) > maxQty) {
      return '${'Quantity must be less than or equal to'.tr} $maxQty';
    }
    return null;
  }

  static String? discount(type, value, price) {
    if (isEmpty(value)) {
      return 'This field is required'.tr;
    } else {
      if (DiscountType.value == type) {
        if (double.parse(value) > price) {
          return 'The discount cannot be greater than the price of an item'.tr;
        }
      } else {
        if (double.parse(value) > 100) {
          return 'Discount cannot be more than %100'.tr;
        }
      }
    }
    return null;
  }

  static String? priceChange(priceChange) {
    if (isEmpty(priceChange)) {
      return 'This field is required'.tr;
    } else if (priceChange <  0) {
      return 'The item price cannot be less than zero'.tr;
    }
    return null;
  }
}
