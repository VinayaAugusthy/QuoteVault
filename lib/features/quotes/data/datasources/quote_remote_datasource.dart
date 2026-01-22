import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<List<QuoteModel>> fetchQuotes({
    String? category,
    String? query,
    int limit = 30,
    int offset = 0,
  });

  Future<List<String>> fetchCategories();

  Future<QuoteModel?> fetchDailyQuote();

  Future<List<QuoteModel>> fetchQuotesByIds(List<String> quoteIds);

  Future<List<String>> fetchFavoriteQuoteIds(String userId);

  Future<List<QuoteModel>> fetchFavoriteQuotes(
    String userId, {
    List<String>? quoteIds,
  });

  Future<void> toggleFavorite({
    required String userId,
    required String quoteId,
    required bool shouldAdd,
  });
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  static const _columns = 'id, body, author, category, tags, created_at';
  static final _dailyQuoteSeed = DateTime.utc(2024, 1, 1);
  static const _favoritesTable = 'user_favorites';

  final SupabaseClient supabaseClient;

  QuoteRemoteDataSourceImpl({required this.supabaseClient});

  String _sanitizeQuery(String query) => query.replaceAll("'", "''");

  @override
  Future<List<QuoteModel>> fetchQuotes({
    String? category,
    String? query,
    int limit = 30,
    int offset = 0,
  }) async {
    dynamic builder = supabaseClient.from('quotes').select(_columns);

    final normalizedCategory = category?.trim();
    if (normalizedCategory != null &&
        normalizedCategory.isNotEmpty &&
        normalizedCategory != 'All') {
      builder = builder.eq('category', normalizedCategory);
    }

    final normalizedQuery = query?.trim();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      final sanitized = _sanitizeQuery(normalizedQuery);
      builder = builder.or('body.ilike.%$sanitized%,author.ilike.%$sanitized%');
    }

    builder = builder
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final result = await builder;
    final data = (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );

    return data.map(QuoteModel.fromMap).toList();
  }

  @override
  Future<List<String>> fetchCategories() async {
    final result = await supabaseClient
        .from('quotes')
        .select('category')
        .order('category', ascending: true);
    final data =
        (result as List<dynamic>?)?.cast<Map<String, dynamic>>().toList(
          growable: false,
        ) ??
        const <Map<String, dynamic>>[];
    final categories = <String>{};
    for (final row in data) {
      final category = row['category'] as String?;
      if (category != null && category.isNotEmpty) {
        categories.add(category.trim());
      }
    }

    if (categories.isEmpty) {
      categories.add('General');
    }

    return categories.toList();
  }

  @override
  Future<QuoteModel?> fetchDailyQuote() async {
    final result = await supabaseClient
        .from('quotes')
        .select(_columns)
        .order('created_at', ascending: true);
    final data = (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );

    if (data.isEmpty) return null;

    final dayOffset = DateTime.now().toUtc().difference(_dailyQuoteSeed).inDays;
    final index = dayOffset % data.length;
    return QuoteModel.fromMap(data[index]);
  }

  @override
  Future<List<QuoteModel>> fetchQuotesByIds(List<String> quoteIds) async {
    final normalized = quoteIds
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final unique = normalized.toSet().toList(growable: false);
    if (unique.isEmpty) return const <QuoteModel>[];

    final result = await supabaseClient
        .from('quotes')
        .select(_columns)
        .inFilter('id', unique);

    final data = (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );

    final byId = <String, QuoteModel>{};
    for (final row in data) {
      final model = QuoteModel.fromMap(row);
      byId[model.id] = model;
    }

    // Preserve caller order where possible.
    final ordered = <QuoteModel>[];
    for (final id in quoteIds) {
      final match = byId[id];
      if (match != null) ordered.add(match);
    }

    // Add any remaining quotes not found in the caller ordering.
    for (final entry in byId.entries) {
      if (!ordered.any((q) => q.id == entry.key)) {
        ordered.add(entry.value);
      }
    }

    return ordered;
  }

  @override
  Future<List<String>> fetchFavoriteQuoteIds(String userId) async {
    final result = await supabaseClient
        .from(_favoritesTable)
        .select('quote_id')
        .eq('user_id', userId);
    final data = (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );
    return data
        .map((entry) => entry['quote_id'] as String?)
        .whereType<String>()
        .toList();
  }

  @override
  Future<List<QuoteModel>> fetchFavoriteQuotes(
    String userId, {
    List<String>? quoteIds,
  }) async {
    final result = await supabaseClient
        .from(_favoritesTable)
        .select('quotes (id, body, author, category, tags, created_at)')
        .eq('user_id', userId);
    final data = (result as List<dynamic>).cast<Map<String, dynamic>>().toList(
      growable: false,
    );
    final quotes = <QuoteModel>[];

    for (final row in data) {
      final quoteMap = row['quotes'] as Map<String, dynamic>?;
      if (quoteMap != null) {
        quotes.add(QuoteModel.fromMap(quoteMap));
      }
    }

    return quotes;
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String quoteId,
    required bool shouldAdd,
  }) async {
    final table = supabaseClient.from(_favoritesTable);

    if (shouldAdd) {
      await table.upsert([
        {'user_id': userId, 'quote_id': quoteId},
      ], onConflict: 'user_id,quote_id');
      return;
    }

    await table.delete().eq('user_id', userId).eq('quote_id', quoteId);
  }
}
