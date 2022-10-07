import 'dart:typed_data';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:screenshot/screenshot.dart';

class PrinterInvoiceModel {
  PrinterInvoiceModel({
    required this.ipAddress,
    required this.port,
    required this.items,
    required this.screenshotController,
    this.invoice,
  });

  String ipAddress;
  int port;
  List<CartItemModel> items;
  ScreenshotController screenshotController;
  Uint8List? invoice;
}
