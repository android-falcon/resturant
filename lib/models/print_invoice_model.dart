import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:restaurant_system/models/cart_model.dart';

class PrintInvoiceModel {
  PrintInvoiceModel({
    required this.printerId,
    required this.networkPrinter,
    required this.posPrintResult,
    required this.invoiceNo,
    required this.orderType,
    required this.items,
  });

  int printerId;
  NetworkPrinter networkPrinter;
  PosPrintResult posPrintResult;
  int invoiceNo;
  String orderType;
  List<CartItemModel> items;
}
