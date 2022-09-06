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
    required  this.servicePerc,
    required  this.serviceTaxPerc,
    required  this.useVoidReason,
  });

  String companyName;
  String vatNo;
  String phoneNo;
  String email;
  String companyLogo;
  int taxCalcMethod;
  double servicePerc;
  double serviceTaxPerc;
  bool useVoidReason;

  factory CompanyConfigModel.fromJson(Map<String, dynamic> json) => CompanyConfigModel(
    companyName: json["CompanyName"] ?? "",
    vatNo: json["VatNo"] ?? "",
    phoneNo: json["PhoneNo"] ?? "",
    email: json["Email"] ?? "",
    companyLogo: json["CompanyLogo"] ?? "",
    taxCalcMethod: json["TaxCalcMethod"] ?? 0,
    servicePerc: json["ServicePerc"] == null ? 0 : json["ServicePerc"].toDouble(),
    serviceTaxPerc: json["ServiceTaxPerc"] == null ? 0 : json["ServiceTaxPerc"].toDouble(),
    useVoidReason: json["UseVoidReason"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "CompanyName": companyName,
    "VatNo": vatNo,
    "PhoneNo": phoneNo,
    "Email": email,
    "CompanyLogo": companyLogo,
    "TaxCalcMethod": taxCalcMethod,
    "ServicePerc": servicePerc,
    "ServiceTaxPerc": serviceTaxPerc,
    "UseVoidReason": useVoidReason,
  };
}
