// To parse this JSON data, do
//
//     final categoryModel = categoryModelFromJson(jsonString);

import 'dart:convert';

List<CategoryModel> categoryModelFromJson(String str) => List<CategoryModel>.from(json.decode(str).map((x) => CategoryModel.fromJson(x)));

String categoryModelToJson(List<CategoryModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoryModel {
  CategoryModel({
    required this.id,
    required this.categoryName,
    required this.categoryPic,
    required this.sortOrder,
    required this.index,
  });

  int id;
  String categoryName;
  String categoryPic;
  int sortOrder;
  int index;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json["Id"] ?? 0,
    categoryName: json["CategoryName"] ?? "",
    categoryPic: json["CategoryPic"] ?? "",
    sortOrder: json["SortOrder"] ?? 0,
    index: json["Index"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "CategoryName": categoryName,
    "CategoryPic": categoryPic,
    "SortOrder": sortOrder,
    "Index": index,
  };
}
