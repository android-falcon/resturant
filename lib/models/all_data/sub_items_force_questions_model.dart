// To parse this JSON data, do
//
//     final itemSubItemsModel = itemSubItemsModelFromJson(jsonString);

import 'dart:convert';

import 'package:restaurant_system/models/all_data/item_model.dart';

SubItemsForceQuestionsModel subItemsForceQuestionsModelFromJson(String str) => SubItemsForceQuestionsModel.fromJson(json.decode(str));

String subItemsForceQuestionsModelToJson(SubItemsForceQuestionsModel data) => json.encode(data.toJson());

class SubItemsForceQuestionsModel {
  SubItemsForceQuestionsModel({
    required this.id,
    required this.qText,
    required this.items,
  });

  int id;
  String qText;
  List<ItemModel> items;

  factory SubItemsForceQuestionsModel.fromJson(Map<String, dynamic> json) => SubItemsForceQuestionsModel(
        id: json["Id"] ?? 0,
        qText: json["QText"] ?? "",
        items: json["Items"] == null ? [] : List<ItemModel>.from(json["Items"].map((e) => ItemModel.fromJson(e))),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "QText": qText,
        "Items": List<dynamic>.from(items.map((e) => e.toJson())),
      };
}
