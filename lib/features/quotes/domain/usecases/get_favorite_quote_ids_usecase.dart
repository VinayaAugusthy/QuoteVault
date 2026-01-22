import '../repositories/quote_repository.dart';

class GetFavoriteQuoteIdsUseCase {
  final QuoteRepository repository;

  GetFavoriteQuoteIdsUseCase(this.repository);

  Future<List<String>> call({required String userId}) {
    return repository.getFavoriteQuoteIds(userId: userId);
  }
}
