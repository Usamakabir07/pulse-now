import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _currency = NumberFormat.compactCurrency(symbol: '\$');
  Timer? _timer;

  static const Duration _refreshEvery = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalyticsProvider>();
      provider.loadOverview();

      _timer = Timer.periodic(_refreshEvery, (_) {
        if (!mounted) return;
        if (!provider.isLoading) {
          provider.loadOverview();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalyticsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.overview == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.overview == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: provider.loadOverview,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = provider.overview;
        if (data == null) {
          return const Center(child: Text('No analytics available'));
        }

        return RefreshIndicator(
          onRefresh: provider.loadOverview,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            children: [
              _tile('Total Market Cap', _currency.format(data.totalMarketCap)),
              _tile(
                'BTC Dominance',
                '${data.btcDominance.toStringAsFixed(2)}%',
              ),
              _tile('Market Sentiment', data.sentiment),
              const SizedBox(height: 12),
              Text(
                'Auto-refresh: every ${_refreshEvery.inSeconds}s',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (provider.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Last refresh error: ${provider.error}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _tile(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
