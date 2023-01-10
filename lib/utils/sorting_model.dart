class SortingModel {
  List<SortingDataModel> categories;
  List<SortingDataModel> items;

  SortingModel({required this.categories, required this.items});

  factory SortingModel.fromJson(Map<String, dynamic> json) => SortingModel(
        categories: json["categories"] == null ? [] : List<SortingDataModel>.from(json["categories"].map((x) => SortingDataModel.fromJson(x))),
        items: json["items"] == null ? [] : List<SortingDataModel>.from(json["items"].map((x) => SortingDataModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class SortingDataModel {
  int id;
  int index;

  SortingDataModel({required this.id, required this.index});

  factory SortingDataModel.fromJson(Map<String, dynamic> json) => SortingDataModel(
        id: json["id"] ?? 0,
        index: json["index"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "index": index,
      };
}
