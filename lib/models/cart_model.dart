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
    required this.totalLineDiscount,
    required this.totalDiscount,
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
    this.creditCardNumber = '',
    this.creditCardType = '',
    this.cheque = 0,
    this.coupon = 0,
    this.gift = 0,
    this.point = 0,
    this.tableNo = 0,
    this.note = '',
    this.payCompanyId = 0,
    this.deliveryCompanyId = 0,
  });

  OrderType orderType;
  int id;
  double total;
  double deliveryCharge;
  double totalLineDiscount;
  double totalDiscount;
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
  String creditCardNumber;
  String creditCardType;
  double cheque;
  double coupon;
  double gift;
  double point;
  int tableNo;
  String note;
  int payCompanyId;
  int deliveryCompanyId;

  factory CartModel.init({required OrderType orderType}) => CartModel(
        orderType: orderType,
        id: 0,
        total: 0,
        deliveryCharge: 0,
        totalLineDiscount: 0,
        totalDiscount: 0,
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
        totalLineDiscount: json['lineDiscount'] == null ? 0 : json['lineDiscount'].toDouble(),
        totalDiscount: json['totalDiscount'] == null ? 0 : json['totalDiscount'].toDouble(),
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
        creditCardNumber: json['creditCardNumber'] ?? "",
        cheque: json['cheque'] == null ? 0 : json['cheque'].toDouble(),
        coupon: json['coupon'] == null ? 0 : json['coupon'].toDouble(),
        gift: json['gift'] == null ? 0 : json['gift'].toDouble(),
        point: json['point'] == null ? 0 : json['point'].toDouble(),
        tableNo: json['tableNo'] ?? 0,
        note: json['note'] ?? '',
        payCompanyId: json['payCompanyId'] ?? 0,
        deliveryCompanyId: json['deliveryCompanyId'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'orderType': orderType.index,
        'id': id,
        'total': total,
        'deliveryCharge': deliveryCharge,
        'lineDiscount': totalLineDiscount,
        'totalDiscount': totalDiscount,
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
        'creditCardNumber': creditCardNumber,
        'cheque': cheque,
        'coupon': coupon,
        'gift': gift,
        'point': point,
        'tableNo': tableNo,
        'note': note,
        'payCompanyId': payCompanyId,
        'deliveryCompanyId': deliveryCompanyId,
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "InvDate": mySharedPreferences.dailyClose.toIso8601String(),
        "TotalService": service, // مجموع سيرفس قبل الضريبة
        "TotalServiceTax": serviceTax, // ضريبة السيرفس فقط
        "TotalTax": itemsTax, // ضريبة بدو ضريبة السيرفس
        "InvDisc": totalDiscount, // الخصم الكلي على الفتورة
        "TotalItemDisc": totalLineDiscount, // مجموع discount line
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
        "NoOfSeats": 0, //
        "SaleInvNo": 0,
        "Card1Name": creditCardType,
        "Card1Code": creditCardNumber,
        "PayCompanyId": payCompanyId,
        "DeliveryCompanyId": deliveryCompanyId,
      };

// Map<String, dynamic> toKitchen(String kitchenId) => {
//   'orderNo': mySharedPreferences.inVocNo,
//   'tableNo': tableNo,
//   'sectionNo': 0,
//   'orderType': orderType.index,
//   'items': items.where((element) => false)
// };
// {
// 'orderNo': 1,
// 'tableNo': 2,
// 'sectionNo': 3,
// 'orderType': 1,
// 'items': [
// {
// 'itemName': 'Shawrma',
// 'qty': 1,
// 'note': 'ana',
// },
// {
// 'itemName': 'Shawrma',
// 'qty': 1,
// 'note': 'ana',
// },
// ],
// }
}

class CartItemModel {
  CartItemModel({
    required this.uuid,
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
    this.totalLineDiscount = 0,
    this.discount = 0,
    this.service = 0,
    this.serviceTax = 0,
    this.discountAvailable = false,
    this.openPrice = false,
    this.modifiers = const [],
    this.questions = const [],
    this.parentUuid = '',
    this.note = '',
  });

  String uuid;
  String parentUuid;
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
  double totalLineDiscount;
  double discount;
  double service;
  double serviceTax;
  bool discountAvailable;
  bool openPrice;
  int rowSerial;
  String note;
  List<CartItemModifierModel> modifiers;
  List<CartItemQuestionModel> questions;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        orderType: OrderType.values[json['orderType']],
        id: json['id'],
        uuid: json['randomId'],
        parentUuid: json['parentRandomId'],
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
        totalLineDiscount: json['totalLineDiscount'] == null ? 0 : json['totalLineDiscount'].toDouble(),
        discount: json['discount'] == null ? 0 : json['discount'].toDouble(),
        service: json['service'] == null ? 0 : json['service'].toDouble(),
        serviceTax: json['serviceTax'] == null ? 0 : json['serviceTax'].toDouble(),
        discountAvailable: json['discountAvailable'],
        openPrice: json['openPrice'],
        rowSerial: json['rowSerial'],
        note: json['note'],
        modifiers: List<CartItemModifierModel>.from(json['modifiers'].map((e) => CartItemModifierModel.fromJson(e))),
        questions: List<CartItemQuestionModel>.from(json['questions'].map((e) => CartItemQuestionModel.fromJson(e))),
      );

  Map<String, dynamic> toJson() => {
        "orderType": orderType.index,
        "id": id,
        "randomId": uuid,
        "parentRandomId": parentUuid,
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
        "totalLineDiscount": totalLineDiscount,
        "discount": discount,
        "service": service,
        "serviceTax": serviceTax,
        "discountAvailable": discountAvailable,
        "openPrice": openPrice,
        "rowSerial": rowSerial,
        "note": note,
        "modifiers": List<dynamic>.from(modifiers.map((e) => e.toJson())),
        "questions": List<dynamic>.from(questions.map((e) => e.toJson())),
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "StoreNo": mySharedPreferences.storeNo, // StoreNo
        "InvDate": mySharedPreferences.dailyClose.toIso8601String(),
        "RowSerial": rowSerial, // رقم الايتم بناء على ليست في شاشة index + 1
        "ItemId": id,
        "Qty": qty,
        "Price": priceChange, // السعر بعد تعديل الي بنحسب في الفتورة
        "OrgPrice": price, // السعر الايتم الفعلي
        "InvDisc": discount, // قيمة الخصم من الخصم الكلي ل هذا اليتم فقط
        "ItemDisc": totalLineDiscount, // قيمة الخصم في linedicount
        "ServiceVal": service, //  قيمة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة -- بنوزعها على الفتورة
        "ServiceTax": serviceTax, // قيمة ضريبة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة  -- بنوزعها على الفتورة
        "ItemTaxKind": taxType, // TaxType/Id
        "ItemTaxPerc": taxPercent, // TaxPerc/TaxPercent
        "ItemTaxVal": tax, // قيمة ضريبة الايتم بدون ضريبة السيرفس
        "NetTotal": total, // المجموع النهائي للايتم مع الضريبة وسيرفس وضريبة السيرفس
        "ReturnedQty": 0, //
        "ItemRemark": note,
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
