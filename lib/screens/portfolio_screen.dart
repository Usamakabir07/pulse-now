import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../utils/constants.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final _currency = NumberFormat.simpleCurrency();
  Timer? _timer;

  static const Duration _refreshEvery = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PortfolioProvider>();
      provider.loadSummary();

      _timer = Timer.periodic(_refreshEvery, (_) {
        if (!mounted) return;
        if (!provider.isLoading) {
          provider.loadSummary();
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
    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.summary == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null && provider.summary == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: provider.loadSummary,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final data = provider.summary;
        if (data == null) {
          return const Center(child: Text('No portfolio data available'));
        }

        final isPositive = data.dailyChange >= 0;
        final color = Color(
          isPositive ? AppConstants.positiveColor : AppConstants.negativeColor,
        );

        return RefreshIndicator(
          onRefresh: provider.loadSummary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(10),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Total Portfolio Value'),
                  trailing: Text(
                    _currency.format(data.totalValue),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text('Daily Change'),
                  trailing: Text(
                    '${isPositive ? '+' : ''}${_currency.format(data.dailyChange)} '
                    '(${data.dailyChangePercent.toStringAsFixed(2)}%)',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
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
}
