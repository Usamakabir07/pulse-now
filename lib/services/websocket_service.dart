import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef JsonMap = Map<String, dynamic>;

class WebSocketService {
  WebSocketService({
    required this.url,
    this.reconnectInitialDelay = const Duration(seconds: 1),
    this.reconnectMaxDelay = const Duration(seconds: 30),
  });

  final String url;
  final Duration reconnectInitialDelay;
  final Duration reconnectMaxDelay;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _controller = StreamController<JsonMap>.broadcast();
  Stream<JsonMap> get stream => _controller.stream;

  bool _disposed = false;
  bool _connecting = false;

  Duration _currentDelay = Duration.zero;
  Timer? _reconnectTimer;

  bool get isConnected => _channel != null;
  bool get isConnecting => _connecting;

  void start() {
    _connect();
  }

  void _connect() {
    if (_disposed) return;
    if (_channel != null || _connecting) return;

    _connecting = true;
    _reconnectTimer?.cancel();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _sub = _channel!.stream.listen(
        (message) {
          final decoded = _decodeMessage(message);
          if (decoded != null) _controller.add(decoded);
        },
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );

      // reset backoff when a connection is established
      _currentDelay = reconnectInitialDelay;
    } catch (_) {
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  JsonMap? _decodeMessage(dynamic message) {
    try {
      final decoded = message is String ? json.decode(message) : message;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  void _scheduleReconnect() {
    if (_disposed) return;

    _cleanupChannel();

    // exponential backoff
    if (_currentDelay == Duration.zero) {
      _currentDelay = reconnectInitialDelay;
    } else {
      final next = _currentDelay.inMilliseconds * 2;
      _currentDelay = Duration(
        milliseconds: next > reconnectMaxDelay.inMilliseconds
            ? reconnectMaxDelay.inMilliseconds
            : next,
      );
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_currentDelay, _connect);
  }

  void stop() {
    _reconnectTimer?.cancel();
    _cleanupChannel();
  }

  void _cleanupChannel() {
    _sub?.cancel();
    _sub = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;
  }

  void dispose() {
    _disposed = true;
    stop();
    _controller.close();
  }
}
