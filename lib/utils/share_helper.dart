import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

class ShareException implements Exception {
  final String message;
  const ShareException(this.message);

  @override
  String toString() => message;
}

/// Captures whatever widget is wrapped in a RepaintBoundary (identified by
/// [key]) as a PNG image and opens the native share sheet.
class ShareHelper {
  static Future<void> shareWidgetAsImage(
    GlobalKey key, {
    String fileName = 'weather.png',
    String? text,
  }) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw const ShareException('Nothing to share yet.');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw const ShareException('Could not create the image.');
      }

      final Uint8List bytes = byteData.buffer.asUint8List();

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: 'image/png', name: fileName)],
          fileNameOverrides: [fileName],
          text: text,
        ),
      );
    } on ShareException {
      rethrow;
    } catch (e) {
      throw ShareException('Could not share: $e');
    }
  }
}
