// To parse this JSON data, do
//
//     final cashInOutTypesModel = cashInOutTypesModelFromJson(jsonString);

import 'dart:convert';

BookingTypesModel? bookingTypesModelFromJson(String str) => BookingTypesModel.fromJson(json.decode(str));

String bookingTypesModelToJson(BookingTypesModel? data) => json.encode(data!.toJson());

class BookingTypesModel {
  BookingTypesModel({
    required this.id,
    required this.name,
  });

  int id;

  String name;

  factory BookingTypesModel.fromJson(Map<String, dynamic> json) => BookingTypesModel(
        id: json["Id"] ?? 0,
        name: json["Name"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
      };
}
