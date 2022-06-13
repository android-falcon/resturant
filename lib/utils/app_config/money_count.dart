import 'package:flutter/material.dart';

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

  static init(){
    moneyCount = [
      MoneyCount(name: '1', value: 1, icon: '', qty: TextEditingController(text: '0')),
      MoneyCount(name: '5', value: 5, icon: '', qty: TextEditingController(text: '0')),
      MoneyCount(name: '10', value: 10, icon: '', qty: TextEditingController(text: '0')),
      MoneyCount(name: '20', value: 20, icon: '', qty: TextEditingController(text: '0')),
      MoneyCount(name: '50', value: 50, icon: '', qty: TextEditingController(text: '0')),
    ];
  }

  static clear(){
    moneyCount = [];
  }

  static List<MoneyCount> moneyCount = [];
}
