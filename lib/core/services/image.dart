import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/core/widgets/content/image_picker_editor.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

/// Opens the pro_image_editor for cropping and editing an image.
/// Returns the edited image as an XFile, or null if cancelled.
Future<XFile?> cropImage(
  BuildContext context, {
  required XFile image,
  List<ImageAspectRatio>? allowedAspectRatios,
  bool replacePath = true,
}) async {
  if (!context.mounted) return null;

  final imageBytes = await image.readAsBytes();
  if (!context.mounted) return null;

  final editorKey = GlobalKey<ProImageEditorState>();
  XFile? result;

  await Navigator.of(context, rootNavigator: true).push(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (editorContext) => ProImageEditor.memory(
        imageBytes,
        key: editorKey,
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            result = XFile.fromData(
              bytes,
              path: !replacePath ? image.path : null,
              mimeType: image.mimeType ?? 'image/jpeg',
            );
            // Close the editor after editing is complete
            if (editorKey.currentState != null &&
                editorKey.currentState!.mounted) {
              Navigator.of(editorContext).pop();
            }
          },
          onCloseEditor: (_) {
            // Editor is already closing, no need to pop again
          },
        ),
        configs: ProImageEditorConfigs(
          designMode: ImageEditorDesignMode.material,
          theme: Theme.of(context),
          mainEditor: const MainEditorConfigs(enableCloseButton: true),
          cropRotateEditor: allowedAspectRatios != null
              ? CropRotateEditorConfigs(
                  enabled: true,
                  aspectRatios: allowedAspectRatios.map((r) {
                    return AspectRatioItem(text: r.label, value: r.ratio);
                  }).toList(),
                )
              : const CropRotateEditorConfigs(enabled: true),
          paintEditor: const PaintEditorConfigs(enabled: true),
          textEditor: const TextEditorConfigs(enabled: true),
          emojiEditor: const EmojiEditorConfigs(enabled: true),
          filterEditor: const FilterEditorConfigs(enabled: true),
          blurEditor: const BlurEditorConfigs(enabled: true),
          stickerEditor: const StickerEditorConfigs(enabled: true),
          tuneEditor: const TuneEditorConfigs(enabled: true),
        ),
      ),
    ),
  );

  return result;
}

/// Picks an image from gallery and optionally edits it.
/// Returns the picked/edited image as an XFile, or null if cancelled.
Future<XFile?> pickAndEditImage(
  BuildContext context, {
  List<ImageAspectRatio>? allowedAspectRatios,
  bool allowMultiple = false,
  ImageSource source = ImageSource.gallery,
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
  );
}
