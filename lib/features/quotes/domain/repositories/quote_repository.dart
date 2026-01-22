import '../entities/quote.dart';

abstract class QuoteRepository {
  Future<List<Quote>> getQuotes({
    String? category,
    String? searchQuery,
    int limit = 30,
    int offset = 0,
  });

  Future<List<Quote>> getQuotesByIds({required List<String> quoteIds});

  Future<List<String>> getCategories();

  Future<Quote?> getDailyQuote();

  Future<List<String>> getFavoriteQuoteIds({required String userId});

  Future<List<Quote>> getFavoriteQuotes({required String userId});

  Future<void> toggleFavorite({
    required String userId,
    required String quoteId,
    required bool shouldAdd,
  });
}
