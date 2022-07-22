import 'package:flutter/material.dart';
import 'package:restaurant_system/utils/global_variable.dart';

class MoneyCount {
  String name;
  String icon;
  double value;
  TextEditingController qty;

  MoneyCount({
    required this.name,
    required this.qty,
    this.icon = '',
    this.value = 0,
  });

  static init() {
    moneyCount = allDataModel.currencies.map((e) => MoneyCount(name: '${e.currVal} ${e.currName}', value: e.currVal, icon: e.currPic, qty: TextEditingController(text: '0'))).toList();
  }

  static clear() {
    moneyCount = [];
  }

  static List<MoneyCount> moneyCount = [];
}
