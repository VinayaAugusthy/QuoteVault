import '../../domain/entities/quote.dart';
import '../../domain/repositories/quote_repository.dart';
import 'package:quote_vault/core/services/daily_quote_service.dart';
import '../datasources/quote_remote_datasource.dart';

class QuoteRepositoryImpl implements QuoteRepository {
  final QuoteRemoteDataSource remoteDataSource;
  final DailyQuoteService dailyQuoteService;

  QuoteRepositoryImpl({
    required this.remoteDataSource,
    required this.dailyQuoteService,
  });

  @override
  Future<List<Quote>> getQuotes({
    String? category,
    String? searchQuery,
    int limit = 30,
    int offset = 0,
  }) {
    return remoteDataSource.fetchQuotes(
      category: category,
      query: searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<Quote>> getQuotesByIds({required List<String> quoteIds}) {
    return remoteDataSource.fetchQuotesByIds(quoteIds);
  }

  @override
  Future<List<String>> getCategories() {
    return remoteDataSource.fetchCategories();
  }

  @override
  Future<Quote?> getDailyQuote() {
    return dailyQuoteService.getDailyQuote();
  }

  @override
  Future<List<String>> getFavoriteQuoteIds({required String userId}) {
    return remoteDataSource.fetchFavoriteQuoteIds(userId);
  }

  @override
  Future<List<Quote>> getFavoriteQuotes({required String userId}) {
    return remoteDataSource.fetchFavoriteQuotes(userId);
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String quoteId,
    required bool shouldAdd,
  }) {
    return remoteDataSource.toggleFavorite(
      userId: userId,
      quoteId: quoteId,
      shouldAdd: shouldAdd,
    );
  }
}
