// To parse this JSON data, do
//
//     final itemsPrintersModel = itemsPrintersModelFromJson(jsonString);

import 'dart:convert';

import 'package:restaurant_system/models/all_data/kitchen_monitor_model.dart';

ItemsKitchenMonitorModel itemsKitchenMonitorModelFromJson(String str) => ItemsKitchenMonitorModel.fromJson(json.decode(str));

String itemsKitchenMonitorModelToJson(ItemsKitchenMonitorModel data) => json.encode(data.toJson());

class ItemsKitchenMonitorModel {
  ItemsKitchenMonitorModel({
    required this.id,
    required this.itemId,
    required this.kitchenPrinter,
  });

  int id;
  int itemId;
  KitchenMonitorModel kitchenPrinter;

  factory ItemsKitchenMonitorModel.fromJson(Map<String, dynamic> json) => ItemsKitchenMonitorModel(
    id: json["Id"] ?? 0,
    itemId: json["ItemId"] ?? 0,
    kitchenPrinter: KitchenMonitorModel.fromJson(json["kitchenMonitor"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "ItemId": itemId,
    "kitchenMonitor": kitchenPrinter.toJson(),
  };
}