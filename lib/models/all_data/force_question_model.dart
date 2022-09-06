// To parse this JSON data, do
//
//     final forceQuestionModel = forceQuestionModelFromJson(jsonString);

import 'dart:convert';

List<ForceQuestionModel> forceQuestionModelFromJson(String str) => List<ForceQuestionModel>.from(json.decode(str).map((x) => ForceQuestionModel.fromJson(x)));

String forceQuestionModelToJson(List<ForceQuestionModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ForceQuestionModel {
  ForceQuestionModel({
    required this.id,
    required this.qText,
    required this.isMultible,
  });

  int id;
  String qText;
  int isMultible;

  factory ForceQuestionModel.fromJson(Map<String, dynamic> json) => ForceQuestionModel(
        id: json["Id"] ?? 0,
        qText: json["QText"] ?? "",
        isMultible: json["isMultible"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "QText": qText,
        "isMultible": isMultible,
      };
}
