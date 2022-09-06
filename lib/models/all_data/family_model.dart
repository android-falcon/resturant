// To parse this JSON data, do
//
//     final familieModel = familieModelFromJson(jsonString);

import 'dart:convert';

List<FamilyModel> familyModelFromJson(String str) => List<FamilyModel>.from(json.decode(str).map((x) => FamilyModel.fromJson(x)));

String familyModelToJson(List<FamilyModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FamilyModel {
  FamilyModel({
    required this.id,
    required this.familyName,
    required this.familyPic,
  });

  int id;
  String familyName;
  String familyPic;

  factory FamilyModel.init() => FamilyModel(
        id: 0,
        familyName: "",
        familyPic: "",
      );

  factory FamilyModel.fromJson(Map<String, dynamic> json) => FamilyModel(
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
