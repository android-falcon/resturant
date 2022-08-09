// To parse this JSON data, do
//
//     final modifireForceQuestionsModel = modifireForceQuestionsModelFromJson(jsonString);

import 'dart:convert';

import 'package:restaurant_system/models/all_data/force_question_model.dart';
import 'package:restaurant_system/models/all_data/modifier_model.dart';

ModifireForceQuestionsModel modifireForceQuestionsModelFromJson(String str) => ModifireForceQuestionsModel.fromJson(json.decode(str));

String modifireForceQuestionsModelToJson(ModifireForceQuestionsModel data) => json.encode(data.toJson());

class ModifireForceQuestionsModel {
  ModifireForceQuestionsModel({
    required this.forceQuestion,
    required this.modifires,
  });

  ForceQuestionModel forceQuestion;
  List<ModifierModel> modifires;

  factory ModifireForceQuestionsModel.fromJson(Map<String, dynamic> json) => ModifireForceQuestionsModel(
        forceQuestion: json["forceQuestion"] == null ? ForceQuestionModel.init() : ForceQuestionModel.fromJson(json["forceQuestion"]),
        modifires: json["Modifires"] == null ? [] : List<ModifierModel>.from(json["Modifires"].map((e) => ModifierModel.fromJson(e))),
      );

  Map<String, dynamic> toJson() => {
        "forceQuestion": forceQuestion.toJson(),
        "Modifires": List<dynamic>.from(modifires.map((x) => x.toJson())),
      };
}
