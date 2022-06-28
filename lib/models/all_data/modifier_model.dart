// To parse this JSON data, do
//
//     final modifierModel = modifierModelFromJson(jsonString);

import 'dart:convert';

List<ModifierModel> modifierModelFromJson(String str) => List<ModifierModel>.from(json.decode(str).map((x) => ModifierModel.fromJson(x)));

String modifierModelToJson(List<ModifierModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ModifierModel {
  ModifierModel({
    required this.id,
    required this.name,
    required this.active,
  });

  int id;
  String name;
  int active;

  factory ModifierModel.init() => ModifierModel(
        id: 0,
        name: "",
        active: 0,
      );

  factory ModifierModel.fromJson(Map<String, dynamic> json) => ModifierModel(
        id: json["Id"] ?? 0,
        name: json["Name"] ?? "",
        active: json["Active"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Active": active,
      };
}
