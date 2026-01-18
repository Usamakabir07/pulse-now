import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pulse_now_assessment/providers/analytics_provider.dart';
import 'package:pulse_now_assessment/providers/portfolio_provider.dart';
import 'package:pulse_now_assessment/services/analytics_tracker.dart';
import 'screens/home_screen.dart';
import 'providers/market_data_provider.dart';

void main() {
  runApp(const PulseNowApp());
}

class PulseNowApp extends StatefulWidget {
  const PulseNowApp({super.key});

  @override
  State<PulseNowApp> createState() => _PulseNowAppState();
}

class _PulseNowAppState extends State<PulseNowApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketDataProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
      ],
      child: MaterialApp(
        title: 'PulseNow',
        themeMode: _themeMode,
        theme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.blue,
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
        home: HomeScreen(onToggleTheme: _toggleTheme, themeMode: _themeMode),
        debugShowCheckedModeBanner: false,
        navigatorObservers: [AppAnalyticsObserver()],
      ),
    );
  }
}

class AppAnalyticsObserver extends NavigatorObserver {
  AppAnalyticsObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _log(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _log(newRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void _log(Route<dynamic> route) {
    final name = route.settings.name ?? route.runtimeType.toString();
    AnalyticsTracker.instance.trackScreenView(name);
  }
}
