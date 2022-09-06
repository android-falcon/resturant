// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<PointOfSalesModel> pointOfSalesModelFromJson(String str) => List<PointOfSalesModel>.from(json.decode(str).map((x) => PointOfSalesModel.fromJson(x)));

String pointOfSalesModelToJson(List<PointOfSalesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PointOfSalesModel {
  PointOfSalesModel({
    required this.id,
    required this.posNo,
    required this.posName,
    required this.orderNo,
  });

  int id;
  int posNo;
  String posName;
  int orderNo;

  factory PointOfSalesModel.fromJson(Map<String, dynamic> json) => PointOfSalesModel(
    id: json["Id"] ?? 0,
    posNo: json["PosNo"] ?? 0,
    posName: json["PosName"] ?? "",
    orderNo: json["OrderNo"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PosNo": posNo,
    "PosName": posName,
    "OrderNo": orderNo,
  };
}
