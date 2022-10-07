import 'dart:developer';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:restaurant_system/models/printer_invoice_model.dart';
import 'package:restaurant_system/models/printer_image_model.dart';

class Printer {
  static Future<void> invoices({required List<PrinterInvoiceModel> invoices}) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
    for (var invoice in invoices) {
      final printer = NetworkPrinter(PaperSize.mm80, profile);
      final cashPosPrintResult = await printer.connect(invoice.ipAddress, port: invoice.port); // invoice.ipAddress
      if (cashPosPrintResult == PosPrintResult.success) {
        try {
          printImage(printer, invoice.invoice!);
          await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
          log('cashPrinter catch ${e.toString()} || ${invoice.ipAddress}:${invoice.port}');
        }
      } else {
        log('cashPrinter catch ${cashPosPrintResult.msg} || ${invoice.ipAddress}:${invoice.port}');
      }
    }
  }

  static Future<void> payInOut({required PrinterImageModel printerImageModel}) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
      final printer = NetworkPrinter(PaperSize.mm80, profile);
      final cashPosPrintResult = await printer.connect(printerImageModel.ipAddress, port: printerImageModel.port);
      if (cashPosPrintResult == PosPrintResult.success) {
        try {
          printImage(printer, printerImageModel.image!);
          await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 200));
          log('cashPrinter catch ${e.toString()} || ${printerImageModel.ipAddress}:${printerImageModel.port}');
        }
      } else {
        log('cashPrinter catch ${cashPosPrintResult.msg} || ${printerImageModel.ipAddress}:${printerImageModel.port}');
      }
  }

  static void printImage(NetworkPrinter printer, Uint8List invoice)  {
    final img.Image? image = img.decodeImage(invoice);
    printer.image(image!, align: PosAlign.center);
    printer.cut();
  }
}
