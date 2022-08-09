import 'package:equatable/equatable.dart';
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
    this.cash = 0,
    this.credit = 0,
    this.cheque = 0,
    this.coupon = 0,
    this.gift = 0,
    this.point = 0,
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
  double cash;
  double credit;
  double cheque;
  double coupon;
  double gift;
  double point;

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

  factory CartModel.fromJson(Map<String, dynamic> json) => CartModel(
        orderType: OrderType.values[json['orderType']],
        id: json['id'],
        total: json['total'] == null ? 0 : json['total'].toDouble(),
        deliveryCharge: json['deliveryCharge'] == null ? 0 : json['deliveryCharge'].toDouble(),
        lineDiscount: json['lineDiscount'] == null ? 0 : json['lineDiscount'].toDouble(),
        discount: json['discount'] == null ? 0 : json['discount'].toDouble(),
        discountType: DiscountType.values[json['discountType']],
        subTotal: json['subTotal'] == null ? 0 : json['subTotal'].toDouble(),
        service: json['service'] == null ? 0 : json['service'].toDouble(),
        serviceTax: json['serviceTax'] == null ? 0 : json['serviceTax'].toDouble(),
        itemsTax: json['itemsTax'] == null ? 0 : json['itemsTax'].toDouble(),
        tax: json['tax'] == null ? 0 : json['tax'].toDouble(),
        amountDue: json['amountDue'] == null ? 0 : json['amountDue'].toDouble(),
        items: List<CartItemModel>.from(json['items'].map((e) => CartItemModel.fromJson(e))),
        cash: json['cash'] == null ? 0 : json['cash'].toDouble(),
        credit: json['credit'] == null ? 0 : json['credit'].toDouble(),
        cheque: json['cheque'] == null ? 0 : json['cheque'].toDouble(),
        coupon: json['coupon'] == null ? 0 : json['coupon'].toDouble(),
        gift: json['gift'] == null ? 0 : json['gift'].toDouble(),
        point: json['point'] == null ? 0 : json['point'].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'orderType': orderType.index,
        'id': id,
        'total': total,
        'deliveryCharge': deliveryCharge,
        'lineDiscount': lineDiscount,
        'discount': discount,
        'discountType': discountType.index,
        'subTotal': subTotal,
        'service': service,
        'serviceTax': serviceTax,
        'itemsTax': itemsTax,
        'tax': tax,
        'amountDue': amountDue,
        'items': List<dynamic>.from(items.map((e) => e.toJson())),
        'cash': cash,
        'credit': credit,
        'cheque': cheque,
        'coupon': coupon,
        'gift': gift,
        'point': point,
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": DateTime.now().year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "InvDate": DateTime.now().toIso8601String(),
        "TotalService": service, // مجموع سيرفس قبل الضريبة
        "TotalServiceTax": serviceTax, // ضريبة السيرفس فقط
        "TotalTax": itemsTax, // ضريبة بدو ضريبة السيرفس
        "InvDisc": discount, // الخصم الكلي على الفتورة
        "TotalItemDisc": lineDiscount, // مجموع discount line
        "DeliveryCharge": deliveryCharge, // مجموع توصيل
        "InvNetTotal": amountDue, // المجموع نهائي بعد كل اشي
        "PayType": 0, // 0
        "CashVal": cash, // كم دفع كاش
        "CardsVal": credit, // كم دفع كردت
        "ChequeVal": cheque, // كم دفع شيكات
        "CouponVal": coupon, // كم دفع كوبونات
        "GiftVal": gift, //
        "PointsVal": point, //
        "UserId": orderType == OrderType.takeAway ? mySharedPreferences.employee.id : 0, // Take away - EmplyeId, Dine In -
        "ShiftId": 0, //
        "WaiterId": orderType == OrderType.takeAway ? mySharedPreferences.employee.id : 0, //Take away - EmplyeId, Dine In -
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
    this.parentItemId = 0,
    this.parentItemIndex = 0,
    this.isDeleted = false,
  });

  OrderType orderType;
  int id;
  int parentItemId;
  int parentItemIndex;
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
  bool isDeleted = true;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        orderType: OrderType.values[json['orderType']],
        id: json['id'],
        parentItemId: json['parentItemId'],
        parentItemIndex: json['parentItemIndex'],
        categoryId: json['categoryId'],
        taxType: json['taxType'],
        taxPercent: json['taxPercent'] == null ? 0 : json['taxPercent'].toDouble(),
        name: json['name'],
        qty: json['qty'],
        price: json['price'] == null ? 0 : json['price'].toDouble(),
        priceChange: json['priceChange'] == null ? 0 : json['priceChange'].toDouble(),
        total: json['total'] == null ? 0 : json['total'].toDouble(),
        tax: json['tax'] == null ? 0 : json['tax'].toDouble(),
        lineDiscountType: DiscountType.values[json['lineDiscountType']],
        lineDiscount: json['lineDiscount'] == null ? 0 : json['lineDiscount'].toDouble(),
        discount: json['discount'] == null ? 0 : json['discount'].toDouble(),
        service: json['service'] == null ? 0 : json['service'].toDouble(),
        serviceTax: json['serviceTax'] == null ? 0 : json['serviceTax'].toDouble(),
        discountAvailable: json['discountAvailable'],
        openPrice: json['openPrice'],
        rowSerial: json['rowSerial'],
        modifiers: List<CartItemModifierModel>.from(json['modifiers'].map((e) => CartItemModifierModel.fromJson(e))),
        questions: List<CartItemQuestionModel>.from(json['questions'].map((e) => CartItemQuestionModel.fromJson(e))),
        isDeleted: json['isDeleted'],
      );

  Map<String, dynamic> toJson() => {
        "orderType": orderType.index,
        "id": id,
        "parentItemId": parentItemId,
        "parentItemIndex": parentItemIndex,
        "categoryId": categoryId,
        "taxType": taxType,
        "taxPercent": taxPercent,
        "name": name,
        "qty": qty,
        "price": price,
        "priceChange": priceChange,
        "total": total,
        "tax": tax,
        "lineDiscountType": lineDiscountType.index,
        "lineDiscount": lineDiscount,
        "discount": discount,
        "service": service,
        "serviceTax": serviceTax,
        "discountAvailable": discountAvailable,
        "openPrice": openPrice,
        "rowSerial": rowSerial,
        "modifiers": List<dynamic>.from(modifiers.map((e) => e.toJson())),
        "questions": List<dynamic>.from(questions.map((e) => e.toJson())),
        "isDeleted": isDeleted,
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": DateTime.now().year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "StoreNo": mySharedPreferences.storeNo, // StoreNo
        "InvDate": DateTime.now().toIso8601String(),
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
    required this.question,
    required this.modifiers,
  });

  int id;
  String question;
  List<String> modifiers;

  factory CartItemQuestionModel.init() => CartItemQuestionModel(
        id: 0,
        question: "",
        modifiers: const [],
      );

  factory CartItemQuestionModel.fromJson(Map<String, dynamic> json) => CartItemQuestionModel(
        id: json["Id"] ?? 0,
        question: json["Name"] ?? "",
        modifiers: json["Modifier"] == null ? [] : List<String>.from(json["Modifier"].map((e) => e)),
      );

  Map<String, dynamic> toJson() => {
        "Id": id,
        "Name": question,
        "Modifier": modifiers,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [id, question, modifiers];
}
