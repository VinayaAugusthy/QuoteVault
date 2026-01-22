import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class GetFavoriteQuotesUseCase {
  final QuoteRepository repository;

  GetFavoriteQuotesUseCase(this.repository);

  Future<List<Quote>> call({required String userId}) {
    return repository.getFavoriteQuotes(userId: userId);
  }
}
