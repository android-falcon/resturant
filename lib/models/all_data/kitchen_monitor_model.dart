// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<KitchenMonitorModel> kitchenMonitorModelFromJson(String str) => List<KitchenMonitorModel>.from(json.decode(str).map((x) => KitchenMonitorModel.fromJson(x)));

String kitchenMonitorModelToJson(List<KitchenMonitorModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KitchenMonitorModel {
  KitchenMonitorModel({
    required this.id,
    required this.name,
    required this.ipAddress,
  });

  int id;
  String name;
  String ipAddress;

  factory KitchenMonitorModel.fromJson(Map<String, dynamic> json) => KitchenMonitorModel(
    id: json["Id"] ?? 0,
    name: json["Name"] ?? "",
    ipAddress: json["IpAddress"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    "IpAddress": ipAddress,
  };
}
