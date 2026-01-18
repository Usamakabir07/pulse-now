class MarketData {
  final String symbol;
  final double price;
  final double change24h;
  final double changePercent24h;
  final double volume;

  const MarketData({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    required this.volume,
  });

  factory MarketData.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    return MarketData(
      symbol: (json['symbol'] ?? '').toString(),
      price: toDouble(json['price']),
      change24h: toDouble(json['change24h']),
      changePercent24h: toDouble(json['changePercent24h']),
      volume: toDouble(json['volume']),
    );
  }

  MarketData copyWith({
    String? symbol,
    double? price,
    double? change24h,
    double? changePercent24h,
    double? volume,
  }) {
    return MarketData(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      changePercent24h: changePercent24h ?? this.changePercent24h,
      volume: volume ?? this.volume,
    );
  }
}
