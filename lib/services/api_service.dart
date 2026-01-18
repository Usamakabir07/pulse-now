import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  static const String baseUrl = AppConstants.baseUrl;

  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Map<String, dynamic>>> getMarketData() async {
    try {
      final uri = Uri.parse('$baseUrl${AppConstants.marketDataEndpoint}');
      final response = await _client.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load market data: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);

      if (decoded is Map && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }

      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }

      throw Exception('Unexpected response format');
    } catch (e) {
      throw Exception('getMarketData error: $e');
    }
  }

  Future<Map<String, dynamic>> getPortfolioSummary() async {
    try {
      final uri = Uri.parse('$baseUrl${AppConstants.portfolioEndpoint}');

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load portfolio: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);

      if (decoded is Map && decoded['data'] is Map) {
        return Map<String, dynamic>.from(decoded['data']);
      }

      throw Exception('Unexpected portfolio response format');
    } catch (e) {
      throw Exception('getPortfolioSummary error: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    try {
      final uri = Uri.parse(
        '$baseUrl${AppConstants.analyticsEndpoint}/overview',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load analytics: ${response.statusCode}');
      }

      final decoded = json.decode(response.body);

      if (decoded is Map && decoded['data'] is Map) {
        return Map<String, dynamic>.from(decoded['data']);
      }

      throw Exception('Unexpected analytics response format');
    } catch (e) {
      throw Exception('getAnalyticsOverview error: $e');
    }
  }
}
