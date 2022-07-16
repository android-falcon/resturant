// To parse this JSON data, do
//
//     final voidReasonModel = voidReasonModelFromJson(jsonString);

import 'dart:convert';

VoidReasonModel voidReasonModelFromJson(String str) => VoidReasonModel.fromJson(json.decode(str));

String voidReasonModelToJson(VoidReasonModel data) => json.encode(data.toJson());

class VoidReasonModel {
  VoidReasonModel({
    required this.id,
    required this.reasonName,
  });

  int id;
  String reasonName;

  factory VoidReasonModel.fromJson(Map<String, dynamic> json) => VoidReasonModel(
        id: json["Id"] ?? 0,
        reasonName: json["ReasonName"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "ReasonName": reasonName,
      };
}
