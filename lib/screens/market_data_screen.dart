import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pulse_now_assessment/screens/widgets/market_detail_screen.dart';
import '../providers/market_data_provider.dart';
import '../utils/constants.dart';

enum MarketSort { symbolAsc, priceDesc, changeDesc }

class MarketDataScreen extends StatefulWidget {
  const MarketDataScreen({super.key});

  @override
  State<MarketDataScreen> createState() => _MarketDataScreenState();
}

class _MarketDataScreenState extends State<MarketDataScreen> {
  final _currency = NumberFormat.simpleCurrency();
  final _compactCurrency = NumberFormat.compactCurrency(symbol: '\$');
  final _pct = NumberFormat("+#0.##%;-#0.##%");

  String _query = '';
  MarketSort _sort = MarketSort.symbolAsc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketDataProvider>().loadMarketData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MarketDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: provider.loadMarketData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final all = provider.marketData;
        final filtered = _applyQueryAndSort(all);

        return Column(
          children: [
            _topBar(filteredCount: filtered.length, totalCount: all.length),
            Expanded(
              child: filtered.isEmpty
                  ? RefreshIndicator(
                      onRefresh: provider.loadMarketData,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(child: Text('No results')),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: provider.loadMarketData,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          final isPositive = item.change24h >= 0;

                          final changeColor = Color(
                            isPositive
                                ? AppConstants.positiveColor
                                : AppConstants.negativeColor,
                          );

                          final changeText =
                              '${isPositive ? '+' : ''}${item.change24h.toStringAsFixed(2)}';
                          final pctText = _pct.format(
                            item.changePercent24h / 100.0,
                          );

                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: ListTile(
                              key: ValueKey(
                                '${item.symbol}-${item.price}-${item.change24h}',
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MarketDetailScreen(marketData: item),
                                  ),
                                );
                              },
                              title: Text(
                                item.symbol,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_currency.format(item.price)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Vol: ${_compactCurrency.format(item.volume)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    changeText,
                                    style: TextStyle(
                                      color: changeColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    pctText,
                                    style: TextStyle(color: changeColor),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  List _applyQueryAndSort(List items) {
    final q = _query.trim().toLowerCase();

    var out = items.where((e) {
      final symbol = (e.symbol as String).toLowerCase();
      return q.isEmpty || symbol.contains(q);
    }).toList();

    switch (_sort) {
      case MarketSort.symbolAsc:
        out.sort((a, b) => (a.symbol as String).compareTo(b.symbol as String));
        break;
      case MarketSort.priceDesc:
        out.sort((a, b) => (b.price as double).compareTo(a.price as double));
        break;
      case MarketSort.changeDesc:
        out.sort(
          (a, b) => (b.change24h as double).compareTo(a.change24h as double),
        );
        break;
    }

    return out;
  }

  Widget _topBar({required int filteredCount, required int totalCount}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search symbol (e.g., BTC)',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _query = ''),
                    ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              isDense: true,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  filteredCount == totalCount
                      ? '$totalCount symbols'
                      : '$filteredCount / $totalCount symbols',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 1.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<MarketSort>(
                    value: _sort,
                    borderRadius: BorderRadius.circular(30),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _sort = v);
                    },
                    items: const [
                      DropdownMenuItem(
                        value: MarketSort.symbolAsc,
                        child: Text('Sort: Symbol'),
                      ),
                      DropdownMenuItem(
                        value: MarketSort.priceDesc,
                        child: Text('Sort: Price'),
                      ),
                      DropdownMenuItem(
                        value: MarketSort.changeDesc,
                        child: Text('Sort: 24h Change'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
