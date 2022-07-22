// To parse this JSON data, do
//
//     final itemSubItemsModel = itemSubItemsModelFromJson(jsonString);

import 'dart:convert';

ItemSubItemsModel itemSubItemsModelFromJson(String str) => ItemSubItemsModel.fromJson(json.decode(str));

String itemSubItemsModelToJson(ItemSubItemsModel data) => json.encode(data.toJson());

class ItemSubItemsModel {
  ItemSubItemsModel({
    required this.itemsId,
    required this.itemName,
    required this.subitemId,
    required this.subitemName,
  });

  int itemsId;
  String itemName;
  int subitemId;
  String subitemName;

  factory ItemSubItemsModel.fromJson(Map<String, dynamic> json) => ItemSubItemsModel(
        itemsId: json["ITEMS_Id"] ?? 0,
        itemName: json["ITEM_NAME"] ?? "",
        subitemId: json["SUBITEM_Id"] ?? 0,
        subitemName: json["SUBITEM_NAME"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "ITEMS_Id": itemsId,
        "ITEM_NAME": itemName,
        "SUBITEM_Id": subitemId,
        "SUBITEM_NAME": subitemName,
      };
}
