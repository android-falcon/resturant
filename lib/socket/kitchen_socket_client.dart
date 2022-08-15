import 'dart:convert';
import 'dart:developer' as developer;
import 'package:restaurant_system/utils/enum_order_type.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class KitchenSocketClient {
  late IO.Socket _socket;

  initConnection({String ipAddress = 'localhost'}) {
    _socket = IO.io(
      'http://$ipAddress:3000',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNewConnection().enableForceNew().disableAutoConnect().enableReconnection().build(),
    );
    _socketLog('IO');
    _socket.connect();
    _socket.onConnect((_) => _socketLog('Connect', _.toString()));
    _socket.onConnectError((_) => _socketLog('ConnectError', _.toString()));
    _socket.onDisconnect((_) => _socketLog('Disconnect', _.toString()));
    _socket.on('new_order', (_) => _socketLog('FromServer(new_order)', _.toString())); // from_server
  }

  sendOrder() {
    if (_socket.connected) {
      _socket.emit(
          'new_order',
          jsonEncode({
            'orderNo': 1,
            'tableNo': 2,
            'sectionNo': 3,
            'orderType': 1,
            'items': [
              {
                'itemName': 'Shawrma',
                'qty': 1,
                'note': 'ana',
              },
              {
                'itemName': 'Shawrma',
                'qty': 1,
                'note': 'ana',
              },
            ],
          }));
    } else {
      _socket.dispose();
      initConnection();
    }
  }

  _socketLog(String type, [String message = '']) {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Socket [$type] info ==> \n'
        '╟ URI: ${_socket.io.uri}\n'
        '╟ CONNECTED: ${_socket.connected}\n'
        '╟ MESSAGE: $message\n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }
}
