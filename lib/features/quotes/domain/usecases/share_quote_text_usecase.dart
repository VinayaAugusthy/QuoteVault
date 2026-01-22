import '../entities/quote.dart';
import '../repositories/quote_share_repository.dart';

class ShareQuoteTextUseCase {
  final QuoteShareRepository _repository;

  const ShareQuoteTextUseCase(this._repository);

  Future<void> call(Quote quote) {
    final text = '"${quote.body}"\n\n— ${quote.author}';
    return _repository.shareText(text: text);
  }
}
