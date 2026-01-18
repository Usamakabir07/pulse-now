import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_now_assessment/providers/market_data_provider.dart';
import 'package:pulse_now_assessment/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

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

void main() {
  test(
    'MarketDataProvider.loadMarketData sets loading and populates data',
    () async {
      final provider = MarketDataProvider(apiService: FakeApiService());

      expect(provider.isLoading, false);
      expect(provider.marketData, isEmpty);

      final future = provider.loadMarketData();
      expect(provider.isLoading, true);

      await future;

      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(provider.marketData.length, 1);
      expect(provider.marketData.first.symbol, 'BTC/USD');
    },
  );
}
