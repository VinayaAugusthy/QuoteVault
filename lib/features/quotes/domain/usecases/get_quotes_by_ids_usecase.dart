import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class GetQuotesByIdsUseCase {
  final QuoteRepository repository;

  GetQuotesByIdsUseCase(this.repository);

  Future<List<Quote>> call({required List<String> quoteIds}) {
    return repository.getQuotesByIds(quoteIds: quoteIds);
  }
}
