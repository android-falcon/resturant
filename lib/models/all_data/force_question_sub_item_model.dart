// To parse this JSON data, do
//
//     final forceQuestionModel = forceQuestionModelFromJson(jsonString);

import 'dart:convert';

List<ForceQuestionSubItemModel> forceQuestionSubItemModelFromJson(String str) => List<ForceQuestionSubItemModel>.from(json.decode(str).map((x) => ForceQuestionSubItemModel.fromJson(x)));

String forceQuestionSubItemModelToJson(List<ForceQuestionSubItemModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForceQuestionSubItemModel {
  ForceQuestionSubItemModel({
    required this.id,
    required this.qText,
    required this.isMultible,
    required this.isMandatory,
  });

  int id;
  String qText;
  int isMultible;
  int isMandatory;

  factory ForceQuestionSubItemModel.fromJson(Map<String, dynamic> json) => ForceQuestionSubItemModel(
        id: json["Id"] ?? 0,
        qText: json["QText"] ?? "",
        isMultible: json["IsMultible"] ?? 0,
        isMandatory: json["IsMandatory"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "QText": qText,
        "IsMultible": isMultible,
        "IsMandatory": isMandatory,
      };
}
