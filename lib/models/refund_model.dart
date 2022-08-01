// To parse this JSON data, do
//
//     final refundModel = refundModelFromJson(jsonString);

import 'dart:convert';

List<RefundModel> refundModelFromJson(String str) => List<RefundModel>.from(json.decode(str).map((x) => RefundModel.fromJson(x)));

String refundModelToJson(List<RefundModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RefundModel {
  RefundModel({
    required this.coYear,
    required this.invType,
    required this.invKind,
    required this.invNo,
    required this.posNo,
    required this.cashNo,
    required this.storeNo,
    required this.invDate,
    required this.rowSerial,
    required this.itemId,
    required this.qty,
    required this.price,
    required this.orgPrice,
    required this.invDisc,
    required this.itemDiscPerc,
    required this.serviceVal,
    required this.serviceTax,
    required this.itemTaxKind,
    required this.itemTaxPerc,
    required this.itemTaxVal,
    required this.netTotal,
    required this.returnedQty,
  });

  int coYear;
  int invType;
  int invKind;
  int invNo;
  int posNo;
  int cashNo;
  int storeNo;
  DateTime invDate;
  int rowSerial;
  int itemId;
  int qty;
  double price;
  double orgPrice;
  double invDisc;
  double itemDiscPerc;
  double serviceVal;
  double serviceTax;
  int itemTaxKind;
  double itemTaxPerc;
  double itemTaxVal;
  double netTotal;
  int returnedQty;

  factory RefundModel.fromJson(Map<String, dynamic> json) => RefundModel(
        coYear: json["CoYear"] ?? 0,
        invType: json["InvType"] ?? 0,
        invKind: json["InvKind"] ?? 0,
        invNo: json["InvNo"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        cashNo: json["CashNo"] ?? 0,
        storeNo: json["StoreNo"] ?? 0,
        invDate: DateTime.parse(json["InvDate"]),
        rowSerial: json["RowSerial"] ?? 0,
        itemId: json["ItemId"] ?? 0,
        qty: json["Qty"]?.toInt() ?? 0,
        price: json["Price"]?.toDouble() ?? 0,
        orgPrice: json["OrgPrice"]?.toDouble() ?? 0,
        invDisc: json["InvDisc"]?.toDouble() ?? 0,
        itemDiscPerc: json["ItemDiscPerc"]?.toDouble() ?? 0,
        serviceVal: json["ServiceVal"]?.toDouble() ?? 0,
        serviceTax: json["ServiceTax"]?.toDouble() ?? 0,
        itemTaxKind: json["ItemTaxKind"],
        itemTaxPerc: json["ItemTaxPerc"]?.toDouble() ?? 0,
        itemTaxVal: json["ItemTaxVal"]?.toDouble() ?? 0,
        netTotal: json["NetTotal"]?.toDouble() ?? 0,
        returnedQty: json["ReturnedQty"]?.toInt() ?? 0,
      );

  Map<String, dynamic> toReturnInvoice() => {
        "CoYear": coYear,
        "InvKind": invKind,
        "InvNo": invNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "RowSerial": rowSerial,
        "Id": itemId,
        "RQty": returnedQty,
      };

  Map<String, dynamic> toJson() => {
        "CoYear": coYear,
        "InvType": invType,
        "InvKind": invKind,
        "InvNo": invNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "StoreNo": storeNo,
        "InvDate": invDate.toIso8601String(),
        "RowSerial": rowSerial,
        "ItemId": itemId,
        "Qty": qty,
        "Price": price,
        "OrgPrice": orgPrice,
        "InvDisc": invDisc,
        "ItemDiscPerc": itemDiscPerc,
        "ServiceVal": serviceVal,
        "ServiceTax": serviceTax,
        "ItemTaxKind": itemTaxKind,
        "ItemTaxPerc": itemTaxPerc,
        "ItemTaxVal": itemTaxVal,
        "NetTotal": netTotal,
        "ReturnedQty": returnedQty,
      };
}
