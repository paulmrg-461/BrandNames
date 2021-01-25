import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;

  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    this._socket =
        IO.io('https://flutter-socket-server.herokuapp.com/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    this._socket.onConnect((_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });
    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    /* socket.on('nuevo-mensaje', (payload) {
      print('New message: $payload');
      print('Name: ' + payload['name']);
      print('Message: ' + payload['message']);
      print(payload.containsKey('message2')
          ? payload['message2']
          : 'There are not new messages.');
    }); */
  }
}
