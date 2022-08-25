import 'dart:convert';
import 'dart:developer' as developer;
import 'package:restaurant_system/models/cart_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class KitchenSocketClient {
  String host;
  int port = 3000;
  late IO.Socket socket;

  KitchenSocketClient(
    this.host, {
    this.port = 3000,
  });

  Future<void> connect() async {
    socket = IO.io(
      'http://$host:$port',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNewConnection().enableForceNew().disableAutoConnect().enableReconnection().build(),
    );
    _socketLog('IO');
    socket.connect();
    socket.onConnect((_) => _socketLog('Connect', _.toString()));
    socket.onConnectError((_) => _socketLog('ConnectError', _.toString()));
    socket.onDisconnect((_) => _socketLog('Disconnect', _.toString()));
    socket.on('new_order', (_) => _socketLog('FromServer(new_order)', _.toString()));
  }

  Future<void> disconnect() async {
    socket.dispose();
  }

  sendOrder({required int orderNo, required CartModel cart}) {
    if (socket.connected) {
      socket.emit(
          'new_order',
          jsonEncode({
            'orderNo': orderNo,
            'tableNo': cart.tableNo,
            'sectionNo': 0,
            'orderType': cart.orderType.index,
            'items': cart.items
                .map((e) => {
                      'itemName': e.name,
                      'qty': e.qty,
                      'note': e.note,
                    })
                .toList(),
          }));
    } else {
      socket.dispose();
      connect();
    }
  }

  _socketLog(String type, [String message = '']) {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Socket [$type] info ==> \n'
        '╟ URI: ${socket.io.uri}\n'
        '╟ CONNECTED: ${socket.connected}\n'
        '╟ MESSAGE: $message\n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }
}
