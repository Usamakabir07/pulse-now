import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/constants.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;

  Stream<Map<String, dynamic>>? get stream => _controller?.stream;

  void connect() {
    _controller = StreamController<Map<String, dynamic>>.broadcast();
    _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));
    _channel!.stream.listen((message) {
      final data = json.decode(message);
      _controller?.add(data);
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _controller?.close();
  }
}
