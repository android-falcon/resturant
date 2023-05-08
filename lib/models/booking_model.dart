// To parse this JSON data, do
//
//     final bookingModel = bookingModelFromJson(jsonString);

import 'dart:convert';

BookingModel bookingModelFromJson(String str) => BookingModel.fromJson(json.decode(str));

String bookingModelToJson(BookingModel data) => json.encode(data.toJson());

class BookingModel {
  int id;
  int cashNo;
  int posNo;
  int coYear;
  int userId;
  String customerPhone;
  String customerName;
  String bookingDate;
  int noOfHours;
  int noOfPersons;
  int bookingFlag;

  BookingModel({
    required this.id,
    required this.cashNo,
    required this.posNo,
    required this.coYear,
    required this.userId,
    required this.customerPhone,
    required this.customerName,
    required this.bookingDate,
    required this.noOfHours,
    required this.noOfPersons,
    required this.bookingFlag,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json["Id"] ?? 0,
        cashNo: json["CashNo"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        coYear: json["CoYear"] ?? 0,
        userId: json["UserId"] ?? 0,
        customerPhone: json["CustomerPhone"] ?? "",
        customerName: json["CustomerName"] ?? "",
        bookingDate: json["BookingDate"] ?? "",
        noOfHours: json["NoOfHours"] ?? 0,
        noOfPersons: json["NoOfPersons"] ?? 0,
        bookingFlag: json["BookingFlag"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "CashNo": cashNo,
        "PosNo": posNo,
        "CoYear": coYear,
        "UserId": userId,
        "CustomerPhone": customerPhone,
        "CustomerName": customerName,
        "BookingDate": bookingDate,
        "NoOfHours": noOfHours,
        "NoOfPersons": noOfPersons,
        "BookingFlag": bookingFlag,
      };
}
