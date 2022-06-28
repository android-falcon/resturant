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
    required this.isMaster,
    required this.justTimeCard,
    required this.isActive,
  });

  int id;
  String empName;
  dynamic jobGroup;
  int jobGroupId;
  String username;
  String password;
  String mobileNo;
  bool isMaster;
  bool justTimeCard;
  bool isActive;

  factory EmployeeModel.init() => EmployeeModel(
        id: 0,
        empName: "",
        jobGroup: null,
        jobGroupId: 0,
        username: "",
        password: "",
        mobileNo: "",
        isMaster: false,
        justTimeCard: false,
        isActive: false,
      );

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json["Id"] ?? 0,
        empName: json["EmpName"] ?? "",
        jobGroup: json["JobGroup"],
        jobGroupId: json["JobGroupId"] ?? 0,
        username: json["username"] ?? "",
        password: json["password"] ?? "",
        mobileNo: json["MobileNo"] ?? "",
        isMaster: json["IsMaster"] ?? false,
        justTimeCard: json["JustTimeCard"] ?? false,
        isActive: json["IsActive"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "EmpName": empName,
        "JobGroup": jobGroup,
        "JobGroupId": jobGroupId,
        "username": username,
        "password": password,
        "MobileNo": mobileNo,
        "IsMaster": isMaster,
        "JustTimeCard": justTimeCard,
        "IsActive": isActive,
      };
}
