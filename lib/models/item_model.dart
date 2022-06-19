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
    required this.categoryId,
    required this.menuName,
    required this.family,
    required this.familyId,
    required this.price,
    required this.taxType,
    required this.taxTypeId,
    required this.taxPercent,
    required this.taxPercentId,
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
    required this.kitchenPrinter,
    required this.kitchenPrinterId,
    required this.used,
    required this.showInMenu,
    required this.itemPicture,
  });

  int id;
  String itemBarcode;
  Category category;
  int categoryId;
  String menuName;
  Family family;
  int familyId;
  double price;
  TaxType taxType;
  int taxTypeId;
  TaxPercent taxPercent;
  int taxPercentId;
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
  KitchenPrinter kitchenPrinter;
  int kitchenPrinterId;
  dynamic used;
  int showInMenu;
  String itemPicture;

  factory ItemModel.fromJson(Map<String, dynamic> json) => ItemModel(
        id: json["Id"] ?? 0,
        itemBarcode: json["ITEM_BARCODE"] ?? "",
        category: json["Category"] == null ? Category.init() : Category.fromJson(json["Category"]),
        categoryId: json["CategoryId"] ?? 0,
        menuName: json["MENU_NAME"] ?? "",
        family: json["Family"] == null ? Family.init() : Family.fromJson(json["Family"]),
        familyId: json["FamilyId"] ?? 0,
        price: json["PRICE"] == null ? 0 : json["PRICE"].toDouble(),
        taxType: json["TaxType"] == null ? TaxType.init() : TaxType.fromJson(json["TaxType"]),
        taxTypeId: json["TaxTypeId"] ?? 0,
        taxPercent: json["TaxPerc"] == null ? TaxPercent.init() : TaxPercent.fromJson(json["TaxPerc"]),
        taxPercentId: json["TaxPercId"] ?? 0,
        secondaryName: json["SECONDARY_NAME"] ?? "",
        kitchenAlias: json["KITCHEN_ALIAS"] ?? "",
        itemStatus: json["Item_STATUS"] ?? 0,
        itemType: json["ITEM_TYPE"],
        description: json["DESCRIPTION"] ?? "",
        unit: json["Unit"],
        unitId: json["UnitId"] ?? 0,
        wastagePercent: json["WASTAGE_PERCENT"],
        discountAvailable: json["DISCOUNT_AVAILABLE"] ?? 0,
        pointAvailable: json["POINT_AVAILABLE"] ?? "",
        openPrice: json["OPEN_PRICE"] ?? 0,
        kitchenPrinter: json["KitchenPrinter"] == null ? KitchenPrinter.init() : KitchenPrinter.fromJson(json["KitchenPrinter"]),
        kitchenPrinterId: json["KitchenPrinterId"] ?? 0,
        used: json["USED"],
        showInMenu: json["SHOW_IN_MENU"] ?? 0,
        itemPicture: json["ITEM_PICTURE"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "ITEM_BARCODE": itemBarcode,
        "Category": category.toJson(),
        "CategoryId": categoryId,
        "MENU_NAME": menuName,
        "Family": family.toJson(),
        "FamilyId": familyId,
        "PRICE": price,
        "TaxType": taxType.toJson(),
        "TaxTypeId": taxTypeId,
        "TaxPerc": taxPercent.toJson(),
        "TaxPercId": taxPercentId,
        "SECONDARY_NAME": secondaryName,
        "KITCHEN_ALIAS": kitchenAlias,
        "Item_STATUS": itemStatus,
        "ITEM_TYPE": itemType,
        "DESCRIPTION": description,
        "Unit": unit,
        "UnitId": unitId,
        "WASTAGE_PERCENT": wastagePercent,
        "DISCOUNT_AVAILABLE": discountAvailable,
        "POINT_AVAILABLE": pointAvailable,
        "OPEN_PRICE": openPrice,
        "KitchenPrinter": kitchenPrinter.toJson(),
        "KitchenPrinterId": kitchenPrinterId,
        "USED": used,
        "SHOW_IN_MENU": showInMenu,
        "ITEM_PICTURE": itemPicture,
      };
}

class Category {
  Category({
    required this.id,
    required this.categoryName,
    required this.categoryPic,
  });

  int id;
  String categoryName;
  String categoryPic;

  factory Category.init() => Category(
        id: 0,
        categoryName: "",
        categoryPic: "",
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["Id"],
        categoryName: json["CategoryName"],
        categoryPic: json["CategoryPic"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "CategoryName": categoryName,
        "CategoryPic": categoryPic,
      };
}

class Family {
  Family({
    required this.id,
    required this.familyName,
    required this.familyPic,
  });

  int id;
  String familyName;
  String familyPic;

  factory Family.init() => Family(
        id: 0,
        familyName: "",
        familyPic: "",
      );

  factory Family.fromJson(Map<String, dynamic> json) => Family(
        id: json["Id"],
        familyName: json["FamilyName"],
        familyPic: json["FamilyPic"],
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "FamilyName": familyName,
        "FamilyPic": familyPic,
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
    required this.addDate,
  });

  int id;
  int percent;
  DateTime addDate;

  factory TaxPercent.init() => TaxPercent(
        id: 0,
        percent: 0,
        addDate: DateTime.now(),
      );

  factory TaxPercent.fromJson(Map<String, dynamic> json) => TaxPercent(
        id: json["Id"],
        percent: json["Percent"],
        addDate: DateTime.parse(json["AddDate"]),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Percent": percent,
        "AddDate": addDate.toIso8601String(),
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
