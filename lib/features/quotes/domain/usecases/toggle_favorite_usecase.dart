import '../repositories/quote_repository.dart';

class ToggleFavoriteUseCase {
  final QuoteRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String quoteId,
    required bool shouldAdd,
  }) {
    return repository.toggleFavorite(
      userId: userId,
      quoteId: quoteId,
      shouldAdd: shouldAdd,
    );
  }
}
