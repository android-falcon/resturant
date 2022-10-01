import 'package:equatable/equatable.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/refund_model.dart';
import 'package:restaurant_system/utils/enums/enum_discount_type.dart';
import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

class CartModel extends Equatable {
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
    this.parkName = '',
    this.invNo = 0,
    this.posNo = 0,
    this.cashNo = 0,
    this.storeNo = 0,
    this.invDate = '',
    this.returnedTotal = 0,
  });

  OrderType orderType;
  int invNo;
  int posNo;
  int cashNo;
  int storeNo;
  String invDate;
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
  double returnedTotal;
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
  String parkName;

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
        orderType: OrderType.values[(json['orderType'] ?? 0)],
        id: json['id'] ?? 0,
        total: json['total'] == null ? 0 : json['total'].toDouble(),
        deliveryCharge: json['deliveryCharge'] == null ? 0 : json['deliveryCharge'].toDouble(),
        totalLineDiscount: json['totalLineDiscount'] == null ? 0 : json['totalLineDiscount'].toDouble(),
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
        creditCardType: json['creditCardType'] ?? "",
        cheque: json['cheque'] == null ? 0 : json['cheque'].toDouble(),
        coupon: json['coupon'] == null ? 0 : json['coupon'].toDouble(),
        gift: json['gift'] == null ? 0 : json['gift'].toDouble(),
        point: json['point'] == null ? 0 : json['point'].toDouble(),
        tableNo: json['tableNo'] ?? 0,
        note: json['note'] ?? '',
        payCompanyId: json['payCompanyId'] ?? 0,
        deliveryCompanyId: json['deliveryCompanyId'] ?? 0,
        parkName: json['parkName'] ?? '',
      );

  factory CartModel.fromJsonRefund(Map<String, dynamic> json) => CartModel(
        orderType: OrderType.values[(json["InvoiceMaster"]?['InvType'] ?? 0)],
        invNo: json["InvoiceMaster"]?["InvNo"] ?? 0,
        posNo: json["InvoiceMaster"]?["PosNo"] ?? 0,
        cashNo: json["InvoiceMaster"]?["CashNo"] ?? 0,
        storeNo: json["InvoiceMaster"]?["StoreNo"] ?? 0,
        invDate: json["InvoiceMaster"]?["InvDate"] ?? '0000-00-00T00:00:00',
        id: 0,
        total: 0,
        deliveryCharge: 0,
        totalLineDiscount: json["InvoiceMaster"]?['TotalItemDisc']?.toDouble() ?? 0,
        totalDiscount: json["InvoiceMaster"]?['InvDisc']?.toDouble() ?? 0,
        discount: 0,
        discountType: DiscountType.value,
        subTotal: 0,
        service: json["InvoiceMaster"]?['TotalService']?.toDouble() ?? 0,
        serviceTax: json["InvoiceMaster"]?['TotalServiceTax']?.toDouble() ?? 0,
        itemsTax: json["InvoiceMaster"]?['TotalTax']?.toDouble() ?? 0,
        tax: 0,
        amountDue: json["InvoiceMaster"]?['InvNetTotal']?.toDouble() ?? 0,
        items: json['InvoiceDetails'] == null ? [] : List<CartItemModel>.from(json['InvoiceDetails'].map((e) => CartItemModel.fromJsonReturn(e))),
        cash: 0,
        credit: 0,
        creditCardNumber: "",
        creditCardType: "",
        cheque: 0,
        coupon: 0,
        gift: 0,
        point: 0,
        tableNo: 0,
        note: '',
        payCompanyId: 0,
        deliveryCompanyId: 0,
        parkName: '',
      );

  Map<String, dynamic> toJson() => {
        'orderType': orderType.index,
        'id': id,
        'total': total,
        'deliveryCharge': deliveryCharge,
        'totalLineDiscount': totalLineDiscount,
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
        'creditCardType': creditCardType,
        'cheque': cheque,
        'coupon': coupon,
        'gift': gift,
        'point': point,
        'tableNo': tableNo,
        'note': note,
        'payCompanyId': payCompanyId,
        'deliveryCompanyId': deliveryCompanyId,
        'parkName': parkName,
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": InvoiceKind.invoicePay.index, // 0 - Pay , 1 - Return
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
        "InvFlag": 1,
      };

  Map<String, dynamic> toReturnInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": InvoiceKind.invoiceReturn.index, // 0 - Pay , 1 - Return
        "InvNo": invNo, // الرقم الي بعد منو VocNo
        "PosNo": posNo, // PosNo
        "CashNo": cashNo, // CashNo
        "InvDate": mySharedPreferences.dailyClose.toIso8601String(),
        "TotalService": service, // مجموع سيرفس قبل الضريبة
        "TotalServiceTax": serviceTax, // ضريبة السيرفس فقط
        "TotalTax": itemsTax, // ضريبة بدو ضريبة السيرفس
        "InvDisc": totalDiscount, // الخصم الكلي على الفتورة
        "TotalItemDisc": totalLineDiscount, // مجموع discount line
        "DeliveryCharge": deliveryCharge, // مجموع توصيل
        "InvNetTotal": amountDue, // المجموع نهائي بعد كل اشي
        "PayType": 0,
        "CashVal": cash,
        "CardsVal": 0,
        "ChequeVal": 0,
        "CouponVal": 0,
        "GiftVal": 0,
        "PointsVal": 0,
        "UserId": 0,
        "ShiftId": 0,
        "WaiterId": 0,
        "TableId": 0,
        "NoOfSeats": 0,
        "SaleInvNo": 0,
        "Card1Name": '',
        "Card1Code": '',
        "PayCompanyId": 0,
        "DeliveryCompanyId": 0,
        "InvFlag": -1,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [orderType, id, total, deliveryCharge, totalLineDiscount, totalDiscount, discount, discountType, subTotal, service, serviceTax, itemsTax, tax, amountDue, items, cash, credit, creditCardNumber, creditCardType, cheque, coupon, gift, point, tableNo, note, payCompanyId, deliveryCompanyId, parkName];
}

