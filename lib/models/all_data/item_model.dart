// To parse this JSON data, do
//
//     final itemModel = itemModelFromJson(jsonString);

import 'dart:convert';

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
    required this.taxType,
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
    required this.showInMenu,
    required this.itemPicture,
  });

  int id;
  String itemBarcode;
  Category category;
  String menuName;
  Family family;
  double price;
  TaxType taxType;
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
  int showInMenu;
  String itemPicture;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json["Id"] ?? 0,
        itemBarcode: json["ITEM_BARCODE"] ?? "",
        category: json["Category"] == null ? Category.init() : Category.fromJson(json["Category"]),
        menuName: json["MENU_NAME"] ?? "",
        family: json["Family"] == null ? Family.init() : Family.fromJson(json["Family"]),
        price: json["PRICE"] == null ? 0 : json["PRICE"].toDouble(),
        taxType: json["TaxType"] == null ? TaxType.init() : TaxType.fromJson(json["TaxType"]),
        taxPercent: json["TaxPerc"] == null ? TaxPercent.init() : TaxPercent.fromJson(json["TaxPerc"]),
        secondaryName: json["SECONDARY_NAME"] ?? "",
        kitchenAlias: json["KITCHEN_ALIAS"] ?? "",
        itemStatus: json["Item_STATUS"] ?? 0,
        itemType: json["ITEM_TYPE"],
        description: json["DESCRIPTION"] ?? "",
        wastagePercent: json["WASTAGE_PERCENT"],
        discountAvailable: json["DISCOUNT_AVAILABLE"] ?? 0,
        pointAvailable: json["POINT_AVAILABLE"] ?? "",
        openPrice: json["OPEN_PRICE"] ?? 0,
        showInMenu: json["SHOW_IN_MENU"] ?? 0,
        itemPicture: json["ITEM_PICTURE"] ?? "",
        unit: json["Unit"],
        unitId: json["UnitId"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "ITEM_BARCODE": itemBarcode,
        "Category": category.toJson(),
        "MENU_NAME": menuName,
        "Family": family.toJson(),
        "PRICE": price,
        "TaxType": taxType.toJson(),
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
        "SHOW_IN_MENU": showInMenu,
        "ITEM_PICTURE": itemPicture,
        "Unit": unit,
        "UnitId": unitId,
      };
}

class Category {
  Category({
    required this.id,
    required this.categoryName,
  });

  int id;
  String categoryName;

  factory Category.init() => Category(
        id: 0,
        categoryName: "",
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["Id"],
        categoryName: json["CategoryName"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "CategoryName": categoryName,
      };
}

class Family {
  Family({
    required this.id,
    required this.familyName,
  });

  int id;
  String familyName;

  factory Family.init() => Family(
        id: 0,
        familyName: "",
      );

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json["Id"],
        familyName: json["FamilyName"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "FamilyName": familyName,
      };
}

class KitchenPrinter {
  KitchenPrinter({
    required this.id,
    required this.printerName,
  });

  int id;
  String printerName;

  factory KitchenPrinter.init() => KitchenPrinter(
        id: 0,
        printerName: "",
      );

  factory KitchenPrinter.fromJson(Map<String, dynamic> json) => KitchenPrinter(
        id: json["Id"],
        printerName: json["PrinterName"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "PrinterName": printerName,
      };
}

class TaxPercent {
  TaxPercent({
    required this.id,
    required this.percent,
  });

  int id;
  double percent;

  factory TaxPercent.init() => TaxPercent(
        id: 0,
        percent: 0,
      );

  factory TaxPercent.fromJson(Map<String, dynamic> json) => TaxPercent(
        id: json["Id"],
        percent: json["TaxPercent"] == null ? 0 : json["TaxPercent"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "TaxPercent": percent,
      };
}

class TaxType {
  TaxType({
    required this.id,
    required this.taxTypeName,
  });

  int id;
  String taxTypeName;

  factory TaxType.init() => TaxType(
        id: 0,
        taxTypeName: "",
      );

  factory TaxType.fromJson(Map<String, dynamic> json) => TaxType(
        id: json["Id"],
        taxTypeName: json["TaxTypeName"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "TaxTypeName": taxTypeName,
      };
}
