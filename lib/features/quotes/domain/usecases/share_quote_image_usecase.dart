import 'dart:typed_data';

import '../repositories/quote_share_repository.dart';

class ShareQuoteImageUseCase {
  final QuoteShareRepository _repository;

  const ShareQuoteImageUseCase(this._repository);

  Future<void> call({required Uint8List pngBytes, String? text}) {
    return _repository.sharePngImage(pngBytes: pngBytes, text: text);
  }
}
