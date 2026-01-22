import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class QuoteCardImageGenerator {
  const QuoteCardImageGenerator._();

  static RenderRepaintBoundary? _boundaryFromKey(GlobalKey key) {
    final ctx = key.currentContext;
    final renderObject = ctx?.findRenderObject();
    if (renderObject is RenderRepaintBoundary) return renderObject;
    return null;
  }

  static Future<Uint8List> capturePngBytes(
    GlobalKey repaintBoundaryKey, {
    double pixelRatio = 3,
  }) async {
    // Ensure at least one frame has been painted before capturing.
    await WidgetsBinding.instance.endOfFrame;

    var boundary = _boundaryFromKey(repaintBoundaryKey);
    if (boundary == null) {
      // Retry once after another frame (helps right after opening the sheet).
      await WidgetsBinding.instance.endOfFrame;
      boundary = _boundaryFromKey(repaintBoundaryKey);
      if (boundary == null) {
        throw StateError('Preview is not ready to capture yet.');
      }
    }

    final uiImage = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode PNG.');
    }

    return byteData.buffer.asUint8List();
  }
}
