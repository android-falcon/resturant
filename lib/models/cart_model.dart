import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/utils/enum_discount_type.dart';
import 'package:restaurant_system/utils/enum_order_type.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

class CartModel {
  CartModel({
    required this.orderType,
    required this.id,
    required this.total,
    required this.deliveryCharge,
    required this.lineDiscount,
    required this.discount,
    this.discountType = DiscountType.percentage,
    required this.subTotal,
    required this.service,
    required this.serviceTax,
    required this.itemsTax,
    required this.tax,
    required this.amountDue,
    required this.items,
  });

  OrderType orderType;
  int id;
  double total;
  double deliveryCharge;
  double lineDiscount;
  double discount;
  DiscountType discountType;
  double subTotal;
  double service;
  double serviceTax;
  double itemsTax;
  double tax;
  double amountDue;
  List<CartItemModel> items;

  factory CartModel.init({required OrderType orderType}) => CartModel(
        orderType: orderType,
        id: 0,
        total: 0,
        deliveryCharge: 0,
        lineDiscount: 0,
        discount: 0,
        discountType: DiscountType.percentage,
        subTotal: 0,
        service: 0,
        serviceTax: 0,
        itemsTax: 0,
        tax: 0,
        amountDue: 0,
        items: [],
      );

  Map<String, dynamic> toInvoice() => {
        "CoYear": DateTime.now().year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "InvDate": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
        "TotalService": service, // مجموع سيرفس قبل الضريبة
        "TotalServiceTax": serviceTax, // ضريبة السيرفس فقط
        "TotalTax": itemsTax, // ضريبة بدو ضريبة السيرفس
        "InvDisc": discount, // الخصم الكلي على الفتورة
        "TotalItemDisc": lineDiscount, // مجموع discount line
        "DeliveryCharge": deliveryCharge, // مجموع توصيل
        "InvNetTotal": amountDue, // المجموع نهائي بعد كل اشي
        "PayType": 0, // 0
        "CashVal": 0, // كم دفع كاش
        "CardsVal": 0, // كم دفع كردت
        "ChequeVal": 0, // كم دفع شيكات
        "CouponVal": 0, // كم دفع كوبونات
        "GiftVal": 0, //
        "PointsVal": 0, //
        "UserId": orderType == OrderType.takeAway ? mySharedPreferences.userId : 0, // Take away - EmplyeId, Dine In -
        "ShiftId": 0, //
        "WaiterId":  orderType == OrderType.takeAway ? mySharedPreferences.userId : 0, //Take away - EmplyeId, Dine In -
        "TableId": 0, //
        "NoOfSeats": 0 //
      };
}

class CartItemModel {
  CartItemModel({
    required this.orderType,
    required this.id,
    required this.categoryId,
    required this.taxType,
    required this.taxPercent,
    required this.name,
    required this.qty,
    required this.price,
    required this.priceChange,
    required this.total,
    required this.tax,
    required this.rowSerial,
    this.lineDiscountType = DiscountType.percentage,
    this.lineDiscount = 0,
    this.discount = 0,
    this.service = 0,
    this.serviceTax = 0,
    this.discountAvailable = false,
    this.openPrice = false,
    this.modifiers = const [],
    this.questions = const [],
  });

  OrderType orderType;
  int id;
  int categoryId;
  int taxType;
  double taxPercent;
  String name;
  int qty;
  double price;
  double priceChange;
  double total;
  double tax;
  DiscountType lineDiscountType;
  double lineDiscount;
  double discount;
  double service;
  double serviceTax;
  bool discountAvailable;
  bool openPrice;
  int rowSerial;
  List<CartItemModifierModel> modifiers;
  List<CartItemQuestionModel> questions;

  Map<String, dynamic> toInvoice() => {
        "CoYear": DateTime.now().year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "StoreNo": mySharedPreferences.storeNo, // StoreNo
        "InvDate": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now()),
        "RowSerial": rowSerial, // رقم الايتم بناء على ليست في شاشة index + 1
        "ItemId": id,
        "Qty": qty,
        "Price": priceChange, // السعر بعد تعديل الي بنحسب في الفتورة
        "OrgPrice": price, // السعر الايتم الفعلي
        "InvDisc": discount, // قيمة الخصم من الخصم الكلي ل هذا اليتم فقط
        "ItemDisc": lineDiscount, // قيمة الخصم في linedicount
        "ServiceVal": service, //  قيمة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة -- بنوزعها على الفتورة
        "ServiceTax": serviceTax, // قيمة ضريبة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة  -- بنوزعها على الفتورة
        "ItemTaxKind": taxType, // TaxType/Id
        "ItemTaxPerc": taxPercent, // TaxPerc/TaxPercent
        "ItemTaxVal": tax, // قيمة ضريبة الايتم بدون ضريبة السيرفس
        "NetTotal": total, // المجموع النهائي للايتم مع الضريبة وسيرفس وضريبة السيرفس
        "ReturnedQty": 0 //
      };
}

class CartItemModifierModel extends Equatable {
  CartItemModifierModel({
    required this.id,
    required this.name,
    required this.modifier,
  });

  int id;
  String name;
  String modifier;

  factory CartItemModifierModel.init() => CartItemModifierModel(
        id: 0,
        name: "",
        modifier: "",
      );

  factory CartItemModifierModel.fromJson(Map<String, dynamic> json) => CartItemModifierModel(
        id: json["Id"] ?? 0,
        name: json["Name"] ?? "",
        modifier: json["Modifier"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Modifier": modifier,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, modifier];
}

class CartItemQuestionModel extends Equatable {
  CartItemQuestionModel({
    required this.id,
    required this.name,
    required this.modifier,
  });

  int id;
  String name;
  String modifier;

  factory CartItemQuestionModel.init() => CartItemQuestionModel(
        id: 0,
        name: "",
        modifier: "",
      );

  factory CartItemQuestionModel.fromJson(Map<String, dynamic> json) => CartItemQuestionModel(
        id: json["Id"] ?? 0,
        name: json["Name"] ?? "",
        modifier: json["Modifier"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": name,
        "Modifier": modifier,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [id, name, modifier];
}
