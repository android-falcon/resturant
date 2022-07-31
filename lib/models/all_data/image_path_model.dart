// To parse this JSON data, do
//
//     final imagePathModel = imagePathModelFromJson(jsonString);

import 'dart:convert';

ImagePathModel imagePathModelFromJson(String str) => ImagePathModel.fromJson(json.decode(str));

String imagePathModelToJson(ImagePathModel data) => json.encode(data.toJson());

class ImagePathModel {
  ImagePathModel({
    required this.description,
    required this.imgPath,
  });

  String description;
  String imgPath;

  factory ImagePathModel.fromJson(Map<String, dynamic> json) => ImagePathModel(
    description: json["Description"] ?? "",
    imgPath: json["ImgPath"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Description": description,
    "ImgPath": imgPath,
  };
}
