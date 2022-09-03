/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';
import 'package:esc_pos_utils/esc_pos_utils.dart';

class NetworkKitchen {
  NetworkKitchen(this._paperSize, this._profile, {int spaceBetweenRows = 5}) {
    _generator = Generator(paperSize, profile, spaceBetweenRows: spaceBetweenRows);
  }

  final PaperSize _paperSize;
  final CapabilityProfile _profile;
  String? _host;
  int? _port;
  late Generator _generator;
  late Socket _socket;

  int? get port => _port;

  String? get host => _host;

  PaperSize get paperSize => _paperSize;

  CapabilityProfile get profile => _profile;

  Future<KitchenResult> connect(String host, {int port = 91000, Duration timeout = const Duration(seconds: 5)}) async {
    _host = host;
    _port = port;
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
      _socket.add(_generator.reset());
      return Future<KitchenResult>.value(KitchenResult.success);
    } catch (e) {
      return Future<KitchenResult>.value(KitchenResult.timeout);
    }
  }

  /// [delayMs]: milliseconds to wait after destroying the socket
  void disconnect({int? delayMs}) async {
    _socket.destroy();
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs), () => null);
    }
  }
}

class KitchenResult {
  const KitchenResult._internal(this.value);

  final int value;
  static const success = KitchenResult._internal(1);
  static const timeout = KitchenResult._internal(2);
  static const printerNotSelected = KitchenResult._internal(3);
  static const ticketEmpty = KitchenResult._internal(4);
  static const printInProgress = KitchenResult._internal(5);
  static const scanInProgress = KitchenResult._internal(6);

  String get msg {
    if (value == KitchenResult.success.value) {
      return 'Success';
    } else if (value == KitchenResult.timeout.value) {
      return 'Error. Kitchen connection timeout';
    } else if (value == KitchenResult.printerNotSelected.value) {
      return 'Error. Kitchen not selected';
    } else if (value == KitchenResult.ticketEmpty.value) {
      return 'Error. Ticket is empty';
    } else if (value == KitchenResult.printInProgress.value) {
      return 'Error. Another print in progress';
    } else if (value == KitchenResult.scanInProgress.value) {
      return 'Error. Printer scanning in progress';
    } else {
      return 'Unknown error';
    }
  }
}
