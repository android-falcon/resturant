import 'dart:developer';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:restaurant_system/models/print_invoice_model.dart';

class PrintInvoice {
  static init({required List<PrintInvoiceModel> invoices}) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
    for (var invoice in invoices) {
      final printer = NetworkPrinter(PaperSize.mm80, profile);
      final cashPosPrintResult = await printer.connect(invoice.ipAddress, port: 9100); // invoice.ipAddress
      if (cashPosPrintResult == PosPrintResult.success) {
        try {
          printInvoiceImage(printer, invoice.invoice!);
          await Future.delayed(const Duration(seconds: 2, milliseconds: 500));
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          printer.disconnect();
          await Future.delayed(const Duration(milliseconds: 100));
          log('cashPrinter catch ${e.toString()}');
        }
      } else {
        log('cashPrinter catch ${cashPosPrintResult.msg} ${invoice.ipAddress}');
      }
    }
  }

  static void printInvoiceImage(NetworkPrinter printer, Uint8List invoice) async {
    final img.Image? image = img.decodeImage(invoice);
    printer.image(image!, align: PosAlign.center);
    printer.cut();
  }
}
