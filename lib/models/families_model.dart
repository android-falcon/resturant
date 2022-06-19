// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<FamiliesModel> familiesModelFromJson(String str) => List<FamiliesModel>.from(json.decode(str).map((x) => FamiliesModel.fromJson(x)));

String familiesModelToJson(List<FamiliesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FamiliesModel {
  FamiliesModel({
    required this.id,
    required this.familyName,
    required this.familyPic,
  });

  int id;
  String familyName;
  String familyPic;

  factory FamiliesModel.init() => FamiliesModel(
        id: 0,
        familyName: "",
        familyPic: "",
      );

  factory FamiliesModel.fromJson(Map<String, dynamic> json) => FamiliesModel(
        id: json["Id"] ?? 0,
        familyName: json["FamilyName"] ?? "",
        familyPic: json["FamilyPic"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "FamilyName": familyName,
        "FamilyPic": familyPic,
      };
}
