// To parse this JSON data, do
//
//     final allDataModel = allDataModelFromJson(jsonString);
import 'dart:convert';
import 'package:restaurant_system/models/all_data/category_model.dart';
import 'package:restaurant_system/models/all_data/category_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/employee_model.dart';
import 'package:restaurant_system/models/all_data/families_model.dart';
import 'package:restaurant_system/models/all_data/item_model.dart';
import 'package:restaurant_system/models/all_data/item_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/modifier_model.dart';

AllDataModel allDataModelFromJson(String str) => AllDataModel.fromJson(json.decode(str));

String allDataModelToJson(AllDataModel data) => json.encode(data.toJson());

class AllDataModel {
  AllDataModel({
    required this.items,
    required this.categories,
    required this.families,
    required this.modifires,
    required this.forceQuestions,
    required this.employees,
    required this.itemWithQuestions,
    required this.itemWithModifires,
    required this.categoryWithModifires,
  });

  List<ItemModel> items;
  List<CategoryModel> categories;
  List<FamiliesModel> families;
  List<ModifierModel> modifires;
  List<dynamic> forceQuestions;
  List<EmployeeModel> employees;
  List<dynamic> itemWithQuestions;
  List<ItemWithModifireModel> itemWithModifires;
  List<CategoryWithModifireModel> categoryWithModifires;

  factory AllDataModel.init() => AllDataModel(
        items: [],
        categories: [],
        families: [],
        modifires: [],
        forceQuestions: [],
        employees: [],
        itemWithQuestions: [],
        itemWithModifires: [],
        categoryWithModifires: [],
      );

  factory AllDataModel.fromJson(Map<String, dynamic> json) => AllDataModel(
        items: json["Items"] == null ? [] : List<ItemModel>.from(json["Items"].map((x) => ItemModel.fromJson(x))),
        categories: json["Categories"] == null ? [] : List<CategoryModel>.from(json["Categories"].map((x) => CategoryModel.fromJson(x))),
        families: json["Families"] == null ? [] : List<FamiliesModel>.from(json["Families"].map((x) => FamiliesModel.fromJson(x))),
        modifires: json["Modifires"] == null ? [] : List<ModifierModel>.from(json["Modifires"].map((x) => ModifierModel.fromJson(x))),
        forceQuestions: json["ForceQuestions"] == null ? [] : List<dynamic>.from(json["ForceQuestions"].map((x) => x)),
        employees: json["Employees"] == null ? [] : List<EmployeeModel>.from(json["Employees"].map((x) => EmployeeModel.fromJson(x))),
        itemWithQuestions: json["ItemWithQuestions"] == null ? [] : List<dynamic>.from(json["ItemWithQuestions"].map((x) => x)),
        itemWithModifires: json["ItemWithModifires"] == null ? [] : List<ItemWithModifireModel>.from(json["ItemWithModifires"].map((x) => ItemWithModifireModel.fromJson(x))),
        categoryWithModifires: json["CategoryWithModifires"] == null ? [] : List<CategoryWithModifireModel>.from(json["CategoryWithModifires"].map((x) => CategoryWithModifireModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "Items": List<dynamic>.from(items.map((x) => x.toJson())),
        "Categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "Families": List<dynamic>.from(families.map((x) => x.toJson())),
        "Modifires": List<dynamic>.from(modifires.map((x) => x.toJson())),
        "ForceQuestions": List<dynamic>.from(forceQuestions.map((x) => x)),
        "Employees": List<dynamic>.from(employees.map((x) => x.toJson())),
        "ItemWithQuestions": List<dynamic>.from(itemWithQuestions.map((x) => x)),
        "ItemWithModifires": List<dynamic>.from(itemWithModifires.map((x) => x.toJson())),
        "CategoryWithModifires": List<dynamic>.from(categoryWithModifires.map((x) => x.toJson())),
      };
}
