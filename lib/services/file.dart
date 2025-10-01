import 'dart:async';
import 'dart:ui';
import 'package:croppy/croppy.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/widgets.dart';

Future<XFile?> cropImage(
  BuildContext context, {
  required XFile image,
  List<CropAspectRatio?>? allowedAspectRatios,
  bool replacePath = true,
}) async {
  if (!context.mounted) return null;
  final imageBytes = await image.readAsBytes();
  if (!context.mounted) return null;
  final result = await showMaterialImageCropper(
    context,
    imageProvider: MemoryImage(imageBytes),
    showLoadingIndicatorOnSubmit: true,
    allowedAspectRatios: allowedAspectRatios,
  );
  if (result == null) return null; // Cancelled operation
  final croppedFile = result.uiImage;
  final croppedBytes = await croppedFile.toByteData(
    format: ImageByteFormat.png,
  );
  if (croppedBytes == null) {
    return image;
  }
  croppedFile.dispose();
  return XFile.fromData(
    croppedBytes.buffer.asUint8List(),
    path: !replacePath ? image.path : null,
    mimeType: image.mimeType,
  );
}
