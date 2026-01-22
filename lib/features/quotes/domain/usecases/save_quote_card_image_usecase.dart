import 'dart:typed_data';

import '../repositories/quote_share_repository.dart';

class SaveQuoteCardImageUseCase {
  final QuoteShareRepository _repository;

  const SaveQuoteCardImageUseCase(this._repository);

  Future<String?> call({
    required Uint8List pngBytes,
    required String fileName,
  }) {
    return _repository.savePngToGallery(pngBytes: pngBytes, fileName: fileName);
  }
}
