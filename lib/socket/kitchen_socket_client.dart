import 'dart:developer' as developer;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class KitchenSocketClient {
  static IO.Socket socket = IO.io(
    'http://192.168.2.65:9002',
    IO.OptionBuilder()
        .setTransports(['polling', 'websocket'])
        .enableForceNewConnection()
        .enableForceNew()
        .disableAutoConnect()
        .enableReconnection()
        .build(),
  );

  static test() {
    _socketLog();

      socket.close();
      socket.connect();

    socket.onConnect((_) {
      _socketLog();
      socket.emit('msg', 'test');
    });
    socket.onConnectError((_) {
      _socketLogConnectError(_.toString());
    });
    socket.on('event', (data) => print(data));
    socket.onDisconnect((_) => print('disconnect'));
    socket.on('fromServer', (_) => print(_));
  }

  static void _socketLog() {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Socket [IO] info ==> \n'
        '╟ URI: ${socket.io.uri}\n'
        '╟ CONNECTED: ${socket.connected}\n'
        // '╟ ACTIVE: ${socket.active}\n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }

  static void _socketLogConnectError(String handler) {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Socket [ConnectError] info ==> \n'
        '╟ URI: ${socket.io.uri}\n'
        '╟ CONNECTED: ${socket.connected}\n'
        // '╟ ACTIVE: ${socket.active}\n'
        '╟ HANDLER: $handler\n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }
}
