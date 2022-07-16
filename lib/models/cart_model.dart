import 'package:restaurant_system/utils/enum_discount_type.dart';

class CartModel {
  CartModel({
    required this.id,
    required this.total,
    required this.deliveryCharge,
    required this.lineDiscount,
    required this.discount,
    this.discountType = DiscountType.percentage,
    required this.subTotal,
    required this.service,
    required this.tax,
    required this.amountDue,
    required this.items,
  });

  int id;
  double total;
  double deliveryCharge;
  double lineDiscount;
  double discount;
  DiscountType discountType;
  double subTotal;
  double service;
  double tax;
  double amountDue;
  List<CartItemModel> items;

  factory CartModel.init() => CartModel(
        id: 0,
        total: 0,
        deliveryCharge: 0,
        lineDiscount: 0,
        discount: 0,
        discountType: DiscountType.percentage,
        subTotal: 0,
        service: 0,
        tax: 0,
        amountDue: 0,
        items: [],
      );

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        id: json["id"] ?? 0,
        total: json["total"] == null ? 0.0 : json["total"].toDouble(),
        deliveryCharge: json["deliveryCharge"] == null ? 0.0 : json["deliveryCharge"].toDouble(),
        lineDiscount: json["lineDiscount"] == null ? 0.0 : json["lineDiscount"].toDouble(),
        discount: json["discount"] == null ? 0.0 : json["discount"].toDouble(),
        discountType: json["discountType"] == null
            ? DiscountType.percentage
            : json["discountType"] == 1
                ? DiscountType.percentage
                : DiscountType.value,
        subTotal: json["subTotal"] == null ? 0.0 : json["subTotal"].toDouble(),
        service: json["service"] == null ? 0.0 : json["service"].toDouble(),
        tax: json["tax"] == null ? 0.0 : json["tax"].toDouble(),
        amountDue: json["amountDue"] == null ? 0.0 : json["amountDue"].toDouble(),
        items: json["items"] == null ? [] : List<CartItemModel>.from(json["items"].map((x) => CartItemModel.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "total": total,
        "deliveryCharge": deliveryCharge,
        "lineDiscount": lineDiscount,
        "discount": discount,
        "subTotal": subTotal,
        "service": service,
        "tax": tax,
        "amountDue": amountDue,
        "items": items,
      };
}

class CartItemModel {
  CartItemModel({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.priceChange,
    required this.total,
    required this.tax,
    this.lineDiscountType = DiscountType.percentage,
    this.lineDiscount = 0,
    this.discount = 0,
    this.discountAvailable = false,
    this.openPrice = false,
  });

  int id;
  String name;
  int qty;
  double price;
  double priceChange;
  double total;
  double tax;
  DiscountType lineDiscountType;
  double lineDiscount;
  double discount;
  bool discountAvailable;
  bool openPrice;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        id: json["Id"] ?? 0,
        name: json["Name"] ?? "",
        qty: json["Qty"] ?? 0,
        price: json["Price"] ?? 0,
        priceChange: json["PriceChange"] ?? 0,
        total: json["Total"] ?? 0,
        tax: json["Tax"] ?? 0,
        lineDiscountType: json["lineDiscountType"] == null
            ? DiscountType.percentage
            : json["lineDiscountType"] == 1
                ? DiscountType.percentage
                : DiscountType.value,
        lineDiscount: json["lineDiscount"] ?? 0,
        discount: json["discount"] ?? 0,
        discountAvailable: json["discountAvailable"] ?? false,
        openPrice: json["openPrice"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Qty": qty,
        "Price": price,
        "PriceChange": priceChange,
        "Total": total,
        "Tax": tax,
        "LineDiscount": lineDiscount,
        "Discount": discount,
      };
}
