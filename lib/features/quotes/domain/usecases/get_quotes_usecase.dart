import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class GetQuotesUseCase {
  final QuoteRepository repository;

  GetQuotesUseCase(this.repository);

  Future<List<Quote>> call({String? category, String? searchQuery}) {
    return repository.getQuotes(category: category, searchQuery: searchQuery);
  }
}
