import 'dart:typed_data';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:screenshot/screenshot.dart';

class PrinterImageModel {
  PrinterImageModel({
    required this.ipAddress,
    required this.port,
    this.image,
  });

  String ipAddress;
  int port;
  Uint8List? image;
}
