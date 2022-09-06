// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<PaymentCompanyModel> paymentCompanyModelFromJson(String str) => List<PaymentCompanyModel>.from(json.decode(str).map((x) => PaymentCompanyModel.fromJson(x)));

String paymentCompanyModelToJson(List<PaymentCompanyModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PaymentCompanyModel {
  PaymentCompanyModel({
    required this.id,
    required this.coName,
  });

  int id;
  String coName;

  factory PaymentCompanyModel.fromJson(Map<String, dynamic> json) => PaymentCompanyModel(
    id: json["Id"] ?? 0,
    coName: json["CoName"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "CoName": coName,
  };
}
