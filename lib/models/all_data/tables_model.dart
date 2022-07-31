// To parse this JSON data, do
//
//     final tablesModel = tablesModelFromJson(jsonString);

import 'dart:convert';

TablesModel tablesModelFromJson(String str) => TablesModel.fromJson(json.decode(str));

String tablesModelToJson(TablesModel data) => json.encode(data.toJson());

class TablesModel {
  TablesModel({
    required this.id,
    required this.tableNo,
    required this.floorNo,
    required this.isOpened,
    required this.height,
    required this.width,
    required this.marginLeft,
    required this.marginTop,
  });

  int id;
  int tableNo;
  int floorNo;
  int isOpened;
  double height;
  double width;
  double marginLeft;
  double marginTop;

  factory TablesModel.fromJson(Map<String, dynamic> json) => TablesModel(
        id: json["Id"] ?? 0,
        tableNo: json["TableNo"] ?? 0,
        floorNo: json["FloorNo"] ?? 0,
        isOpened: json["IsOpened"] ?? 0,
        height: json["Height"] == null ? 0 : json["Height"].toDouble(),
        width: json["Width"] == null ? 0 : json["Width"].toDouble(),
        marginLeft: json["MarginLeft"] == null ? 0 : json["MarginLeft"].toDouble(),
        marginTop: json["MarginTop"] == null ? 0 : json["MarginTop"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "TableNo": tableNo,
        "FloorNo": floorNo,
        "IsOpened": isOpened,
        "Height": height,
        "Width": width,
        "MarginLeft": marginLeft,
        "MarginTop": marginTop,
      };
}
