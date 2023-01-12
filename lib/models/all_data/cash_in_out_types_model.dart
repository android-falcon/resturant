// To parse this JSON data, do
//
//     final cashInOutTypesModel = cashInOutTypesModelFromJson(jsonString);

import 'dart:convert';

CashInOutTypesModel? cashInOutTypesModelFromJson(String str) => CashInOutTypesModel.fromJson(json.decode(str));

String cashInOutTypesModelToJson(CashInOutTypesModel? data) => json.encode(data!.toJson());

class CashInOutTypesModel {
  CashInOutTypesModel({
    required this.id,
    required this.kind,
    required this.description,
  });

  int id;
  int kind;
  String description;

  factory CashInOutTypesModel.fromJson(Map<String, dynamic> json) => CashInOutTypesModel(
        id: json["Id"] ?? 0,
        kind: json["Kind"] ?? 0,
        description: json["Description"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Kind": kind,
        "Description": description,
      };
}
