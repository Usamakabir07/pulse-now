import 'dart:developer' as dev;

class AnalyticsTracker {
  AnalyticsTracker._();
  static final AnalyticsTracker instance = AnalyticsTracker._();

  void trackScreenView(String screenName) {
    dev.log('screen_view: $screenName', name: 'analytics');
  }

  void trackEvent(String name, {Map<String, Object?>? params}) {
    dev.log('event: $name params=${params ?? {}}', name: 'analytics');
  }

  void trackError(String where, Object error) {
    dev.log('error: $where -> $error', name: 'analytics');
  }
}
