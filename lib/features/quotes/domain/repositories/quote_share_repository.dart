import 'dart:typed_data';

abstract class QuoteShareRepository {
  Future<void> shareText({required String text});

  Future<void> sharePngImage({required Uint8List pngBytes, String? text});

  /// Saves the PNG image to the user's photo gallery.
  ///
  /// Returns a platform-specific identifier/URI if available.
  Future<String?> savePngToGallery({
    required Uint8List pngBytes,
    required String fileName,
  });
}
