// To parse this JSON data, do
//
//     final endCashModel = endCashModelFromJson(jsonString);

import 'dart:convert';

EndCashModel endCashModelFromJson(String str) => EndCashModel.fromJson(json.decode(str));

String endCashModelToJson(EndCashModel data) => json.encode(data.toJson());

class EndCashModel {
  EndCashModel({
    required this.totalCash,
    required this.totalCreditCard,
    required this.netTotal,
  });

  double totalCash;
  double totalCreditCard;
  double netTotal;

  factory EndCashModel.fromJson(Map<String, dynamic> json) => EndCashModel(
    totalCash: json["TotalCash"]?.toDouble() ?? 0,
    totalCreditCard: json["TotalCreditCard"]?.toDouble() ?? 0,
    netTotal: json["NetTotal"]?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "TotalCash": totalCash,
    "TotalCreditCard": totalCreditCard,
    "NetTotal": netTotal,
  };
}
