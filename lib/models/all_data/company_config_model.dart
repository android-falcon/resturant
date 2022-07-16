// To parse this JSON data, do
//
//     final companyConfigModel = companyConfigModelFromJson(jsonString);

import 'dart:convert';

CompanyConfigModel companyConfigModelFromJson(String str) => CompanyConfigModel.fromJson(json.decode(str));

String companyConfigModelToJson(CompanyConfigModel data) => json.encode(data.toJson());

class CompanyConfigModel {
  CompanyConfigModel({
    required this.companyName,
    required  this.vatNo,
    required this.phoneNo,
    required  this.email,
    required  this.companyLogo,
    required  this.taxCalcMethod,
  });

  String companyName;
  String vatNo;
  String phoneNo;
  String email;
  String companyLogo;
  int taxCalcMethod;

  factory CompanyConfigModel.fromJson(Map<String, dynamic> json) => CompanyConfigModel(
    companyName: json["CompanyName"] ?? "",
    vatNo: json["VatNo"] ?? "",
    phoneNo: json["PhoneNo"] ?? "",
    email: json["Email"] ?? "",
    companyLogo: json["CompanyLogo"] ?? "",
    taxCalcMethod: json["TaxCalcMethod"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "CompanyName": companyName,
    "VatNo": vatNo,
    "PhoneNo": phoneNo,
    "Email": email,
    "CompanyLogo": companyLogo,
    "TaxCalcMethod": taxCalcMethod,
  };
}
