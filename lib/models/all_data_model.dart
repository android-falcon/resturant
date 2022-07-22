// To parse this JSON data, do
//
//     final allDataModel = allDataModelFromJson(jsonString);
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/all_data/category_model.dart';
import 'package:restaurant_system/models/all_data/category_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/company_config_model.dart';
import 'package:restaurant_system/models/all_data/currency_model.dart';
import 'package:restaurant_system/models/all_data/employee_model.dart';
import 'package:restaurant_system/models/all_data/families_model.dart';
import 'package:restaurant_system/models/all_data/force_question_model.dart';
import 'package:restaurant_system/models/all_data/item_model.dart';
import 'package:restaurant_system/models/all_data/item_sub_items_model.dart';
import 'package:restaurant_system/models/all_data/item_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/item_with_questions_model.dart';
import 'package:restaurant_system/models/all_data/modifier_model.dart';
import 'package:restaurant_system/models/all_data/modifire_force_questions_model.dart';
import 'package:restaurant_system/models/all_data/tables_model.dart';
import 'package:restaurant_system/models/all_data/void_reason_model.dart';

AllDataModel allDataModelFromJson(String str) => AllDataModel.fromJson(json.decode(str));

String allDataModelToJson(AllDataModel data) => json.encode(data.toJson());

class AllDataModel {
  AllDataModel({
    required this.serverTime,
    required this.companyConfig,
    required this.items,
    required this.categories,
    required this.families,
    required this.modifires,
    required this.forceQuestions,
    required this.modifireForceQuestions,
    required this.employees,
    required this.itemWithQuestions,
    required this.itemWithModifires,
    required this.categoryWithModifires,
    required this.currencies,
    required this.voidReason,
    required this.tables,
    required this.itemSubItems,
  });

  DateTime serverTime;
  List<CompanyConfigModel> companyConfig;
  List<ItemModel> items;
  List<CategoryModel> categories;
  List<FamiliesModel> families;
  List<ModifierModel> modifires;
  List<ForceQuestionModel> forceQuestions;
  List<ModifireForceQuestionsModel> modifireForceQuestions;
  List<EmployeeModel> employees;
  List<ItemWithQuestionsModel> itemWithQuestions;
  List<ItemWithModifireModel> itemWithModifires;
  List<CategoryWithModifireModel> categoryWithModifires;
  List<CurrencyModel> currencies;
  List<VoidReasonModel> voidReason;
  List<TablesModel> tables;
  List<ItemSubItemsModel> itemSubItems;

  factory AllDataModel.init() => AllDataModel(
        serverTime: DateTime.now(),
        companyConfig: [],
        items: [],
        categories: [],
        families: [],
        modifires: [],
        forceQuestions: [],
        modifireForceQuestions: [],
        employees: [],
        itemWithQuestions: [],
        itemWithModifires: [],
        categoryWithModifires: [],
        currencies: [],
        voidReason: [],
        tables: [],
        itemSubItems: [],
      );

  factory AllDataModel.fromJson(Map<String, dynamic> json) => AllDataModel(
        serverTime: json["serverDate"] == null ? DateTime.now() : DateFormat('M/dd/yyyy h:mm:ss a').parse(json["serverDate"]),
        companyConfig: json["CompanyConfig"] == null ? [] : List<CompanyConfigModel>.from(json["CompanyConfig"].map((x) => CompanyConfigModel.fromJson(x))),
        items: json["Items"] == null ? [] : List<ItemModel>.from(json["Items"].map((x) => ItemModel.fromJson(x))),
        categories: json["Categories"] == null ? [] : List<CategoryModel>.from(json["Categories"].map((x) => CategoryModel.fromJson(x))),
        families: json["Families"] == null ? [] : List<FamiliesModel>.from(json["Families"].map((x) => FamiliesModel.fromJson(x))),
        modifires: json["Modifires"] == null ? [] : List<ModifierModel>.from(json["Modifires"].map((x) => ModifierModel.fromJson(x))),
        forceQuestions: json["ForceQuestions"] == null ? [] : List<ForceQuestionModel>.from(json["ForceQuestions"].map((x) => ForceQuestionModel.fromJson(x))),
        modifireForceQuestions: json["ModifireForceQuestions"] == null ? [] : List<ModifireForceQuestionsModel>.from(json["ModifireForceQuestions"].map((x) => ModifireForceQuestionsModel.fromJson(x))),
        employees: json["Employees"] == null ? [] : List<EmployeeModel>.from(json["Employees"].map((x) => EmployeeModel.fromJson(x))),
        itemWithQuestions: json["ItemWithQuestions"] == null ? [] : List<ItemWithQuestionsModel>.from(json["ItemWithQuestions"].map((x) => ItemWithQuestionsModel.fromJson(x))),
        itemWithModifires: json["ItemWithModifires"] == null ? [] : List<ItemWithModifireModel>.from(json["ItemWithModifires"].map((x) => ItemWithModifireModel.fromJson(x))),
        categoryWithModifires: json["CategoryWithModifires"] == null ? [] : List<CategoryWithModifireModel>.from(json["CategoryWithModifires"].map((x) => CategoryWithModifireModel.fromJson(x))),
        currencies: json["Currencies"] == null ? [] : List<CurrencyModel>.from(json["Currencies"].map((x) => CurrencyModel.fromJson(x))),
        voidReason: json["VoidReason"] == null ? [] : List<VoidReasonModel>.from(json["VoidReason"].map((x) => VoidReasonModel.fromJson(x))),
        tables: json["Tables"] == null ? [] : List<TablesModel>.from(json["Tables"].map((x) => TablesModel.fromJson(x))),
        itemSubItems: json["ItemSubItems"] == null ? [] : List<ItemSubItemsModel>.from(json["ItemSubItems"].map((x) => ItemSubItemsModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "serverDate": DateFormat('M/dd/yyyy h:mm:ss a').format(serverTime),
        "CompanyConfig": List<dynamic>.from(companyConfig.map((x) => x.toJson())),
        "Items": List<dynamic>.from(items.map((x) => x.toJson())),
        "Categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "Families": List<dynamic>.from(families.map((x) => x.toJson())),
        "Modifires": List<dynamic>.from(modifires.map((x) => x.toJson())),
        "ForceQuestions": List<dynamic>.from(forceQuestions.map((x) => x)),
        "ModifireForceQuestions": List<dynamic>.from(modifireForceQuestions.map((x) => x)),
        "Employees": List<dynamic>.from(employees.map((x) => x.toJson())),
        "ItemWithQuestions": List<dynamic>.from(itemWithQuestions.map((x) => x)),
        "ItemWithModifires": List<dynamic>.from(itemWithModifires.map((x) => x.toJson())),
        "CategoryWithModifires": List<dynamic>.from(categoryWithModifires.map((x) => x.toJson())),
        "Currencies": List<dynamic>.from(currencies.map((x) => x.toJson())),
        "VoidReason": List<dynamic>.from(voidReason.map((x) => x.toJson())),
        "Tables": List<dynamic>.from(tables.map((x) => x.toJson())),
        "ItemSubItems": List<dynamic>.from(itemSubItems.map((x) => x.toJson())),
      };
}
