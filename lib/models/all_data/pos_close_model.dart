// To parse this JSON data, do
//
//     final voidReasonModel = voidReasonModelFromJson(jsonString);

import 'dart:convert';

PosCloseModel posCloseModelFromJson(String str) => PosCloseModel.fromJson(json.decode(str));

String posCloseModelToJson(PosCloseModel data) => json.encode(data.toJson());

class PosCloseModel {
  PosCloseModel({
    required this.coYear,
    required this.posNo,
    required this.userId,
    required this.closeDate,
  });

  int coYear;
  int posNo;
  int userId;
  DateTime closeDate;

  factory PosCloseModel.fromJson(Map<String, dynamic> json) => PosCloseModel(
        coYear: json["CoYear"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        userId: json["UserId"] ?? 0,
        closeDate: json["CloseDate"] == null ? DateTime.now() : DateTime.parse(json["CloseDate"]),
      );

  Map<String, dynamic> toJson() => {
        "CoYear": coYear,
        "PosNo": posNo,
        "UserId": userId,
        "CloseDate": closeDate.toIso8601String(),
      };
}
