import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';

class DineInModel {
  DineInModel({
    required this.isOpen,
    required this.isReservation,
    required this.tableId,
    required this.tableNo,
    required this.floorNo,
    required this.numberSeats,
    required this.cart,
  });

  bool isOpen;
  bool isReservation;
  int tableId;
  int tableNo;
  int floorNo;
  int numberSeats;
  CartModel cart;

  factory DineInModel.init() => DineInModel(
    isOpen: false,
    isReservation: false,
    tableId: 0,
    tableNo: 0,
    floorNo: 0,
    numberSeats: 0,
    cart: CartModel.init(orderType: OrderType.dineIn),
  );

  factory DineInModel.fromJson(Map<String, dynamic> json) => DineInModel(
    isOpen: json['isOpen'] ?? false,
    isReservation: json['isReservation'] ?? false,
    tableId: json['tableId'] ?? 0,
    tableNo: json['tableNo'] ?? 0,
    floorNo: json['floorNo'] ?? 0,
    numberSeats: json['numberSeats'] ?? 0,
    cart: json['cart'] == null ? CartModel.init(orderType: OrderType.dineIn) : CartModel.fromJson(json['cart']),
  );

  Map<String, dynamic> toJson() => {
    'isOpen':isOpen,
    'isReservation':isReservation,
    'tableId':tableId,
    'tableNo':tableNo,
    'floorNo':floorNo,
    'numberSeats':numberSeats,
    'cart':cart.toJson(),
  };
}
