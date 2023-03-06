// To parse this JSON data, do
//
//     final cashLastSerialsModel = cashLastSerialsModelFromJson(jsonString);

import 'dart:convert';

CashLastSerialsModel cashLastSerialsModelFromJson(String str) => CashLastSerialsModel.fromJson(json.decode(str));

String cashLastSerialsModelToJson(CashLastSerialsModel data) => json.encode(data.toJson());

class CashLastSerialsModel {
  CashLastSerialsModel({
    required this.cashNo,
    required this.posNo,
    required this.invNo,
    required this.cashInOutNo,
  });

  int cashNo;
  int posNo;
  int invNo;
  int cashInOutNo;

  factory CashLastSerialsModel.fromJson(Map<String, dynamic> json) => CashLastSerialsModel(
    cashNo: json["CashNo"],
    posNo: json["PosNo"],
    invNo: json["InvNo"],
    cashInOutNo: json["CashInOutNo"],
  );

  Map<String, dynamic> toJson() => {
    "CashNo": cashNo,
    "PosNo": posNo,
    "InvNo": invNo,
    "CashInOutNo": cashInOutNo,
  };
}
