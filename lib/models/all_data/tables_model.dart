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
  });

  int id;
  int tableNo;
  int floorNo;

  factory TablesModel.fromJson(Map<String, dynamic> json) => TablesModel(
        id: json["Id"] ?? 0,
        tableNo: json["TableNo"] ?? 0,
        floorNo: json["FloorNo"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "TableNo": tableNo,
        "FloorNo": floorNo,
      };
}
