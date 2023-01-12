// To parse this JSON data, do
//
//     final allDataModel = allDataModelFromJson(jsonString);
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/all_data/cash_in_out_types_model.dart';
import 'package:restaurant_system/models/all_data/category_model.dart';
import 'package:restaurant_system/models/all_data/category_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/combo_items_force_question_model.dart';
import 'package:restaurant_system/models/all_data/company_config_model.dart';
import 'package:restaurant_system/models/all_data/currency_model.dart';
import 'package:restaurant_system/models/all_data/delivery_compant_item_price_model.dart';
import 'package:restaurant_system/models/all_data/delivery_company_model.dart';
import 'package:restaurant_system/models/all_data/employee_model.dart';
import 'package:restaurant_system/models/all_data/family_model.dart';
import 'package:restaurant_system/models/all_data/force_question_model.dart';
import 'package:restaurant_system/models/all_data/image_path_model.dart';
import 'package:restaurant_system/models/all_data/item_model.dart';
import 'package:restaurant_system/models/all_data/items_kitchen_monitor_model.dart';
import 'package:restaurant_system/models/all_data/items_printers_model.dart';
import 'package:restaurant_system/models/all_data/payment_company_model.dart';
import 'package:restaurant_system/models/all_data/point_of_sales_model.dart';
import 'package:restaurant_system/models/all_data/sub_items_force_questions_model.dart';
import 'package:restaurant_system/models/all_data/item_with_modifire_model.dart';
import 'package:restaurant_system/models/all_data/item_with_questions_model.dart';
import 'package:restaurant_system/models/all_data/modifier_model.dart';
import 'package:restaurant_system/models/all_data/force_question_mod_model.dart';
import 'package:restaurant_system/models/all_data/pos_close_model.dart';
import 'package:restaurant_system/models/all_data/printer_model.dart';
import 'package:restaurant_system/models/all_data/tables_model.dart';
import 'package:restaurant_system/models/all_data/void_reason_model.dart';

AllDataModel allDataModelFromJson(String str) => AllDataModel.fromJson(json.decode(str));

String allDataModelToJson(AllDataModel data) => json.encode(data.toJson());

class AllDataModel {
  AllDataModel({
    required this.serverTime,
    required this.companyConfig,
    required this.imagePaths,
    required this.posClose,
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
    required this.printers,
    required this.voidReason,
    required this.tables,
    required this.subItemsForceQuestions,
    required this.comboItemsForceQuestion,
    required this.itemsPrintersModel,
    required this.itemsKitchenMonitorModel,
    required this.pointOfSalesModel,
    required this.paymentCompanyModel,
    required this.deliveryCompanyModel,
    required this.deliveryCompanyItemPriceModel,
    required this.cashInOutTypesModel,
  });

  DateTime serverTime;
  List<CompanyConfigModel> companyConfig;
  List<ImagePathModel> imagePaths;
  DateTime posClose;
  List<ItemModel> items;
  List<CategoryModel> categories;
  List<FamilyModel> families;
  List<ModifierModel> modifires;
  List<ForceQuestionModel> forceQuestions;
  List<ForceQuestionModModel> modifireForceQuestions;
  List<EmployeeModel> employees;
  List<ItemWithQuestionsModel> itemWithQuestions;
  List<ItemWithModifireModel> itemWithModifires;
  List<CategoryWithModifireModel> categoryWithModifires;
  List<CurrencyModel> currencies;
  List<PrinterModel> printers;
  List<VoidReasonModel> voidReason;
  List<TablesModel> tables;
  List<SubItemsForceQuestionsModel> subItemsForceQuestions;
  List<ComboItemsForceQuestionModel> comboItemsForceQuestion;
  List<ItemsPrintersModel> itemsPrintersModel;
  List<ItemsKitchenMonitorModel> itemsKitchenMonitorModel;
  List<PointOfSalesModel> pointOfSalesModel;
  List<PaymentCompanyModel> paymentCompanyModel;
  List<DeliveryCompanyModel> deliveryCompanyModel;
  List<DeliveryCompanyItemPriceModel> deliveryCompanyItemPriceModel;
  List<CashInOutTypesModel> cashInOutTypesModel;

