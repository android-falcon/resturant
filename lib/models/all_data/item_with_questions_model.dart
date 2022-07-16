// To parse this JSON data, do
//
//     final itemWithQuestionsModel = itemWithQuestionsModelFromJson(jsonString);

import 'dart:convert';

ItemWithQuestionsModel itemWithQuestionsModelFromJson(String str) => ItemWithQuestionsModel.fromJson(json.decode(str));

String itemWithQuestionsModelToJson(ItemWithQuestionsModel data) => json.encode(data.toJson());

class ItemWithQuestionsModel {
  ItemWithQuestionsModel({
    required this.itemsId,
    required this.menuName,
    required this.forceQuestionId,
    required this.qtext,
  });

  int itemsId;
  String menuName;
  int forceQuestionId;
  String qtext;

  factory ItemWithQuestionsModel.fromJson(Map<String, dynamic> json) => ItemWithQuestionsModel(
        itemsId: json["ITEMS_Id"] ?? 0,
        menuName: json["MENU_NAME"] ?? "",
        forceQuestionId: json["ForceQuestion_Id"] ?? 0,
        qtext: json["Qtext"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "ITEMS_Id": itemsId,
        "MENU_NAME": menuName,
        "ForceQuestion_Id": forceQuestionId,
        "Qtext": qtext,
      };
}
