import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quote_model.dart';

/// Lightweight local cache for daily quote selection (SharedPreferences).
class QuoteLocalDataSource {
  static const String _dailyQuoteDateKey = 'daily_quote_date';
  static const String _dailyQuoteJsonKey = 'daily_quote_json';

  Future<QuoteModel?> getCachedDailyQuote({required String dateKey}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedDate = prefs.getString(_dailyQuoteDateKey);
    if (cachedDate != dateKey) return null;

    final jsonString = prefs.getString(_dailyQuoteJsonKey);
    if (jsonString == null || jsonString.isEmpty) return null;

    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) return null;
    return QuoteModel.fromMap(decoded);
  }

  Future<void> cacheDailyQuote({
    required String dateKey,
    required QuoteModel quote,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyQuoteDateKey, dateKey);
    await prefs.setString(_dailyQuoteJsonKey, jsonEncode(quote.toMap()));
  }

  Future<void> clearDailyQuoteCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyQuoteDateKey);
    await prefs.remove(_dailyQuoteJsonKey);
  }
}