  factory AllDataModel.fromJson(Map<String, dynamic> json) => AllDataModel(
        serverTime: json["serverDate"] == null ? DateTime.now() : DateFormat('M/dd/yyyy h:mm:ss a').parse(json["serverDate"]),
        companyConfig: json["CompanyConfig"] == null ? [] : List<CompanyConfigModel>.from(json["CompanyConfig"].map((x) => CompanyConfigModel.fromJson(x))),
        imagePaths: json["ImagePaths"] == null ? [] : List<ImagePathModel>.from(json["ImagePaths"].map((x) => ImagePathModel.fromJson(x))),
        posClose: DateTime.parse(json["PosClose"] ?? DateTime.now().toIso8601String()),
        items: json["Items"] == null ? [] : List<ItemModel>.from(json["Items"].map((x) => ItemModel.fromJson(x))),
        categories: json["Categories"] == null ? [] : List<CategoryModel>.from(json["Categories"].map((x) => CategoryModel.fromJson(x))),
        families: json["Families"] == null ? [] : List<FamilyModel>.from(json["Families"].map((x) => FamilyModel.fromJson(x))),
        modifires: json["Modifires"] == null ? [] : List<ModifierModel>.from(json["Modifires"].map((x) => ModifierModel.fromJson(x))),
        forceQuestions: json["ForceQuestions"] == null ? [] : List<ForceQuestionModel>.from(json["ForceQuestions"].map((x) => ForceQuestionModel.fromJson(x))),
        modifireForceQuestions: json["ForceQuestionModViewModels"] == null ? [] : List<ForceQuestionModModel>.from(json["ForceQuestionModViewModels"].map((x) => ForceQuestionModModel.fromJson(x))),
        employees: json["Employees"] == null ? [] : List<EmployeeModel>.from(json["Employees"].map((x) => EmployeeModel.fromJson(x))),
        itemWithQuestions: json["ItemWithQuestions"] == null ? [] : List<ItemWithQuestionsModel>.from(json["ItemWithQuestions"].map((x) => ItemWithQuestionsModel.fromJson(x))),
        itemWithModifires: json["ItemWithModifires"] == null ? [] : List<ItemWithModifireModel>.from(json["ItemWithModifires"].map((x) => ItemWithModifireModel.fromJson(x))),
        categoryWithModifires: json["CategoryWithModifires"] == null ? [] : List<CategoryWithModifireModel>.from(json["CategoryWithModifires"].map((x) => CategoryWithModifireModel.fromJson(x))),
        currencies: json["Currencies"] == null ? [] : List<CurrencyModel>.from(json["Currencies"].map((x) => CurrencyModel.fromJson(x))),
        printers: json["Printers"] == null ? [] : List<PrinterModel>.from(json["Printers"].map((x) => PrinterModel.fromJson(x))),
        voidReason: json["VoidReason"] == null ? [] : List<VoidReasonModel>.from(json["VoidReason"].map((x) => VoidReasonModel.fromJson(x))),
        tables: json["Tables"] == null ? [] : List<TablesModel>.from(json["Tables"].map((x) => TablesModel.fromJson(x))),
        subItemsForceQuestions: json["SubItemsForceQuestionsViewModel"] == null ? [] : List<SubItemsForceQuestionsModel>.from(json["SubItemsForceQuestionsViewModel"].map((x) => SubItemsForceQuestionsModel.fromJson(x))),
        comboItemsForceQuestion: json["ComboItemsForceQuestion"] == null ? [] : List<ComboItemsForceQuestionModel>.from(json["ComboItemsForceQuestion"].map((x) => ComboItemsForceQuestionModel.fromJson(x))),
        itemsPrintersModel: json["ItemsPrintersViewModel"] == null ? [] : List<ItemsPrintersModel>.from(json["ItemsPrintersViewModel"].map((x) => ItemsPrintersModel.fromJson(x))),
        itemsKitchenMonitorModel: json["ItemsKitchenMonitorViewModel"] == null ? [] : List<ItemsKitchenMonitorModel>.from(json["ItemsKitchenMonitorViewModel"].map((x) => ItemsKitchenMonitorModel.fromJson(x))),
        pointOfSalesModel: json["PointOfSales"] == null ? [] : List<PointOfSalesModel>.from(json["PointOfSales"].map((x) => PointOfSalesModel.fromJson(x))),
        paymentCompanyModel: json["PaymentCompany"] == null ? [] : List<PaymentCompanyModel>.from(json["PaymentCompany"].map((x) => PaymentCompanyModel.fromJson(x))),
        deliveryCompanyModel: json["DeliveryCompanys"] == null ? [] : List<DeliveryCompanyModel>.from(json["DeliveryCompanys"].map((x) => DeliveryCompanyModel.fromJson(x))),
        deliveryCompanyItemPriceModel: json["DeliveryCoItemPrices"] == null ? [] : List<DeliveryCompanyItemPriceModel>.from(json["DeliveryCoItemPrices"].map((x) => DeliveryCompanyItemPriceModel.fromJson(x))),
        cashInOutTypesModel: json["CashInOutTypes"] == null ? [] : List<CashInOutTypesModel>.from(json["CashInOutTypes"].map((x) => CashInOutTypesModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "serverDate": DateFormat('M/dd/yyyy h:mm:ss a').format(serverTime),
        "CompanyConfig": List<dynamic>.from(companyConfig.map((x) => x.toJson())),
        "ImagePaths": List<dynamic>.from(imagePaths.map((x) => x.toJson())),
        "PosClose": posClose.toIso8601String(),
        "Items": List<dynamic>.from(items.map((x) => x.toJson())),
        "Categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "Families": List<dynamic>.from(families.map((x) => x.toJson())),
        "Modifires": List<dynamic>.from(modifires.map((x) => x.toJson())),
        "ForceQuestions": List<dynamic>.from(forceQuestions.map((x) => x)),
        "ForceQuestionModViewModels": List<dynamic>.from(modifireForceQuestions.map((x) => x)),
        "Employees": List<dynamic>.from(employees.map((x) => x.toJson())),
        "ItemWithQuestions": List<dynamic>.from(itemWithQuestions.map((x) => x)),
        "ItemWithModifires": List<dynamic>.from(itemWithModifires.map((x) => x.toJson())),
        "CategoryWithModifires": List<dynamic>.from(categoryWithModifires.map((x) => x.toJson())),
        "Currencies": List<dynamic>.from(currencies.map((x) => x.toJson())),
        "Printers": List<dynamic>.from(printers.map((x) => x.toJson())),
        "VoidReason": List<dynamic>.from(voidReason.map((x) => x.toJson())),
        "Tables": List<dynamic>.from(tables.map((x) => x.toJson())),
        "SubItemsForceQuestionsViewModel": List<dynamic>.from(subItemsForceQuestions.map((x) => x.toJson())),
        "ComboItemsForceQuestion": List<dynamic>.from(comboItemsForceQuestion.map((x) => x.toJson())),
        "ItemsPrintersViewModel": List<dynamic>.from(itemsPrintersModel.map((x) => x.toJson())),
        "ItemsKitchenMonitorViewModel": List<dynamic>.from(itemsKitchenMonitorModel.map((x) => x.toJson())),
        "PointOfSales": List<dynamic>.from(pointOfSalesModel.map((x) => x.toJson())),
        "PaymentCompany": List<dynamic>.from(paymentCompanyModel.map((x) => x.toJson())),
        "DeliveryCompanys": List<dynamic>.from(deliveryCompanyModel.map((x) => x.toJson())),
        "DeliveryCoItemPrices": List<dynamic>.from(deliveryCompanyItemPriceModel.map((x) => x.toJson())),
        "CashInOutTypes": List<dynamic>.from(cashInOutTypesModel.map((x) => x.toJson())),
      };
}
