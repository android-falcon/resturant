// To parse this JSON data, do
//
//     final currencyModel = currencyModelFromJson(jsonString);

import 'dart:convert';

CurrencyModel currencyModelFromJson(String str) => CurrencyModel.fromJson(json.decode(str));

String currencyModelToJson(CurrencyModel data) => json.encode(data.toJson());

class CurrencyModel {
  CurrencyModel({
    required this.id,
    required this.currName,
    required this.currVal,
    required this.currRate,
    required this.currPic,
  });

  int id;
  String currName;
  double currVal;
  double currRate;
  String currPic;

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
        id: json["Id"] ?? 0,
        currName: json["CurrName"] ?? "",
        currVal: json["CurrVal"] == null ? 0 : json["CurrVal"].toDouble(),
        currRate: json["CurrRate"] == null ? 0 : json["CurrRate"].toDouble(),
        currPic: json["CurrPic"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "CurrName": currName,
        "CurrVal": currVal,
        "CurrRate": currRate,
        "CurrPic": currPic,
      };
}
