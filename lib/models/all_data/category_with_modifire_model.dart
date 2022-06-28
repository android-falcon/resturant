// To parse this JSON data, do
//
//     final categoryWithModifireModel = categoryWithModifireModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

CategoryWithModifireModel categoryWithModifireModelFromJson(String str) => CategoryWithModifireModel.fromJson(json.decode(str));

String categoryWithModifireModelToJson(CategoryWithModifireModel data) => json.encode(data.toJson());

class CategoryWithModifireModel {
  CategoryWithModifireModel({
    required this.categoryId,
    required this.categoryName,
    required this.modifireId,
    required this.name,
  });

  int categoryId;
  String categoryName;
  int modifireId;
  String name;

  factory CategoryWithModifireModel.init() => CategoryWithModifireModel(
        categoryId: 0,
        categoryName: "",
        modifireId: 0,
        name: "",
      );

  factory CategoryWithModifireModel.fromJson(Map<String, dynamic> json) => CategoryWithModifireModel(
        categoryId: json["category_Id"] ?? 0,
        categoryName: json["CategoryName"] ?? "",
        modifireId: json["modifire_Id"] ?? 0,
        name: json["Name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "category_Id": categoryId,
        "CategoryName": categoryName,
        "modifire_Id": modifireId,
        "Name": name,
      };
}
