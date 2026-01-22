import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/repositories/quote_share_repository.dart';

class QuoteShareRepositoryImpl implements QuoteShareRepository {
  static const MethodChannel _galleryChannel = MethodChannel(
    'quote_vault/gallery_saver',
  );

  @override
  Future<void> shareText({required String text}) async {
    await Share.share(text, subject: AppStrings.shareSubject);
  }

  @override
  Future<void> sharePngImage({
    required Uint8List pngBytes,
    String? text,
  }) async {
    final fileName = 'quote_${DateTime.now().millisecondsSinceEpoch}.png';
    try {
      final xFile = XFile.fromData(
        pngBytes,
        name: fileName,
        mimeType: 'image/png',
      );
      await Share.shareXFiles([xFile], text: text);
      return;
    } catch (_) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(pngBytes, flush: true);
      await Share.shareXFiles([XFile(file.path)], text: text);
    }
  }

  @override
  Future<String?> savePngToGallery({
    required Uint8List pngBytes,
    required String fileName,
  }) async {
    await _ensureGalleryPermission();

    final result = await _galleryChannel.invokeMethod<String>(
      'saveImage',
      <String, dynamic>{'bytes': pngBytes, 'fileName': fileName},
    );
    return result;
  }

  Future<void> _ensureGalleryPermission() async {
    if (Platform.isIOS) {
      final addOnly = await Permission.photosAddOnly.request();
      if (addOnly.isGranted || addOnly.isLimited) return;

      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return;

      throw PlatformException(
        code: 'permission_denied',
        message: AppStrings.permissionDeniedMessage,
      );
    }

    if (Platform.isAndroid) {
      final storage = await Permission.storage.request();
      if (storage.isGranted || storage.isLimited) return;

      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) return;

      throw PlatformException(
        code: 'permission_denied',
        message: AppStrings.permissionDeniedMessage,
      );
    }
  }
}
