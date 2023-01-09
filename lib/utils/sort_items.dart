class SortItems {
  List<Data> categories;
  List<Data> items;

  SortItems({required this.categories, required this.items});

  factory SortItems.fromJson(Map<String, dynamic> json) => SortItems(
        categories: json["categories"] == null ? [] : List<Data>.from(json["categories"].map((x) => Data.fromJson(x))),
        items: json["items"] == null ? [] : List<Data>.from(json["items"].map((x) => Data.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
      };
}

class Data {
  int id;
  int index;

  Data({required this.id, required this.index});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"] ?? 0,
        index: json["index"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "index": index,
      };
}
