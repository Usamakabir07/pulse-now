import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_now_assessment/providers/market_data_provider.dart';
import 'package:pulse_now_assessment/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse_now_assessment/services/websocket_service.dart';

class FakeApiService extends ApiService {
  FakeApiService()
    : super(
        client: MockClient(
          (_) async => http.Response('{"success":true,"data":[]}', 200),
        ),
      );

  @override
  Future<List<Map<String, dynamic>>> getMarketData() async {
    return [
      {
        "symbol": "BTC/USD",
        "price": 100.0,
        "change24h": 2.0,
        "changePercent24h": 2.0,
        "volume": 999.0,
      },
    ];
  }
}

class FakeWebSocketService extends WebSocketService {
  FakeWebSocketService()
    : _controller = StreamController<Map<String, dynamic>>.broadcast(),
      super(url: 'ws://test');

  final StreamController<Map<String, dynamic>> _controller;

  @override
  Stream<Map<String, dynamic>> get stream => _controller.stream;

  @override
  void start() {}

  void emit(Map<String, dynamic> msg) => _controller.add(msg);

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

void main() {
  test(
    'MarketDataProvider.loadMarketData sets loading and populates data',
    () async {
      final ws = FakeWebSocketService();

      final provider = MarketDataProvider(
        apiService: FakeApiService(),
        wsService: ws,
      );

      expect(provider.isLoading, false);
      expect(provider.marketData, isEmpty);

      final future = provider.loadMarketData();
      expect(provider.isLoading, true);

      await future;

      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.marketData.length, 1);
      expect(provider.marketData.first.symbol, 'BTC/USD');

      provider.dispose();
      ws.dispose();
    },
  );
}
