// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

import 'package:equatable/equatable.dart';

List<KitchenMonitorModel> kitchenMonitorModelFromJson(String str) => List<KitchenMonitorModel>.from(json.decode(str).map((x) => KitchenMonitorModel.fromJson(x)));

String kitchenMonitorModelToJson(List<KitchenMonitorModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KitchenMonitorModel extends Equatable {
  KitchenMonitorModel({
    required this.id,
    required this.name,
    required this.ipAddress,
    required this.port,
  });

  int id;
  String name;
  String ipAddress;
  int port;

  factory KitchenMonitorModel.fromJson(Map<String, dynamic> json) => KitchenMonitorModel(
    id: json["Id"] ?? 0,
    name: json["Name"] ?? "",
    ipAddress: json["IpAddress"] ?? "",
    port: json["Port"] ?? 3000,
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    "IpAddress": ipAddress,
    "Port": port,
  };

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, ipAddress, port];
}
