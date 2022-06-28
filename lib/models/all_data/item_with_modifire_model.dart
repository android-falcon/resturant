// To parse this JSON data, do
//
//     final itemWithModifireModel = itemWithModifireModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

ItemWithModifireModel itemWithModifireModelFromJson(String str) => ItemWithModifireModel.fromJson(json.decode(str));

String itemWithModifireModelToJson(ItemWithModifireModel data) => json.encode(data.toJson());

class ItemWithModifireModel {
  ItemWithModifireModel({
    required this.itemsId,
    required this.menuName,
    required this.modifiresId,
    required this.name,
  });

  int itemsId;
  String menuName;
  int modifiresId;
  String name;

  factory ItemWithModifireModel.init() => ItemWithModifireModel(
        itemsId: 0,
        menuName: "",
        modifiresId: 0,
        name: "",
      );

  factory ItemWithModifireModel.fromJson(Map<String, dynamic> json) => ItemWithModifireModel(
        itemsId: json["ITEMS_Id"] ?? 0,
        menuName: json["MENU_NAME"] ?? "",
        modifiresId: json["Modifires_Id"] ?? 0,
        name: json["Name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "ITEMS_Id": itemsId,
        "MENU_NAME": menuName,
        "Modifires_Id": modifiresId,
        "Name": name,
      };
}
