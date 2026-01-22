import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class GetQuotesUseCase {
  final QuoteRepository repository;

  GetQuotesUseCase(this.repository);

  Future<List<Quote>> call({
    String? category,
    String? searchQuery,
    int limit = 30,
    int offset = 0,
  }) {
    return repository.getQuotes(
      category: category,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }
}
