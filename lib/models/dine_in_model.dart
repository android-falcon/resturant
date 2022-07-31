import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/utils/enum_order_type.dart';

class DineInModel {
  DineInModel({
    required this.isOpen,
    required this.isReservation,
    required this.tableNo,
    required this.floorNo,
    required this.cart,
  });

  bool isOpen;
  bool isReservation;
  int tableNo;
  int floorNo;
  CartModel cart;

  factory DineInModel.init() => DineInModel(
    isOpen: false,
    isReservation: false,
    tableNo: 0,
    floorNo: 0,
    cart: CartModel.init(orderType: OrderType.dineIn),
  );

  factory DineInModel.fromJson(Map<String, dynamic> json) => DineInModel(
    isOpen: json['isOpen'],
    isReservation: json['isReservation'],
    tableNo: json['tableNo'],
    floorNo: json['floorNo'],
    cart: json['cart'] == null ? CartModel.init(orderType: OrderType.dineIn) : CartModel.fromJson(json['cart']),
  );

  Map<String, dynamic> toJson() => {
    'isOpen':isOpen,
    'isReservation':isReservation,
    'tableNo':tableNo,
    'floorNo':floorNo,
    'cart':cart.toJson(),
  };
}
