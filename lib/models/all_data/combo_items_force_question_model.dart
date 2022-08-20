// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

List<ComboItemsForceQuestionModel> comboItemsForceQuestionModelFromJson(String str) => List<ComboItemsForceQuestionModel>.from(json.decode(str).map((x) => ComboItemsForceQuestionModel.fromJson(x)));

String comboItemsForceQuestionModelToJson(List<ComboItemsForceQuestionModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ComboItemsForceQuestionModel {
  ComboItemsForceQuestionModel({
    required this.itemId,
    required this.subItemsForceQuestionId,
  });

  int itemId;
  int subItemsForceQuestionId;

  factory ComboItemsForceQuestionModel.fromJson(Map<String, dynamic> json) => ComboItemsForceQuestionModel(
        itemId: json["ItemId"] ?? 0,
        subItemsForceQuestionId: json["SubItemsForceQuestion_Id"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "ItemId": itemId,
        "SubItemsForceQuestion_Id": subItemsForceQuestionId,
      };
}
