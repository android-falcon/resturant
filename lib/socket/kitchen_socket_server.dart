import 'dart:developer' as developer;
import 'package:socket_io/socket_io.dart';

class KitchenSocketServer {
  static var io = Server();
  static var nsp = io.of('/kitchen');

  static init() {
    _socketLog();
    nsp.on('connection', (client) {
      print('connection /kitchen');
      client.on('msg', (data) {
        print('data from /kitchen => $data');
        client.emit('fromServer', "ok 2");
      });
    });
    io.on('connection', (client) {
      print('connection default namespace');
      client.on('msg', (data) {
        print('data from default => $data');
        client.emit('fromServer', "ok");
      });
    });
    io.listen(9002);
  }

  static void _socketLog() {
    String trace = '════════════════════════════════════════ \n'
        '╔╣ Socket [Server] info ==> \n'
        '╟ NAME: ${io.sockets.name}\n'
        '╚ [END] ════════════════════════════════════════╝';
    developer.log(trace);
  }
}
