// To parse this JSON data, do
//
//     final refundModel = refundModelFromJson(jsonString);

import 'dart:convert';

import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

List<RefundModel> refundModelFromJson(String str) => List<RefundModel>.from(json.decode(str).map((x) => RefundModel.fromJson(x)));

String refundModelToJson(List<RefundModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RefundModel {
  RefundModel({
    required this.coYear,
    required this.orderType,
    required this.invKind,
    required this.invNo,
    required this.posNo,
    required this.cashNo,
    required this.storeNo,
    required this.invDate,
    required this.rowSerial,
    required this.isCombo,
    required this.note,
    required this.id,
    required this.qty,
    required this.priceChange,
    required this.price,
    required this.discount,
    required this.itemDiscPerc,
    required this.service,
    required this.serviceTax,
    required this.taxType,
    required this.taxPercent,
    required this.tax,
    required this.totalLineDiscount,
    required this.total,
    required this.returnedQty,
  });

  int coYear;
  OrderType orderType;
  int invKind;
  int invNo;
  int posNo;
  int cashNo;
  int storeNo;
  DateTime invDate;
  int rowSerial;
  bool isCombo;
  String note;
  int id;
  int qty;
  double priceChange;
  double price;
  double discount;
  double itemDiscPerc;
  double service;
  double serviceTax;
  int taxType;
  double taxPercent;
  double tax;
  double totalLineDiscount;
  double total;
  int returnedQty;

  factory RefundModel.fromJson(Map<String, dynamic> json) => RefundModel(
        coYear: json["CoYear"] ?? 0,
        orderType: OrderType.values.firstWhere((element) => element.index == (json["InvType"] ?? 0)),
        invKind: json["InvKind"] ?? 0,
        invNo: json["InvNo"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        cashNo: json["CashNo"] ?? 0,
        storeNo: json["StoreNo"] ?? 0,
        invDate: DateTime.parse(json["InvDate"]),
        rowSerial: json["RowSerial"] ?? 0,
        isCombo: (json["IsCombo"] ?? 0) == 1 ? true : false,
        note: json["ItemRemark"] ?? "",
        id: json["ItemId"] ?? 0,
        qty: json["Qty"]?.toInt() ?? 0,
        priceChange: json["Price"]?.toDouble() ?? 0,
        price: json["OrgPrice"]?.toDouble() ?? 0,
        discount: json["InvDisc"]?.toDouble() ?? 0,
        itemDiscPerc: json["ItemDiscPerc"]?.toDouble() ?? 0,
        service: json["ServiceVal"]?.toDouble() ?? 0,
        serviceTax: json["ServiceTax"]?.toDouble() ?? 0,
        taxType: json["ItemTaxKind"] ?? 0,
        taxPercent: json["ItemTaxPerc"]?.toDouble() ?? 0,
        tax: json["ItemTaxVal"]?.toDouble() ?? 0,
        totalLineDiscount: json["LineDisc"]?.toDouble() ?? 0,
        total: json["NetTotal"]?.toDouble() ?? 0,
        returnedQty: json["ReturnedQty"]?.toInt() ?? 0,
      );

  Map<String, dynamic> toReturnInvoice() => {
        "CoYear": coYear,
        "InvKind": invKind,
        "InvNo": invNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "RowSerial": rowSerial,
        "Id": id,
        "RQty": returnedQty,
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": InvoiceKind.invoiceReturn.index, // 0 - Pay , 1 - Return
        "InvNo": invNo, // الرقم الي بعد منو VocNo
        "PosNo": posNo, // PosNo
        "CashNo": cashNo, // CashNo
        "StoreNo": storeNo, // StoreNo
        "InvDate": mySharedPreferences.dailyClose.toIso8601String(),
        "RowSerial": rowSerial, // رقم الايتم بناء على ليست في شاشة index + 1
        "ItemId": id,
        "Qty": qty,
        "Price": priceChange, // السعر بعد تعديل الي بنحسب في الفتورة
        "OrgPrice": price, // السعر الايتم الفعلي
        "InvDisc": discount, // قيمة الخصم من الخصم الكلي ل هذا اليتم فقط
        "ItemDiscPerc": 0, //
        "LineDisc": totalLineDiscount, // قيمة الخصم في linedicount
        "ServiceVal": service, //  قيمة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة -- بنوزعها على الفتورة
        "ServiceTax": serviceTax, // قيمة ضريبة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة  -- بنوزعها على الفتورة
        "ItemTaxKind": taxType, // TaxType/Id
        "ItemTaxPerc": taxPercent, // TaxPerc/TaxPercent
        "ItemTaxVal": tax, // قيمة ضريبة الايتم بدون ضريبة السيرفس
        "NetTotal": total, // المجموع النهائي للايتم مع الضريبة وسيرفس وضريبة السيرفس
        "ReturnedQty": 0, //
        "ItemRemark": note,
        "IsCombo": isCombo ? 1 : 0,
        "IsSubItem": 0,
      };

  Map<String, dynamic> toJson() => {
        "CoYear": coYear,
        "InvType": orderType,
        "InvKind": invKind,
        "InvNo": invNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "StoreNo": storeNo,
        "InvDate": invDate.toIso8601String(),
        "RowSerial": rowSerial,
        "IsCombo": isCombo,
        "ItemRemark": note,
        "ItemId": id,
        "Qty": qty,
        "Price": priceChange,
        "OrgPrice": price,
        "InvDisc": discount,
        "ItemDiscPerc": itemDiscPerc,
        "ServiceVal": service,
        "ServiceTax": serviceTax,
        "ItemTaxKind": taxType,
        "ItemTaxPerc": taxPercent,
        "ItemTaxVal": tax,
        "LineDisc": totalLineDiscount,
        "NetTotal": total,
        "ReturnedQty": returnedQty,
      };
}
