

class CartModel {
  CartModel({
    required this.id,
    required this.categoryName,
    required this.categoryPic,
  });

  int id;
  String categoryName;
  String categoryPic;

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
    id: json["Id"] ?? 0,
    categoryName: json["CategoryName"] ?? "",
    categoryPic: json["CategoryPic"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "CategoryName": categoryName,
    "CategoryPic": categoryPic,
  };
}

class CartItemModel {
  CartItemModel({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.total,
  });

  int id;
  String name;
  int qty;
  double price;
  double total;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json["Id"] ?? 0,
    name: json["Name"] ?? "",
    qty: json["Qty"] ?? "",
    price: json["Price"] ?? "",
    total: json["Total"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "Id": id,
    "Name": name,
    "Qty": qty,
    "Price": price,
    "Total": total,
  };
}