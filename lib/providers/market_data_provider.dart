import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/market_data_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class MarketDataProvider with ChangeNotifier {
  final ApiService _apiService;

  MarketDataProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  List<MarketData> _marketData = [];
  bool _isLoading = false;
  String? _error;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSub;
  Timer? _reconnectTimer;
  bool _wsConnecting = false;

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();

      _ensureWebSocketConnected();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _ensureWebSocketConnected() {
    if (_channel != null || _wsConnecting) return;

    _wsConnecting = true;
    _reconnectTimer?.cancel();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(AppConstants.wsUrl));

      _wsSub = _channel!.stream.listen(
        (message) => _handleWsMessage(message),
        onError: (err) => _scheduleReconnect('WebSocket error: $err'),
        onDone: () => _scheduleReconnect('WebSocket closed'),
        cancelOnError: true,
      );
    } catch (e) {
      _scheduleReconnect('WebSocket connect failed: $e');
    } finally {
      _wsConnecting = false;
    }
  }

  void _scheduleReconnect(String reason) {
    _disposeWebSocket();
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(
      const Duration(seconds: 2),
      _ensureWebSocketConnected,
    );
  }

  void _handleWsMessage(dynamic message) {
    dynamic decoded;
    try {
      decoded = message is String ? json.decode(message) : message;
    } catch (_) {
      return;
    }

    if (decoded is! Map) return;
    final map = Map<String, dynamic>.from(decoded);

    if (map['type'] != 'market_update') return;

    final data = map['data'];
    if (data is! Map) return;

    final itemJson = Map<String, dynamic>.from(data);
    if (itemJson['changePercent24h'] == null) {
      final price = _toDouble(itemJson['price']);
      final change = _toDouble(itemJson['change24h']);
      final baseline = price - change;

      final pct = (baseline.abs() < 1e-9) ? 0.0 : (change / baseline) * 100.0;
      itemJson['changePercent24h'] = pct;
    }

    _upsertMarketItem(MarketData.fromJson(itemJson));
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  void _upsertMarketItem(MarketData incoming) {
    final idx = _marketData.indexWhere((e) => e.symbol == incoming.symbol);
    if (idx == -1) {
      _marketData = [incoming, ..._marketData];
    } else {
      final copy = List<MarketData>.from(_marketData);
      copy[idx] = incoming;
      _marketData = copy;
    }
    notifyListeners();
  }

  void _disposeWebSocket() {
    _wsSub?.cancel();
    _wsSub = null;

    try {
      _channel?.sink.close();
    } catch (_) {}

    _channel = null;
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _disposeWebSocket();
    super.dispose();
  }
}
