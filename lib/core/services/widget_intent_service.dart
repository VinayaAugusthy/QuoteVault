import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../constants/route_constants.dart';

class WidgetIntentService {
  static const MethodChannel _channel = MethodChannel(
    'quote_vault/widget_intents',
  );

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialized = false;

  void initialize(GlobalKey<NavigatorState> navigatorKey) {
    if (_initialized) return;
    _initialized = true;
    _navigatorKey = navigatorKey;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'openQuoteOfDay') {
        _navigateHome();
      }
    });
  }

  Future<void> handleInitialLaunchIntent() async {
    try {
      final shouldOpen =
          await _channel.invokeMethod<bool>('getInitialOpenQuoteOfDay') ??
          false;
      if (shouldOpen) {
        _navigateHome();
      }
    } catch (_) {
      // Intentionally ignore: widget intents are optional.
    }
  }

  void _navigateHome() {
    final nav = _navigatorKey?.currentState;
    if (nav == null) return;
    nav.pushNamedAndRemoveUntil(RouteConstants.quotesList, (route) => false);
  }
}
