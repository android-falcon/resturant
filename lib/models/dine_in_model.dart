import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';

class DineInModel {
  DineInModel({
    required this.isOpen,
    required this.isReservation,
    required this.isPrinted,
    required this.userId,
    required this.tableId,
    required this.tableNo,
    required this.floorNo,
    required this.cart,
  });

  bool isOpen;
  bool isReservation;
  bool isPrinted;
  int userId;
  int tableId;
  int tableNo;
  int floorNo;
  CartModel cart;

  factory DineInModel.init() => DineInModel(
        isOpen: false,
        isReservation: false,
        isPrinted: false,
        userId: 0,
        tableId: 0,
        tableNo: 0,
        floorNo: 0,
        cart: CartModel.init(orderType: OrderType.dineIn),
      );

  factory DineInModel.fromJson(Map<String, dynamic> json) => DineInModel(
        isOpen: json['isOpen'] ?? false,
        isReservation: json['isReservation'] ?? false,
        isPrinted: json['isPrinted'] ?? false,
        userId: json['userId'] ?? 0,
        tableId: json['tableId'] ?? 0,
        tableNo: json['tableNo'] ?? 0,
        floorNo: json['floorNo'] ?? 0,
        cart: json['cart'] == null ? CartModel.init(orderType: OrderType.dineIn) : CartModel.fromJson(json['cart']),
      );

  Map<String, dynamic> toJson() => {
        'isOpen': isOpen,
        'isReservation': isReservation,
        'isPrinted': isPrinted,
        'userId': userId,
        'tableId': tableId,
        'tableNo': tableNo,
        'floorNo': floorNo,
        'cart': cart.toJson(),
      };
}
