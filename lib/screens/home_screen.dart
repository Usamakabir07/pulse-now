import 'package:flutter/material.dart';
import 'package:pulse_now_assessment/screens/analytics_screen.dart';
import 'package:pulse_now_assessment/screens/portfolio_screen.dart';
import 'package:pulse_now_assessment/services/analytics_tracker.dart';
import 'market_data_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _screens = <Widget>[
    MarketDataScreen(),
    AnalyticsScreen(),
    PortfolioScreen(),
  ];

  static const _titles = <String>['Market', 'Analytics', 'Portfolio'];

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('PulseNow • ${_titles[_index]}'),
          elevation: 1,
          actions: [
            IconButton(
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: widget.onToggleTheme,
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),
        body: _screens[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            setState(() => _index = i);
            AnalyticsTracker.instance.trackEvent(
              'tab_selected',
              params: {'index': _screens[i]},
            );
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.show_chart),
              label: 'Market',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights),
              label: 'Analytics',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet),
              label: 'Portfolio',
            ),
          ],
        ),
      ),
    );
  }
}
