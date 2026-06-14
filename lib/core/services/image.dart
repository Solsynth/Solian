import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:path/path.dart' as p;

/// Opens the shared crop editor and returns the edited image, or null if cancelled.
Future<XFile?> cropImage(
  BuildContext context, {
  required XFile image,
  List<ImageAspectRatio>? allowedAspectRatios,
  bool replacePath = true,
  ImageEditorConfig? config,
}) async {
  if (!context.mounted) return null;

  final imageBytes = await image.readAsBytes();
  if (!context.mounted) return null;

  final bytes = await showCropImageEditor(
    context,
    imageBytes: imageBytes,
    allowedAspectRatios: allowedAspectRatios ?? config?.allowedAspectRatios,
  );

  if (bytes == null) return null;

  return XFile.fromData(
    bytes,
    name: _editedImageName(image.name),
    path: replacePath ? null : image.path,
    mimeType: 'image/png',
  );
}

/// Picks an image from gallery and optionally edits it.
/// Returns the picked/edited image as an XFile, or null if cancelled.
Future<XFile?> pickAndEditImage(
  BuildContext context, {
  List<ImageAspectRatio>? allowedAspectRatios,
  bool allowMultiple = false,
  ImageSource source = ImageSource.gallery,
  ImageEditorConfig? config,
}) async {
  final ImagePicker picker = ImagePicker();

  XFile? pickedFile;
  if (source == ImageSource.gallery && allowMultiple) {
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return null;
    pickedFile = files.first;
  } else {
    pickedFile = await picker.pickImage(source: source);
  }

  if (pickedFile == null || !context.mounted) return null;

  return cropImage(
    context,
    image: pickedFile,
    allowedAspectRatios: allowedAspectRatios,
    config: config,
  );
}

String _editedImageName(String originalName) {
  final extension = p.extension(originalName);
  if (extension.isEmpty) return '${originalName}_cropped.png';
  return originalName.replaceRange(
    originalName.length - extension.length,
    originalName.length,
    '.png',
  );
}
