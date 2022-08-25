// To parse this JSON data, do
//
//     final itemsPrintersModel = itemsPrintersModelFromJson(jsonString);

import 'dart:convert';

import 'package:restaurant_system/models/all_data/printer_model.dart';

ItemsPrintersModel itemsPrintersModelFromJson(String str) => ItemsPrintersModel.fromJson(json.decode(str));

String itemsPrintersModelToJson(ItemsPrintersModel data) => json.encode(data.toJson());

class ItemsPrintersModel {
  ItemsPrintersModel({
    required this.id,
    required this.itemId,
    required this.kitchenPrinter,
  });

  int id;
  int itemId;
  PrinterModel kitchenPrinter;

  factory ItemsPrintersModel.fromJson(Map<String, dynamic> json) => ItemsPrintersModel(
    id: json["Id"] ?? 0,
    itemId: json["ItemId"] ?? 0,
    kitchenPrinter: PrinterModel.fromJson(json["kitchenPrinter"] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "ItemId": itemId,
    "kitchenPrinter": kitchenPrinter.toJson(),
  };
}