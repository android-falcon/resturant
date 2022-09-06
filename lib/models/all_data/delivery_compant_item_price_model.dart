// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<DeliveryCompanyItemPriceModel> deliveryCompanyModelFromJson(String str) => List<DeliveryCompanyItemPriceModel>.from(json.decode(str).map((x) => DeliveryCompanyItemPriceModel.fromJson(x)));

String deliveryCompanyModelToJson(List<DeliveryCompanyItemPriceModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeliveryCompanyItemPriceModel {
  DeliveryCompanyItemPriceModel({
    required this.itemId,
    required this.deliveryCoId,
    required this.price,
  });

  int itemId;
  int deliveryCoId;
  double price;

  factory DeliveryCompanyItemPriceModel.fromJson(Map<String, dynamic> json) => DeliveryCompanyItemPriceModel(
    itemId: json["ItemId"] ?? 0,
    deliveryCoId: json["DeliveryCoId"] ?? 0,
    price: json["Price"]?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "ItemId": itemId,
    "DeliveryCoId": deliveryCoId,
    "Price": price,
  };
}
