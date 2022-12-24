import 'package:flutter/material.dart';

class HomeMenu {
  String name;
  Widget? icon;
  Function()? onTab;

  HomeMenu({required this.name, this.icon, this.onTab});
}
