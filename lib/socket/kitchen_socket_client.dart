import 'dart:convert';
import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class KitchenSocketClient {
  String host;
  int port = 3000;
  late IO.Socket socket;

  KitchenSocketClient(
    this.host, {
    this.port = 3000,
  });

  Future<void> connect({required String data}) async {
    socket = IO.io(
      'http://$host:$port',
      IO.OptionBuilder().setTransports(['websocket']).enableForceNewConnection().disableAutoConnect().disableReconnection().build(),
    );
    _socketLog('IO');
    socket.connect();
    socket.onConnect((_) async {
      _socketLog('Connect', _.toString());
      socket.emitWithBinary('new_order', utf8.encode(data));
      // socket.emit('new_order', data);

    });
    socket.onConnectError((_) => _socketLog('ConnectError', _.toString()));
    socket.onDisconnect((_) => _socketLog('Disconnect', _.toString()));
    socket.on('new_order', (_) {
      _socketLog('FromServer(new_order)', _.toString());
      socket.disconnect();
      socket.dispose();
    });
  }

  Future<void> disconnect({int? delayMs}) async {
    socket.dispose();
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs), () => null);
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
