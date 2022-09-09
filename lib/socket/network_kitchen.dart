/*
 * esc_pos_printer
 * Created by Andrey Ushakov
 * 
 * Copyright (c) 2019-2020. All rights reserved.
 * See LICENSE for distribution and usage details.
 */

import 'dart:io';

class NetworkKitchen {
  String? _host;
  int? _port;
  late Socket _socket;

  int? get port => _port;

  String? get host => _host;

  Future<KitchenResult> connect(String host, {int port = 3000, Duration timeout = const Duration(seconds: 5)}) async {
    _host = host;
    _port = port;
    try {
      _socket = await Socket.connect(host, port, timeout: timeout);
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

  void sendData(List<int> data) {
    _socket.add(data);
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
