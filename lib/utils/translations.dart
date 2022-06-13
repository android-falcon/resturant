import 'package:get/get.dart';
import 'package:restaurant_system/utils/ar.dart';
import 'package:restaurant_system/utils/en.dart';


class Translation extends Translations {
  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys => {
    'en' : en,
    'ar' : ar,
  };

}