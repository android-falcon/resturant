// To parse this JSON data, do
//
//     final employeeModel = employeeModelFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

EmployeeModel employeeModelFromJson(String str) => EmployeeModel.fromJson(json.decode(str));

String employeeModelToJson(EmployeeModel data) => json.encode(data.toJson());

class EmployeeModel {
  EmployeeModel({
    required this.id,
    required this.empName,
    required this.jobGroup,
    required this.jobGroupId,
    required this.username,
    required this.password,
    required this.mobileNo,
    required this.isCasher,
    required this.isMaster,
    required this.justTimeCard,
    required this.isActive,
    required this.isKitchenUser,
    required this.hasRefundPermission,
    required this.hasCashInOutPermission,
    required this.hasVoidPermission,
    required this.hasVoidAllPermission,
    required this.hasLineDiscPermission,
    required this.hasDiscPermission,
    required this.hasPriceChangePermission,
    required this.hasResetPermission,
    required this.hasMoveTablePermission,
    required this.hasMergeTablePermission,
    required this.hasChangeTableCaptinPermission,
    required this.deviceIp,
    required this.devicePort,
  });

  int id;
  String empName;
  dynamic jobGroup;
  int jobGroupId;
  String username;
  String password;
  String mobileNo;
  bool isCasher;
  bool isMaster;
  bool justTimeCard;
  bool isActive;
  bool isKitchenUser;
  bool hasRefundPermission;
  bool hasCashInOutPermission;
  bool hasVoidPermission;
  bool hasVoidAllPermission;
  bool hasLineDiscPermission;
  bool hasDiscPermission;
  bool hasPriceChangePermission;
  bool hasResetPermission;
  bool hasMoveTablePermission;
  bool hasMergeTablePermission;
  bool hasChangeTableCaptinPermission;
  String deviceIp;
  int devicePort;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json["Id"] ?? 0,
        empName: json["EmpName"] ?? "",
        jobGroup: json["JobGroup"],
        jobGroupId: json["JobGroupId"] ?? 0,
        username: json["username"] ?? "",
        password: json["password"] ?? "",
        mobileNo: json["MobileNo"] ?? "",
        isCasher: json["IsCasher"] ?? false,
        isMaster: json["IsMaster"] ?? false,
        justTimeCard: json["JustTimeCard"] ?? false,
        isActive: json["IsActive"] ?? false,
        isKitchenUser: json["IsKitchenUser"] ?? false,
        hasRefundPermission: json["HasRefundPermission"] ?? false,
        hasCashInOutPermission: json["HasCashInOutPermission"] ?? false,
        hasVoidPermission: json["HasVoidPermission"] ?? false,
        hasVoidAllPermission: json["HasVoidAllPermission"] ?? false,
        hasLineDiscPermission: json["HasLineDiscPermission"] ?? false,
        hasDiscPermission: json["HasDiscPermission"] ?? false,
        hasPriceChangePermission: json["HasPriceChangePermission"] ?? false,
        hasResetPermission: json["HasResetPermission"] ?? false,
        hasMoveTablePermission: json["HasMoveTablePermission"] ?? false,
        hasMergeTablePermission: json["HasMergeTablePermission"] ?? false,
        hasChangeTableCaptinPermission: json["HasChangeTableCaptinPermission"] ?? false,
        deviceIp: json["DeviceIp"] ?? "",
        devicePort: json["DevicePort"] ?? 3000,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "EmpName": empName,
        "JobGroup": jobGroup,
        "JobGroupId": jobGroupId,
        "username": username,
        "password": password,
        "MobileNo": mobileNo,
        "IsCasher": isCasher,
        "IsMaster": isMaster,
        "JustTimeCard": justTimeCard,
        "IsActive": isActive,
        "IsKitchenUser": isKitchenUser,
        "HasRefundPermission": hasRefundPermission,
        "HasCashInOutPermission": hasCashInOutPermission,
        "HasVoidPermission": hasVoidPermission,
        "HasVoidAllPermission": hasVoidAllPermission,
        "HasLineDiscPermission": hasLineDiscPermission,
        "HasDiscPermission": hasDiscPermission,
        "HasPriceChangePermission": hasPriceChangePermission,
        "HasResetPermission": hasResetPermission,
        "HasMoveTablePermission": hasMoveTablePermission,
        "HasMergeTablePermission": hasMergeTablePermission,
        "HasChangeTableCaptinPermission": hasChangeTableCaptinPermission,
        "DeviceIp": deviceIp,
        "DevicePort": devicePort,
      };
}
