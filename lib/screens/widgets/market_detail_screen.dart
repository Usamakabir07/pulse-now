import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pulse_now_assessment/models/market_data_model.dart';
import 'package:pulse_now_assessment/utils/constants.dart';

class MarketDetailScreen extends StatelessWidget {
  final MarketData marketData;

  const MarketDetailScreen({super.key, required this.marketData});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency();
    final compact = NumberFormat.compactCurrency(symbol: '\$');
    final pct = NumberFormat("+#0.##%;-#0.##%");

    final isPositive = marketData.change24h >= 0;
    final changeColor = Color(
      isPositive ? AppConstants.positiveColor : AppConstants.negativeColor,
    );

    return Scaffold(
      appBar: AppBar(title: Text(marketData.symbol)),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Price'),
                trailing: Text(
                  currency.format(marketData.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('24h Change'),
                trailing: Text(
                  '${isPositive ? '+' : ''}${marketData.change24h.toStringAsFixed(2)} '
                  '(${pct.format(marketData.changePercent24h / 100.0)})',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: changeColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Volume'),
                trailing: Text(
                  compact.format(marketData.volume),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tip: Pull down on the Market list to refresh. WebSocket updates will stream automatically.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
