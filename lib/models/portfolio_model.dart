class PortfolioSummary {
  final double totalValue;
  final double dailyChange;
  final double dailyChangePercent;

  const PortfolioSummary({
    required this.totalValue,
    required this.dailyChange,
    required this.dailyChangePercent,
  });

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return PortfolioSummary(
      totalValue: toDouble(json['totalValue']),
      dailyChange: toDouble(json['dailyChange']),
      dailyChangePercent: toDouble(json['dailyChangePercent']),
    );
  }
}
