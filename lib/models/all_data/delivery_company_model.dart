// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<DeliveryCompanyModel> deliveryCompanyModelFromJson(String str) => List<DeliveryCompanyModel>.from(json.decode(str).map((x) => DeliveryCompanyModel.fromJson(x)));

String deliveryCompanyModelToJson(List<DeliveryCompanyModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeliveryCompanyModel {
  DeliveryCompanyModel({
    required this.id,
    required this.coName,
  });

  int id;
  String coName;

  factory DeliveryCompanyModel.fromJson(Map<String, dynamic> json) => DeliveryCompanyModel(
    id: json["Id"] ?? 0,
    coName: json["CoName"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "CoName": coName,
  };
}
