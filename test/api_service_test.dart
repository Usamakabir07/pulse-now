import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pulse_now_assessment/services/api_service.dart';

void main() {
  test('ApiService.getMarketData parses {data: []} payload', () async {
    final client = MockClient((request) async {
      return http.Response(
        '{"success":true,"data":[{"symbol":"BTC/USD","price":100,"change24h":1,"changePercent24h":1,"volume":10}]}',
        200,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = ApiService(client: client);
    final data = await api.getMarketData();

    expect(data, isA<List<Map<String, dynamic>>>());
    expect(data.length, 1);
    expect(data.first['symbol'], 'BTC/USD');
  });

  test('ApiService.getMarketData throws on non-200', () async {
    final client = MockClient((request) async {
      return http.Response('oops', 500);
    });

    final api = ApiService(client: client);

    expect(() async => api.getMarketData(), throwsA(isA<Exception>()));
  });
}
