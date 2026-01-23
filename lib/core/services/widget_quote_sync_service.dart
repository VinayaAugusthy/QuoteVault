import 'package:flutter/services.dart';

class WidgetQuoteSyncService {
  static const MethodChannel _channel = MethodChannel(
    'quote_vault/widget_intents',
  );

  static Future<void> pushQuoteOfDayToWidget({
    required String id,
    required String body,
    required String author,
  }) async {
    try {
      await _channel.invokeMethod('updateQuoteOfDay', {
        'id': id,
        'body': body,
        'author': author,
      });
    } catch (_) {
      // Widget sync is best-effort.
    }
  }
}
