import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pdf;
import 'package:pdf/src/pdf/page_format.dart' as pdf_format;
import 'package:printing/printing.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/print_invoice_model.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

extension PdfRasterExt on PdfRaster {
  img.Image asImage() {
    return img.Image.fromBytes(width, height, pixels);
  }
}

class Printer {
  // String imageUrl = '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'COMPANY_LOGO')?.imgPath ?? ''}${allDataModel.companyConfig.first.companyLogo}';

  static init({required CartModel cart}) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
    for (var printer in allDataModel.printers) {
      if (printer.cashNo == mySharedPreferences.cashNo) {
        final cashNetworkPrinter = NetworkPrinter(PaperSize.mm80, profile);
        final cashPosPrintResult = await cashNetworkPrinter.connect(printer.ipAddress, port: 9100);
        if (cashPosPrintResult == PosPrintResult.success) {
          try {
            // await printInvoiceImage(cashNetworkPrinter);
            await printInvoice(cashNetworkPrinter, cart);
            cashNetworkPrinter.disconnect();
            await Future.delayed(const Duration(seconds: 1));
          } catch (e) {
            cashNetworkPrinter.disconnect();
            log('cashPrinter catch ${e.toString()}');
          }
        } else {
          log('cashPrinter catch ${cashPosPrintResult.msg} ${printer.ipAddress}');
        }
      }
      var itemsPrinter = allDataModel.itemsPrintersModel.where((element) => element.kitchenPrinter.id == printer.id).toList();
      List<CartItemModel> cartItems = cart.items.where((element) => itemsPrinter.any((elementPrinter) => element.id == elementPrinter.itemId)).toList();
      if (cartItems.isNotEmpty) {
        final kitchenNetworkPrinter = NetworkPrinter(PaperSize.mm80, profile);
        final PosPrintResult kitchenPosPrintResult = await kitchenNetworkPrinter.connect(printer.ipAddress, port: 9100);
        var printInvoiceModel = PrintInvoiceModel(
          invoiceNo: mySharedPreferences.inVocNo - 1,
          orderType: cart.orderType.name,
          items: cartItems,
        );
        if (kitchenPosPrintResult == PosPrintResult.success) {
          try {
            await printKitchen(kitchenNetworkPrinter, printInvoiceModel);
            kitchenNetworkPrinter.disconnect();
            await Future.delayed(const Duration(seconds: 1));
          } catch (e) {
            kitchenNetworkPrinter.disconnect();
            log('printKitchen catch ${e.toString()}');
          }
        } else {
          log('printKitchen catch ${kitchenPosPrintResult.msg}');
        }
      }
    }
  }

  static Future<void> printKitchen(NetworkPrinter printer, PrintInvoiceModel printInvoiceModel) async {
    printer.hr(linesAfter: 1);
    printer.text(
      'Invoice No  : ${printInvoiceModel.invoiceNo}',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    printer.text(
      printInvoiceModel.orderType,
      styles: const PosStyles(
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    printer.hr(linesAfter: 1);
    printer.row([
      PosColumn(text: 'Item Name', width: 6),
      PosColumn(text: 'QTY', width: 2),
      PosColumn(text: 'Note', width: 4),
    ]);
    for (var item in printInvoiceModel.items) {
      printer.row([
        PosColumn(text: 'item.name', width: 6),
        PosColumn(text: '${item.qty}', width: 2),
        PosColumn(text: item.note, width: 4),
      ]);
    }
    printer.hr(linesAfter: 2);
    printer.cut();
  }

  static Future<Uint8List> _buildDocument() async {
    final doc = pdf.Document();
    doc.addPage(
      pdf.Page(
        orientation: pdf.PageOrientation.landscape,
        pageFormat: pdf_format.PdfPageFormat.roll80,
        build: (context) => pdf.Column(
          children: [
            pdf.Text(
              'Hello World',
              style: pdf.TextStyle(
                fontWeight: pdf.FontWeight.bold,
                fontSize: 20,
              ),
            ),
            pdf.Text(
              'Hello World',
              style: pdf.TextStyle(
                fontWeight: pdf.FontWeight.bold,
                fontSize: 20,
              ),
            ),
            pdf.Text(
              'Hello World',
              style: pdf.TextStyle(
                fontWeight: pdf.FontWeight.bold,
                fontSize: 20,
              ),
            ),
            pdf.Text(
              'Hello World',
              style: pdf.TextStyle(
                fontWeight: pdf.FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
    return await doc.save();
  }

  static Future<void> printInvoiceImage(NetworkPrinter printer) async {
    // final img.Image? image = img.decodeImage(imageBytes);
    // printer.image(image!, align: PosAlign.center);
    // printer.cut();
    var ana = await _buildDocument();
    // Printing.layoutPdf(onLayout: _buildDocument());
    await for (var page in Printing.raster(await _buildDocument(), dpi: 203)) {
      final image = page.asImage();
      printer.image(image, align: PosAlign.center);
      printer.feed(2);
      printer.cut();
    }

    // printer.rawBytes(ticket);
  }

  static Future<void> printInvoice(NetworkPrinter printer, CartModel cart) async {
    printer.hr(linesAfter: 1);
    printer.text(
      'Invoice No  : ${mySharedPreferences.inVocNo - 1}',
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    printer.emptyLines(2);
    printer.text(
      cart.orderType.name,
      styles: const PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    printer.text(
      mySharedPreferences.dailyClose.toString(),
      styles: const PosStyles(
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    printer.hr(linesAfter: 1);
    printer.row([
      PosColumn(text: 'Item Name', width: 6),
      PosColumn(text: 'QTY', width: 2),
      PosColumn(text: 'Price', width: 2),
      PosColumn(text: 'Total', width: 2),
    ]);
    final encodedStr = utf8.encode("فاتورة ضريبة");
    printer.textEncoded(Uint8List.fromList([
      ...[0x1C, 0x26, 0x1C, 0x43, 0xFF],
      ...encodedStr
    ]));
    // Uint8List encoded = await CharsetConverter.encode('Windows-1251', "فاتورة ضريبة");
    // printer.textEncoded(encoded, styles: PosStyles(codeTable: 'PC850', bold: true, align: PosAlign.center));
    // printer.text('ا ب ت ث ج ح خ د ذ ر ز س ش ص ض ف ق ك ل م ن ه و ي', styles: const PosStyles(codeTable: 'ISO-8859-6'));
    for (var item in cart.items) {
      printer.row([
        PosColumn(text: 'item.name', width: 6),
        PosColumn(text: '${item.qty}', width: 2),
        PosColumn(text: item.priceChange.toStringAsFixed(2), width: 2),
        PosColumn(text: item.total.toStringAsFixed(2), width: 2),
      ]);
    }
    printer.hr(linesAfter: 2);
    printer.cut();
    // final ByteData data = await rootBundle.load('assets/images/falcons.png');
    // final Uint8List bytes = data.buffer.asUint8List();
    // //  Uint8List bytes = (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl)).buffer.asUint8List();
    // final Image? image = decodeImage(bytes);
    // printer.image(image!);
    // printer.beep();
    // printer.text('ليث',styles: PosStyles(codeTable: 'PC720'));
    // var _bytes = utf8.encode("");

    // log('ana');
    // Uint8List encArabic = await CharsetConverter.encode("windows-1256", "اهلا");
    // log('ana');
    //
    // printer.text("عمل الطباعة العربية", styles: PosStyles(codeTable: 'arabic'));
    // printer.feed(2);
    // printer.cut();
    // Uint8List encoded =
    // await CharsetConverter.encode('windows-1256', "فاتورة ضريبة");
    // printer.textEncoded(encoded,
    //     styles:
    //     PosStyles(codeTable: 'PC864', bold: true, align: PosAlign.center));
    // final encodedStr = utf8.encode("عمل الطباعة العربية");
    //  printer.textEncoded(Uint8List.fromList([
    //   ...[0x1C, 0x26, 0x1C, 0x43, 0xFF],
    //   ...encodedStr
    // ]));
    // Uint8List encSeller = await CharsetConverter.encode('PC864', "عمل الطباعة العربية");
    // printer.textEncoded(encSeller);

    // printer.text('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    // printer.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ', styles: PosStyles(codeTable: 'CP1252'));
    // printer.text('Special 2: blåbærgrød', styles: PosStyles(codeTable: 'CP1252'));
    //
    // printer.text('Bold text', styles: PosStyles(bold: true));
    // printer.text('Reverse text', styles: PosStyles(reverse: true));
    // printer.text('Underlined text', styles: PosStyles(underline: true), linesAfter: 1);
    // printer.text('Align left', styles: PosStyles(align: PosAlign.left));
    // printer.text('Align center', styles: PosStyles(align: PosAlign.center));
    // printer.text('Align right', styles: PosStyles(align: PosAlign.right), linesAfter: 1);
    // printer.qrcode('aananna');
    // printer.qrcode('aananna');
    // printer.text('Text size 200%',
    //     styles: PosStyles(
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ));
    //
    // printer.feed(2);
    // printer.cut();
  }
}
