import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:charset_converter/charset_converter.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';

class Printer {
  // String imageUrl = '${mySharedPreferences.baseUrl}${allDataModel.imagePaths.firstWhereOrNull((element) => element.description == 'COMPANY_LOGO')?.imgPath ?? ''}${allDataModel.companyConfig.first.companyLogo}';

  init({required String ipAddress, required CartModel cart}) async {
    final profile = await CapabilityProfile.load(); //name: 'TP806L'
    final printer = NetworkPrinter(PaperSize.mm80, profile);
    final PosPrintResult posPrintResult = await printer.connect(ipAddress, port: 9100); // '10.0.0.113'
    if (posPrintResult == PosPrintResult.success) {
      try {
        await printInvoice(printer);
        printer.disconnect();
      } catch (e) {
        printer.disconnect();
      }
    } else {
      Fluttertoast.showToast(msg: 'Print Failed'.tr);
    }
  }

  Future<void> printKitchen(NetworkPrinter printer) async {
    printer.hr(len: 2, linesAfter: 1);
    printer.hr(len: 2, linesAfter: 2);
    printer.cut();
  }

  Future<void> printInvoice(NetworkPrinter printer) async {
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
