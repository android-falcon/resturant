// To parse this JSON data, do
//
//     final unConfirmInvoiceModel = unConfirmInvoiceModelFromJson(jsonString);

import 'dart:convert';

UnConfirmInvoiceModel unConfirmInvoiceModelFromJson(String str) => UnConfirmInvoiceModel.fromJson(json.decode(str));

String unConfirmInvoiceModelToJson(UnConfirmInvoiceModel data) => json.encode(data.toJson());

class UnConfirmInvoiceModel {
  UnConfirmInvoiceModel({
    required this.coYear,
    required this.invType,
    required this.invKind,
    required this.invNo,
    required this.posNo,
    required this.cashNo,
    required this.invDate,
    required this.totalService,
    required this.totalServiceTax,
    required this.totalTax,
    required this.invDisc,
    required this.totalItemDisc,
    required this.deliveryCharge,
    required this.invNetTotal,
    required this.payType,
    required this.cashVal,
    required this.cardsVal,
    required this.chequeVal,
    required this.couponVal,
    required this.giftVal,
    required this.pointsVal,
    required this.userId,
    required this.shiftId,
    required this.waiterId,
    required this.tableId,
    required this.noOfSeats,
    required this.saleInvNo,
    required this.card1Name,
    required this.card1Code,
    required this.payCompanyId,
    required this.deliveryCompanyId,
    required this.invFlag,
    required this.endCashId,
    required this.noOfMale,
    required this.noOfFemal,
    required this.totSeats,
    required this.custId,
    required this.confirmed,
  });

  int coYear;
  int invType;
  int invKind;
  int invNo;
  int posNo;
  int cashNo;
  String invDate;
  double totalService;
  double totalServiceTax;
  double totalTax;
  double invDisc;
  double totalItemDisc;
  double deliveryCharge;
  double invNetTotal;
  int payType;
  double cashVal;
  double cardsVal;
  double chequeVal;
  double couponVal;
  double giftVal;
  double pointsVal;
  int userId;
  int shiftId;
  int waiterId;
  int tableId;
  int noOfSeats;
  int saleInvNo;
  String card1Name;
  String card1Code;
  int payCompanyId;
  int deliveryCompanyId;
  int invFlag;
  int endCashId;
  int noOfMale;
  int noOfFemal;
  int totSeats;
  int custId;
  int confirmed;

  factory UnConfirmInvoiceModel.fromJson(Map<String, dynamic> json) => UnConfirmInvoiceModel(
        coYear: json["CoYear"] ?? 0,
        invType: json["InvType"] ?? 0,
        invKind: json["InvKind"] ?? 0,
        invNo: json["InvNo"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        cashNo: json["CashNo"] ?? 0,
        invDate: json["InvDate"] ?? "",
        totalService: json["TotalService"]?.toDouble() ?? 0,
        totalServiceTax: json["TotalServiceTax"]?.toDouble() ?? 0,
        totalTax: json["TotalTax"]?.toDouble() ?? 0,
        invDisc: json["InvDisc"]?.toDouble() ?? 0,
        totalItemDisc: json["TotalItemDisc"]?.toDouble() ?? 0,
        deliveryCharge: json["DeliveryCharge"]?.toDouble() ?? 0,
        invNetTotal: json["InvNetTotal"]?.toDouble()?.toDouble() ?? 0,
        payType: json["PayType"] ?? 0,
        cashVal: json["CashVal"]?.toDouble() ?? 0,
        cardsVal: json["CardsVal"]?.toDouble() ?? 0,
        chequeVal: json["ChequeVal"]?.toDouble() ?? 0,
        couponVal: json["CouponVal"]?.toDouble() ?? 0,
        giftVal: json["GiftVal"]?.toDouble() ?? 0,
        pointsVal: json["PointsVal"]?.toDouble() ?? 0,
        userId: json["UserId"] ?? 0,
        shiftId: json["ShiftId"] ?? 0,
        waiterId: json["WaiterId"] ?? 0,
        tableId: json["TableId"] ?? 0,
        noOfSeats: json["NoOfSeats"] ?? 0,
        saleInvNo: json["SaleInvNo"] ?? 0,
        card1Name: json["Card1Name"] ?? "",
        card1Code: json["Card1Code"] ?? "",
        payCompanyId: json["PayCompanyId"] ?? 0,
        deliveryCompanyId: json["DeliveryCompanyId"] ?? 0,
        invFlag: json["InvFlag"] ?? 0,
        endCashId: json["EndCashId"] ?? 0,
        noOfMale: json["NoOfMale"] ?? 0,
        noOfFemal: json["NoOfFemal"] ?? 0,
        totSeats: json["TotSeats"] ?? 0,
        custId: json["CustId"] ?? 0,
        confirmed: json["Confirmed"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "CoYear": coYear,
        "InvType": invType,
        "InvKind": invKind,
        "InvNo": invNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "InvDate": invDate,
        "TotalService": totalService,
        "TotalServiceTax": totalServiceTax,
        "TotalTax": totalTax,
        "InvDisc": invDisc,
        "TotalItemDisc": totalItemDisc,
        "DeliveryCharge": deliveryCharge,
        "InvNetTotal": invNetTotal,
        "PayType": payType,
        "CashVal": cashVal,
        "CardsVal": cardsVal,
        "ChequeVal": chequeVal,
        "CouponVal": couponVal,
        "GiftVal": giftVal,
        "PointsVal": pointsVal,
        "UserId": userId,
        "ShiftId": shiftId,
        "WaiterId": waiterId,
        "TableId": tableId,
        "NoOfSeats": noOfSeats,
        "SaleInvNo": saleInvNo,
        "Card1Name": card1Name,
        "Card1Code": card1Code,
        "PayCompanyId": payCompanyId,
        "DeliveryCompanyId": deliveryCompanyId,
        "InvFlag": invFlag,
        "EndCashId": endCashId,
        "NoOfMale": noOfMale,
        "NoOfFemal": noOfFemal,
        "TotSeats": totSeats,
        "CustId": custId,
        "Confirmed": confirmed,
      };
}