class CartItemModel extends Equatable {
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
    this.isCombo = false,
    this.invNo = 0,
    this.posNo = 0,
    this.cashNo = 0,
    this.storeNo = 0,
    this.returnedQty = 0,
    this.returnedPrice = 0,
    this.returnedTotal = 0,
  });

  String uuid;
  String parentUuid;
  OrderType orderType;
  int invNo;
  int posNo;
  int cashNo;
  int storeNo;
  int returnedQty;
  double returnedPrice;
  double returnedTotal;
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
  bool isCombo;
  List<CartItemModifierModel> modifiers;
  List<CartItemQuestionModel> questions;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        orderType: OrderType.values[json['orderType'] ?? 0],
        id: json['id'] ?? 0,
        uuid: json['uuid'] ?? '',
        parentUuid: json['parentUuid'] ?? '',
        categoryId: json['categoryId'] ?? 0,
        taxType: json['taxType'] ?? 0,
        taxPercent: json['taxPercent'] == null ? 0 : json['taxPercent'].toDouble(),
        name: json['name'] ?? '',
        qty: json['qty'] ?? 0,
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
        discountAvailable: json['discountAvailable'] ?? false,
        openPrice: json['openPrice'] ?? false,
        rowSerial: json['rowSerial'] ?? 0,
        note: json['note'] ?? '',
        isCombo: json['isCombo'] ?? false,
        modifiers: json['modifiers'] == null ? [] : List<CartItemModifierModel>.from(json['modifiers'].map((e) => CartItemModifierModel.fromJson(e))),
        questions: json['questions'] == null ? [] : List<CartItemQuestionModel>.from(json['questions'].map((e) => CartItemQuestionModel.fromJson(e))),
      );

  factory CartItemModel.fromJsonReturn(Map<String, dynamic> json) => CartItemModel(
        orderType: OrderType.values[json['InvType'] ?? 0],
        invNo: json["InvNo"] ?? 0,
        posNo: json["PosNo"] ?? 0,
        cashNo: json["CashNo"] ?? 0,
        storeNo: json["StoreNo"] ?? 0,
        rowSerial: json["RowSerial"] ?? 0,
        isCombo: (json["IsCombo"] ?? 0) == 1 ? true : false,
        note: json["ItemRemark"] ?? "",
        id: json["ItemId"] ?? 0,
        qty: json["Qty"]?.toInt() ?? 0,
        priceChange: json["Price"]?.toDouble() ?? 0,
        price: json["OrgPrice"]?.toDouble() ?? 0,
        discount: json["InvDisc"]?.toDouble() ?? 0,
        service: json["ServiceVal"]?.toDouble() ?? 0,
        serviceTax: json["ServiceTax"]?.toDouble() ?? 0,
        taxType: json["ItemTaxKind"] ?? 0,
        taxPercent: json["ItemTaxPerc"]?.toDouble() ?? 0,
        tax: json["ItemTaxVal"]?.toDouble() ?? 0,
        totalLineDiscount: json["LineDisc"]?.toDouble() ?? 0,
        total: json["NetTotal"]?.toDouble() ?? 0,
        returnedQty: json["ReturnedQty"]?.toInt() ?? 0,
        uuid: json["UUID"] ?? '',
        parentUuid: json["ParentUUID"] ?? '',
        categoryId: 0,
        name: allDataModel.items.firstWhereOrNull((element) => element.id == (json["ItemId"] ?? 0))?.menuName ?? "",
      );

  Map<String, dynamic> toJson() => {
        "orderType": orderType.index,
        "id": id,
        "uuid": uuid,
        "parentUuid": parentUuid,
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
        "isCombo": isCombo,
        "modifiers": List<dynamic>.from(modifiers.map((e) => e.toJson())),
        "questions": List<dynamic>.from(questions.map((e) => e.toJson())),
      };

  Map<String, dynamic> toInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": InvoiceKind.invoicePay.index, // 0 - Pay , 1 - Return
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
        "ItemDiscPerc": 0, //
        "LineDisc": totalLineDiscount, // قيمة الخصم في linedicount
        "ServiceVal": service, //  قيمة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة -- بنوزعها على الفتورة
        "ServiceTax": serviceTax, // قيمة ضريبة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة  -- بنوزعها على الفتورة
        "ItemTaxKind": taxType, // TaxType/Id
        "ItemTaxPerc": taxPercent, // TaxPerc/TaxPercent
        "ItemTaxVal": tax, // قيمة ضريبة الايتم بدون ضريبة السيرفس
        "NetTotal": total, // المجموع النهائي للايتم مع الضريبة وسيرفس وضريبة السيرفس
        "ReturnedQty": 0, //
        "ItemRemark": note,
        "IsCombo": isCombo ? 1 : 0,
        "IsSubItem": parentUuid != "" ? 1 : 0,
        "UUID": uuid,
        "ParentUUID": parentUuid,
      };

  Map<String, dynamic> toReturnInvoice() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": InvoiceKind.invoiceReturn.index, // 0 - Pay , 1 - Return
        "InvNo": invNo, // الرقم الي بعد منو VocNo
        "PosNo": posNo, // PosNo
        "CashNo": cashNo, // CashNo
        "StoreNo": storeNo, // StoreNo
        "InvDate": mySharedPreferences.dailyClose.toIso8601String(),
        "RowSerial": rowSerial, // رقم الايتم بناء على ليست في شاشة index + 1
        "ItemId": id,
        "Qty": qty,
        "Price": priceChange, // السعر بعد تعديل الي بنحسب في الفتورة
        "OrgPrice": price, // السعر الايتم الفعلي
        "InvDisc": discount, // قيمة الخصم من الخصم الكلي ل هذا اليتم فقط
        "ItemDiscPerc": 0, //
        "LineDisc": totalLineDiscount, // قيمة الخصم في linedicount
        "ServiceVal": service, //  قيمة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة -- بنوزعها على الفتورة
        "ServiceTax": serviceTax, // قيمة ضريبة سيرفس للايتم بناء على سعر الايتم ل مجموع الفتورة  -- بنوزعها على الفتورة
        "ItemTaxKind": taxType, // TaxType/Id
        "ItemTaxPerc": taxPercent, // TaxPerc/TaxPercent
        "ItemTaxVal": tax, // قيمة ضريبة الايتم بدون ضريبة السيرفس
        "NetTotal": total, // المجموع النهائي للايتم مع الضريبة وسيرفس وضريبة السيرفس
        "ReturnedQty": 0, //
        "ItemRemark": note,
        "IsCombo": isCombo ? 1 : 0,
        "IsSubItem": parentUuid != "" ? 1 : 0,
        "UUID": uuid,
        "ParentUUID": parentUuid,
      };

  Map<String, dynamic> toReturnInvoiceQty() => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvKind": InvoiceKind.invoiceReturn.index,
        "InvNo": invNo,
        "PosNo": posNo,
        "CashNo": cashNo,
        "RowSerial": rowSerial,
        "Id": id,
        "RQty": returnedQty,
      };

  @override
  // TODO: implement props
  List<Object?> get props => [uuid, parentUuid, orderType, id, categoryId, taxType, taxPercent, name, qty, price, priceChange, total, tax, lineDiscountType, lineDiscount, totalLineDiscount, discount, service, serviceTax, discountAvailable, openPrice, rowSerial, note, isCombo, modifiers, questions];
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
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        modifier: json["modifier"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "modifier": modifier,
      };

  Map<String, dynamic> toInvoice({required int itemId, required int rowSerial, required OrderType orderType}) => {
        "CoYear": mySharedPreferences.dailyClose.year,
        "InvType": orderType.index, // 0 - Take away , 1 - Dine In
        "InvKind": 0, // 0 - Pay , 1 - Return
        "InvNo": mySharedPreferences.inVocNo, // الرقم الي بعد منو VocNo
        "PosNo": mySharedPreferences.posNo, // PosNo
        "CashNo": mySharedPreferences.cashNo, // CashNo
        "InvDate": mySharedPreferences.dailyClose.toIso8601String(),
        "RowSerial": rowSerial, // رقم الايتم بناء على ليست في شاشة index + 1
        "ItemId": itemId,
        "ModifireId": id
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
  List<CartItemModifierModel> modifiers;

  factory CartItemQuestionModel.init() => CartItemQuestionModel(
        id: 0,
        question: "",
        modifiers: const [],
      );

  factory CartItemQuestionModel.fromJson(Map<String, dynamic> json) => CartItemQuestionModel(
        id: json["id"] ?? 0,
        question: json["question"] ?? "",
        modifiers: json["modifiers"] == null ? [] : List<CartItemModifierModel>.from(json["modifiers"].map((e) => CartItemModifierModel.fromJson(e))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "question": question,
        "modifiers": List<dynamic>.from(modifiers.map((e) => e.toJson())).toList(),
      };

  @override
  // TODO: implement props
  List<Object?> get props => [id, question, modifiers];
}
