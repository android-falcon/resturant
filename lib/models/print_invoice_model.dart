import 'dart:typed_data';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:screenshot/screenshot.dart';

class PrintInvoiceModel {
  PrintInvoiceModel({
    required this.ipAddress,
    required this.items,
    required this.screenshotController,
    this.invoice,
  });

  String ipAddress;
  List<CartItemModel> items;
  ScreenshotController screenshotController;
  Uint8List? invoice;
}
