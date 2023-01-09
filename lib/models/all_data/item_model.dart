// To parse this JSON data, do
//
//     final itemModel = itemModelFromJson(jsonString);

import 'dart:convert';

import 'package:restaurant_system/models/all_data/category_model.dart';
import 'package:restaurant_system/models/all_data/family_model.dart';

List<ItemModel> itemModelFromJson(String str) => List<ItemModel>.from(json.decode(str).map((x) => ItemModel.fromJson(x)));

String itemModelToJson(List<ItemModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ItemModel {
  ItemModel({
    required this.id,
    required this.itemBarcode,
    required this.category,
    required this.menuName,
    required this.family,
    required this.price,
    this.companyPrice = 0,
    required this.inMealPrice,
    required this.taxTypeId,
    required this.taxPercent,
    required this.secondaryName,
    required this.kitchenAlias,
    required this.itemStatus,
    required this.itemType,
    required this.description,
    required this.unit,
    required this.unitId,
    required this.wastagePercent,
    required this.discountAvailable,
    required this.pointAvailable,
    required this.openPrice,
    required this.sortOrder,
    required this.showInMenu,
    required this.itemPicture,
    required this.index,
  });

  int id;
  String itemBarcode;
  CategoryModel category;
  String menuName;
  FamilyModel family;
  double price;
  double companyPrice;
  double inMealPrice;
  int taxTypeId;
  TaxPercent taxPercent;
  String secondaryName;
  String kitchenAlias;
  int itemStatus;
  dynamic itemType;
  String description;
  dynamic unit;
  int unitId;
  dynamic wastagePercent;
  int discountAvailable;
  String pointAvailable;
  int openPrice;
  int sortOrder;
  int showInMenu;
  String itemPicture;
  int index;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json["Id"] ?? 0,
        itemBarcode: json["ITEM_BARCODE"] ?? "",
        category: CategoryModel.fromJson(json["Category"] ?? {}),
        menuName: json["MENU_NAME"] ?? "",
        family: FamilyModel.fromJson(json["Family"] ?? {}),
        price: json["PRICE"]?.toDouble() ?? 0,
        inMealPrice: json["InMealPrice"]?.toDouble() ?? 0,
        taxTypeId: json["TaxTypeId"] ?? 0,
        taxPercent: TaxPercent.fromJson(json["TaxPerc"] ?? {}),
        secondaryName: json["SECONDARY_NAME"] ?? "",
        kitchenAlias: json["KITCHEN_ALIAS"] ?? "",
        itemStatus: json["Item_STATUS"] ?? 0,
        itemType: json["ITEM_TYPE"],
        description: json["DESCRIPTION"] ?? "",
        wastagePercent: json["WASTAGE_PERCENT"],
        discountAvailable: json["DISCOUNT_AVAILABLE"] ?? 0,
        pointAvailable: json["POINT_AVAILABLE"] ?? "",
        openPrice: json["OPEN_PRICE"] ?? 0,
        sortOrder: json["SortOrder"] ?? 0,
        showInMenu: json["SHOW_IN_MENU"] ?? 0,
        itemPicture: json["ITEM_PICTURE"] ?? "",
        unit: json["Unit"],
        unitId: json["UnitId"] ?? 0,
        index: json["Index"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "ITEM_BARCODE": itemBarcode,
        "Category": category.toJson(),
        "MENU_NAME": menuName,
        "Family": family.toJson(),
        "PRICE": price,
        "InMealPrice": inMealPrice,
        "TaxTypeId": taxTypeId,
        "TaxPerc": taxPercent.toJson(),
        "SECONDARY_NAME": secondaryName,
        "KITCHEN_ALIAS": kitchenAlias,
        "Item_STATUS": itemStatus,
        "ITEM_TYPE": itemType,
        "DESCRIPTION": description,
        "WASTAGE_PERCENT": wastagePercent,
        "DISCOUNT_AVAILABLE": discountAvailable,
        "POINT_AVAILABLE": pointAvailable,
        "OPEN_PRICE": openPrice,
        "SortOrder": sortOrder,
        "SHOW_IN_MENU": showInMenu,
        "ITEM_PICTURE": itemPicture,
        "Unit": unit,
        "UnitId": unitId,
        "Index": index,
      };
}

class TaxPercent {
  TaxPercent({
    required this.id,
    required this.percent,
  });

  int id;
  double percent;

  factory TaxPercent.fromJson(Map<String, dynamic> json) => TaxPercent(
        id: json["Id"] ?? 0,
        percent: json["TaxPercent"]?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "TaxPercent": percent,
      };
}
