// To parse this JSON data, do
//
//     final tablesModel = tablesModelFromJson(jsonString);

import 'dart:convert';

TablesModel tablesModelFromJson(String str) => TablesModel.fromJson(json.decode(str));

String tablesModelToJson(TablesModel data) => json.encode(data.toJson());

class TablesModel {
  TablesModel({
    required this.id,
    required this.userId,
    required this.tableNo,
    required this.floorNo,
    required this.isOpened,
    required this.height,
    required this.width,
    required this.marginLeft,
    required this.marginTop,
    required this.cart,
  });

  int id;
  int userId;
  int tableNo;
  int floorNo;
  int isOpened;
  double height;
  double width;
  double marginLeft;
  double marginTop;
  String cart;

  factory TablesModel.fromJson(Map<String, dynamic> json) => TablesModel(
        id: json["Id"] ?? 0,
        userId: json["UserId"] ?? 0,
        tableNo: json["TableNo"] ?? 0,
        floorNo: json["FloorNo"] ?? 0,
        isOpened: json["IsOpened"] ?? 0,
        height: json["Height"]?.toDouble() ?? 0,
        width: json["Width"]?.toDouble() ?? 0,
        marginLeft: json["MarginLeft"]?.toDouble() ?? 0,
        marginTop: json["MarginTop"]?.toDouble() ?? 0,
        cart: json["TBLCART"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "UserId": userId,
        "TableNo": tableNo,
        "FloorNo": floorNo,
        "IsOpened": isOpened,
        "Height": height,
        "Width": width,
        "MarginLeft": marginLeft,
        "MarginTop": marginTop,
        "TBLCART": cart,
      };
}
