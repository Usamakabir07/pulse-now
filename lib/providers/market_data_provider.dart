import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pulse_now_assessment/services/websocket_service.dart';

import '../models/market_data_model.dart';
import '../services/api_service.dart';

class MarketDataProvider with ChangeNotifier {
  MarketDataProvider({
    ApiService? apiService,
    required WebSocketService wsService,
  }) : _apiService = apiService ?? ApiService(),
       _wsService = wsService;

  final ApiService _apiService;
  final WebSocketService _wsService;

  List<MarketData> _marketData = [];
  bool _isLoading = false;
  String? _error;

  List<MarketData> get marketData => _marketData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  Future<void> loadMarketData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMarketData();
      _marketData = data.map((json) => MarketData.fromJson(json)).toList();
      _startListeningToWs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startListeningToWs() {
    _wsService.start();

    _wsSub?.cancel();
    _wsSub = _wsService.stream.listen((map) {
      _handleWsMap(map);
    });
  }

  void _handleWsMap(Map<String, dynamic> map) {
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

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }
}
