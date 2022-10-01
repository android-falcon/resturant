// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<PrinterModel> printerModelFromJson(String str) => List<PrinterModel>.from(json.decode(str).map((x) => PrinterModel.fromJson(x)));

String printerModelToJson(List<PrinterModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PrinterModel {
  PrinterModel({
    required this.id,
    required this.printerName,
    required this.ipAddress,
    required this.port,
    required this.cashNo,
  });

  int id;
  String printerName;
  String ipAddress;
  int port;
  int cashNo;

  factory PrinterModel.fromJson(Map<String, dynamic> json) => PrinterModel(
    id: json["Id"] ?? 0,
    printerName: json["PrinterName"] ?? "",
    ipAddress: json["IPAddress"] ?? "",
    port: json["PortNo"] ?? 9100,
    cashNo: json["CashNo"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "PrinterName": printerName,
    "IPAddress": ipAddress,
    "Port": port,
    "CashNo": cashNo,
  };
}
