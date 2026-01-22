import '../entities/quote.dart';
import '../repositories/quote_repository.dart';

class GetDailyQuoteUseCase {
  final QuoteRepository repository;

  GetDailyQuoteUseCase(this.repository);

  Future<Quote?> call() {
    return repository.getDailyQuote();
  }
}
