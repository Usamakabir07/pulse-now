class AnalyticsOverview {
  final double totalMarketCap;
  final double btcDominance;
  final String sentiment;

  const AnalyticsOverview({
    required this.totalMarketCap,
    required this.btcDominance,
    required this.sentiment,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return AnalyticsOverview(
      totalMarketCap: toDouble(json['totalMarketCap']),
      btcDominance: toDouble(json['btcDominance']),
      sentiment: (json['sentiment'] ?? '').toString(),
    );
  }
}
