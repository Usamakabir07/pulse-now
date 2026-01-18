import 'package:flutter/foundation.dart';
import '../models/portfolio_model.dart';
import '../services/api_service.dart';

class PortfolioProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  PortfolioSummary? _summary;
  bool _isLoading = false;
  String? _error;

  PortfolioSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSummary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _apiService.getPortfolioSummary();
      _summary = PortfolioSummary.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
