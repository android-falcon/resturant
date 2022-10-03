import 'package:flutter/material.dart';


enum DeviceType {
  phone,
  tablet,
}

DeviceType deviceType = DeviceType.phone;

getDeviceType() {
  final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  deviceType = data.size.shortestSide < 550 ? DeviceType.phone : DeviceType.tablet;
}
