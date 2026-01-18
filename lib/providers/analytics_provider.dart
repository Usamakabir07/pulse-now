import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import '../services/api_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  AnalyticsOverview? _overview;
  bool _isLoading = false;
  String? _error;

  AnalyticsOverview? get overview => _overview;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final json = await _apiService.getAnalyticsOverview();
      _overview = AnalyticsOverview.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
