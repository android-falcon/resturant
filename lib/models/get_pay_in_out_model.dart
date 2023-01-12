// To parse this JSON data, do
//
//     final getPayInOutModel = getPayInOutModelFromJson(jsonString);

import 'dart:convert';

GetPayInOutModel? getPayInOutModelFromJson(String str) => GetPayInOutModel.fromJson(json.decode(str));

String getPayInOutModelToJson(GetPayInOutModel? data) => json.encode(data!.toJson());

class GetPayInOutModel {
  GetPayInOutModel({
    required this.coYear,
    required this.voucherType,
    required this.voucherNo,
    required this.posNo,
    required this.cashNo,
    required this.voucherDate,
    required this.voucherTime,
    required this.voucherValue,
    required this.remark,
    required this.userId,
    required this.shiftId,
    required this.endCashId,
    required this.descId,
  });

  int coYear;
  int voucherType;
  int voucherNo;
  int posNo;
  int cashNo;
  DateTime voucherDate;
  String voucherTime;
  double voucherValue;
  String remark;
  int userId;
  int shiftId;
  int endCashId;
  int descId;

  factory GetPayInOutModel.fromJson(Map<String, dynamic> json) => GetPayInOutModel(
        coYear: json["CoYear"] ?? 0,
        voucherType: json["VoucherType"] ?? 0,
        voucherNo: json["VoucherNo"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        cashNo: json["CashNo"] ?? 0,
        voucherDate: DateTime.tryParse(json["VoucherDate"]) ?? DateTime.now(),
        voucherTime: json["VoucherTime"] ?? '',
        voucherValue: json["VoucherValue"]?.toDouble() ?? 0,
        remark: json["Remark"] ?? '',
        userId: json["UserId"] ?? 0,
        shiftId: json["ShiftId"] ?? 0,
        endCashId: json["EndCashID"] ?? 0,
        descId: json["DescId"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "CoYear": coYear,
        "VoucherType": voucherType,
        "VoucherNo": voucherNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "VoucherDate": voucherDate.toIso8601String(),
        "VoucherTime": voucherTime,
        "VoucherValue": voucherValue,
        "Remark": remark,
        "UserId": userId,
        "ShiftId": shiftId,
        "EndCashID": endCashId,
        "DescId": descId,
      };
}
