import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Configuration for image editing features
class ImageEditorConfig {
  /// Allowed aspect ratios for cropping. If null, freeform cropping is allowed.
  final List<ImageAspectRatio>? allowedAspectRatios;

  /// Maximum number of images that can be selected. Null for unlimited.
  final int? maxImages;

  /// Whether to allow multiple image selection
  final bool allowMultiple;

  /// Whether to show compression options
  final bool allowCompression;

  /// Default compression quality (0-100)
  final int defaultCompressionQuality;

  /// Whether to enable painting/drawing feature
  final bool enablePaint;

  /// Whether to enable text overlay feature
  final bool enableText;

  /// Whether to enable emoji feature
  final bool enableEmoji;

  /// Whether to enable filter feature
  final bool enableFilters;

  /// Whether to enable blur feature
  final bool enableBlur;

  /// Whether to enable adjust feature (brightness, contrast, saturation)
  final bool enableAdjustments;

  const ImageEditorConfig({
    this.allowedAspectRatios,
    this.maxImages,
    this.allowMultiple = true,
    this.allowCompression = true,
    this.defaultCompressionQuality = 85,
    this.enablePaint = true,
    this.enableText = true,
    this.enableEmoji = true,
    this.enableFilters = true,
    this.enableBlur = true,
    this.enableAdjustments = true,
  });

  /// Preset for avatar/profile picture (1:1 aspect ratio, single image)
  static const avatar = ImageEditorConfig(
    allowedAspectRatios: [ImageAspectRatio.square],
    allowMultiple: false,
    allowCompression: true,
    defaultCompressionQuality: 90,
  );

  /// Preset for banner/background (16:9 aspect ratio, single image)
  static const banner = ImageEditorConfig(
    allowedAspectRatios: [ImageAspectRatio(width: 16, height: 9)],
    allowMultiple: false,
    allowCompression: true,
    defaultCompressionQuality: 85,
  );

  /// Preset for post attachments (freeform, multiple images)
  static const postAttachments = ImageEditorConfig(
    allowedAspectRatios: null,
    allowMultiple: true,
    allowCompression: true,
    defaultCompressionQuality: 85,
  );

  /// Preset for story (9:16 aspect ratio, single image)
  static const story = ImageEditorConfig(
    allowedAspectRatios: [ImageAspectRatio(width: 9, height: 16)],
    allowMultiple: false,
    allowCompression: true,
    defaultCompressionQuality: 90,
  );

  /// Preset with all features enabled
  static const allFeatures = ImageEditorConfig(
    allowedAspectRatios: null,
    allowMultiple: true,
    allowCompression: true,
    defaultCompressionQuality: 85,
    enablePaint: true,
    enableText: true,
    enableEmoji: true,
    enableFilters: true,
    enableBlur: true,
    enableAdjustments: true,
  );

  /// Copy with modifications
  ImageEditorConfig copyWith({
    List<ImageAspectRatio>? allowedAspectRatios,
    int? maxImages,
    bool? allowMultiple,
    bool? allowCompression,
    int? defaultCompressionQuality,
    bool? enablePaint,
    bool? enableText,
    bool? enableEmoji,
    bool? enableFilters,
    bool? enableBlur,
    bool? enableStickers,
    bool? enableAdjustments,
  }) {
    return ImageEditorConfig(
      allowedAspectRatios: allowedAspectRatios ?? this.allowedAspectRatios,
      maxImages: maxImages ?? this.maxImages,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      allowCompression: allowCompression ?? this.allowCompression,
      defaultCompressionQuality: defaultCompressionQuality ?? this.defaultCompressionQuality,
      enablePaint: enablePaint ?? this.enablePaint,
      enableText: enableText ?? this.enableText,
      enableEmoji: enableEmoji ?? this.enableEmoji,
      enableFilters: enableFilters ?? this.enableFilters,
      enableBlur: enableBlur ?? this.enableBlur,
      enableAdjustments: enableAdjustments ?? this.enableAdjustments,
    );
  }
}

/// Represents an aspect ratio for image cropping
class ImageAspectRatio {
  final int width;
  final int height;

  const ImageAspectRatio({required this.width, required this.height});

  static const square = ImageAspectRatio(width: 1, height: 1);
  static const portrait = ImageAspectRatio(width: 3, height: 4);
  static const landscape = ImageAspectRatio(width: 4, height: 3);
  static const widescreen = ImageAspectRatio(width: 16, height: 9);
  static const ultrawide = ImageAspectRatio(width: 21, height: 9);

  double get ratio => width / height;

  String get label => '$width:$height';
}

/// A model representing a selected image with its metadata
class EditableImage {
  final XFile file;
  final String id;
  Uint8List? editedBytes;
  String? displayName;
  bool isEdited;
  int compressionQuality;

  EditableImage({
    required this.file,
    required this.id,
    this.editedBytes,
    this.displayName,
    this.isEdited = false,
    this.compressionQuality = 85,
  });

  EditableImage copyWith({
    XFile? file,
    String? id,
    Uint8List? editedBytes,
    String? displayName,
    bool? isEdited,
    int? compressionQuality,
  }) {
    return EditableImage(
      file: file ?? this.file,
      id: id ?? this.id,
      editedBytes: editedBytes ?? this.editedBytes,
      displayName: displayName ?? this.displayName,
      isEdited: isEdited ?? this.isEdited,
      compressionQuality: compressionQuality ?? this.compressionQuality,
    );
  }

  /// Get the effective bytes (edited or original)
  Future<Uint8List> getBytes() async {
    if (editedBytes != null) {
      return editedBytes!;
    }
    return await file.readAsBytes();
  }

  /// Get the file size in bytes
  Future<int> getSize() async {
    final bytes = await getBytes();
    return bytes.length;
  }
}

/// Creates i18n configuration for pro_image_editor
I18n createImageEditorI18n(BuildContext context) {
  return I18n(
    cancel: 'cancel'.tr(),
    undo: 'imageEditorUndo'.tr(),
    redo: 'imageEditorRedo'.tr(),
    done: 'done'.tr(),
    doneLoadingMsg: 'imageEditorLoading'.tr(),
    cropRotateEditor: I18nCropRotateEditor(
      bottomNavigationBarText: 'imageEditorCrop'.tr(),
      rotate: 'imageEditorRotate'.tr(),
      ratio: 'imageEditorFree'.tr(),
      back: 'back'.tr(),
    ),
    paintEditor: I18nPaintEditor(
      bottomNavigationBarText: 'imageEditorPaint'.tr(),
      freestyle: 'imageEditorBrush'.tr(),
      line: 'imageEditorLine'.tr(),
      lineWidth: 'imageEditorLineWidth'.tr(),
      back: 'back'.tr(),
    ),
    textEditor: I18nTextEditor(
      bottomNavigationBarText: 'imageEditorText'.tr(),
      inputHintText: 'imageEditorAddText'.tr(),
      backgroundMode: 'imageEditorBackground'.tr(),
      back: 'back'.tr(),
    ),
    emojiEditor: I18nEmojiEditor(bottomNavigationBarText: 'imageEditorEmoji'.tr()),
    filterEditor: I18nFilterEditor(bottomNavigationBarText: 'imageEditorFilters'.tr(), back: 'back'.tr()),
    blurEditor: I18nBlurEditor(bottomNavigationBarText: 'imageEditorBlur'.tr(), back: 'back'.tr()),
    tuneEditor: I18nTuneEditor(bottomNavigationBarText: 'imageEditorAdjust'.tr(), back: 'back'.tr()),
    various: I18nVarious(
      closeEditorWarningTitle: 'close'.tr(),
      closeEditorWarningMessage: 'Are you sure you want to close the editor? Your changes will not be saved.',
      closeEditorWarningConfirmBtn: 'yes'.tr(),
      closeEditorWarningCancelBtn: 'no'.tr(),
    ),
  );
}

/// Creates editor configs with Material design and black background
ProImageEditorConfigs createImageEditorConfigs(
  BuildContext context, {
  ImageEditorConfig? config,
  List<ImageAspectRatio>? allowedAspectRatios,
}) {
  final effectiveConfig = config ?? const ImageEditorConfig();
  final colorScheme = Theme.of(context).colorScheme;

  // Create base theme with black background
  final baseTheme = Theme.of(context).copyWith(
    scaffoldBackgroundColor: Colors.black,
    colorScheme: colorScheme.copyWith(surface: Colors.black, surfaceContainerHighest: Colors.grey[900]!),
  );

  return ProImageEditorConfigs(
    designMode: ImageEditorDesignMode.material,
    theme: baseTheme,
    i18n: createImageEditorI18n(context),
    mainEditor: MainEditorConfigs(
      enableCloseButton: true,
      widgets: MainEditorWidgets(
        appBar: (state, stream) => ReactiveAppbar(
          builder: (context) {
            return AppBar(
              actions: [
                IconButton(onPressed: state.canUndo ? state.undoAction : null, icon: const Icon(Symbols.undo)),
                IconButton(onPressed: state.canRedo ? state.redoAction : null, icon: const Icon(Symbols.redo)),
                IconButton(onPressed: state.doneEditing, icon: const Icon(Symbols.check)),
                const Gap(8),
              ],
            );
          },
          stream: stream,
        ),
        bottomBar: (state, stream, key) => ReactiveWidget(
          stream: stream,
          builder: (context) {
            return BottomAppBar(
              key: key,
              child: Row(
                children: [
                  IconButton(onPressed: state.openPaintEditor, icon: const Icon(Symbols.draw)),
                  // TODO add buttons to other editors, and add label
                ],
              ),
            );
          },
        ),
      ),
    ),
    cropRotateEditor: CropRotateEditorConfigs(
      enabled: true,
      aspectRatios:
          allowedAspectRatios?.map((r) {
            return AspectRatioItem(text: r.label, value: r.ratio);
          }).toList() ??
          [],
      widgets: CropRotateEditorWidgets(
        appBar: (state, stream) => ReactiveAppbar(
          builder: (context) {
            return AppBar(
              actions: [
                IconButton(onPressed: state.done, icon: const Icon(Symbols.check)),
                const Gap(8),
              ],
            );
          },
          stream: stream,
        ),
      ),
    ),
    paintEditor: PaintEditorConfigs(
      enabled: effectiveConfig.enablePaint,
      widgets: PaintEditorWidgets(
        appBar: (state, stream) => ReactiveAppbar(
          builder: (context) {
            return AppBar(
              flexibleSpace: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: state.openLinWidthBottomSheet,
                    icon: const Icon(Symbols.line_weight),
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  IconButton(
                    onPressed: state.openOpacityBottomSheet,
                    icon: const Icon(Symbols.opacity),
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  IconButton(
                    onPressed: state.toggleFill,
                    icon: Icon(Symbols.format_paint, fill: state.fillBackground ? 1 : 0),
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ],
              ).padding(vertical: 8),
              actions: [
                IconButton(onPressed: state.canUndo ? state.undoAction : null, icon: const Icon(Symbols.undo)),
                IconButton(onPressed: state.canRedo ? state.redoAction : null, icon: const Icon(Symbols.redo)),
                IconButton(onPressed: state.done, icon: const Icon(Symbols.check)),
                const Gap(8),
              ],
            );
          },
          stream: stream,
        ),
      ),
    ),
    textEditor: TextEditorConfigs(
      enabled: effectiveConfig.enableText,
      widgets: TextEditorWidgets(
        appBar: (state, stream) => ReactiveAppbar(
          builder: (context) {
            return AppBar(
              flexibleSpace: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: state.toggleTextAlign,
                    icon: switch (state.align) {
                      TextAlign.left => const Icon(Symbols.align_start),
                      TextAlign.center => const Icon(Symbols.align_center),
                      _ => const Icon(Symbols.align_end),
                    },
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  IconButton(
                    onPressed: state.openFontScaleBottomSheet,
                    icon: const Icon(Symbols.format_size),
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  IconButton(
                    onPressed: state.toggleBackgroundMode,
                    icon: Icon(Symbols.format_paint, fill: state.backgroundColorMode == .backgroundAndColor ? 1 : 0),
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                ],
              ).padding(vertical: 8),
              actions: [
                IconButton(onPressed: state.done, icon: const Icon(Symbols.check)),
                const Gap(8),
              ],
            );
          },
          stream: stream,
        ),
      ),
    ),
    // TODO update those editors appbar and bottom bars like above
    emojiEditor: const EmojiEditorConfigs(enabled: false),
    filterEditor: const FilterEditorConfigs(enabled: false),
    blurEditor: const BlurEditorConfigs(enabled: false),
    stickerEditor: const StickerEditorConfigs(enabled: false),
    tuneEditor: const TuneEditorConfigs(enabled: false),
  );
}

/// A dedicated image picker widget with preview and editing capabilities.
/// Uses pro_image_editor for image editing.
class ImagePickerEditor extends HookConsumerWidget {
  final ImageEditorConfig config;
  final String? title;

  const ImagePickerEditor({super.key, this.config = const ImageEditorConfig(), this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = useState<List<EditableImage>>([]);
    final uploadPosition = useState<int?>(null);
    final uploadProgress = useState<double?>(null);

    final uploadOverallProgress = useMemoized<double?>(() {
      if (uploadPosition.value == null || uploadProgress.value == null) {
        return null;
      }
      final completedProgress = uploadPosition.value! * 100.0;
      final currentProgress = uploadProgress.value!;
      return (completedProgress + currentProgress) / (images.value.length * 100.0);
    }, [uploadPosition.value, uploadProgress.value, images.value.length]);

    Future<void> startUpload() async {
      if (images.value.isEmpty) return;

      List<SnCloudFile> result = List.empty(growable: true);

      uploadProgress.value = 0;
      uploadPosition.value = 0;

      try {
        for (var idx = 0; idx < images.value.length; idx++) {
          uploadPosition.value = idx;
          final image = images.value[idx];

          final bytes = await image.getBytes();
          final xfile = XFile.fromData(bytes, name: image.displayName ?? image.file.name, mimeType: 'image/jpeg');

          final cloudFile = await ref
              .read(driveFileUploaderProvider)
              .createCloudFile(
                fileData: UniversalFile(data: xfile, type: UniversalFileType.image),
                onProgress: (progress, _) {
                  uploadProgress.value = progress;
                },
              )
              .future;

          if (cloudFile == null) {
            throw ArgumentError('Failed to upload the image...');
          }
          result.add(cloudFile);
        }

        if (context.mounted) {
          if (config.allowMultiple) {
            Navigator.pop(context, result);
          } else {
            Navigator.pop(context, result.isNotEmpty ? result.first : null);
          }
        }
      } catch (err) {
        showErrorAlert(err);
      }
    }

    void pickImages() async {
      showLoadingModal(context);
      final ImagePicker picker = ImagePicker();

      List<XFile> results;
      if (config.allowMultiple) {
        results = await picker.pickMultiImage();
      } else {
        final XFile? result = await picker.pickImage(source: ImageSource.gallery);
        results = result != null ? [result] : [];
      }

      if (results.isEmpty) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }

      // Check max images limit
      if (config.maxImages != null && images.value.length + results.length > config.maxImages!) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert('maxImagesError'.tr(args: [config.maxImages.toString()]));
        }
        return;
      }

      final newImages = results.map((xfile) {
        return EditableImage(
          file: xfile,
          id: '${DateTime.now().millisecondsSinceEpoch}_${xfile.name.hashCode}',
          displayName: xfile.name,
          compressionQuality: config.defaultCompressionQuality,
        );
      }).toList();

      if (!config.allowMultiple) {
        images.value = newImages;
        if (context.mounted) {
          hideLoadingModal(context);
        }
        return;
      }

      images.value = [...images.value, ...newImages];
      if (context.mounted) hideLoadingModal(context);
    }

    Future<void> editImage(EditableImage image) async {
      final bytes = await image.getBytes();

      if (!context.mounted) return;

      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (editorContext) => ProImageEditor.memory(
            bytes,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List editedBytes) async {
                final idx = images.value.indexWhere((i) => i.id == image.id);
                if (idx != -1) {
                  final updatedImages = [...images.value];
                  updatedImages[idx] = images.value[idx].copyWith(editedBytes: editedBytes, isEdited: true);
                  images.value = updatedImages;
                }
              },
            ),
            configs: createImageEditorConfigs(context, config: config, allowedAspectRatios: config.allowedAspectRatios),
          ),
        ),
      );
    }

    void showCompressionDialog(EditableImage image) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return _CompressionDialog(
            initialQuality: image.compressionQuality,
            onSave: (quality) {
              final idx = images.value.indexWhere((i) => i.id == image.id);
              if (idx != -1) {
                final updatedImages = [...images.value];
                updatedImages[idx] = images.value[idx].copyWith(compressionQuality: quality);
                images.value = updatedImages;
              }
            },
          );
        },
      );
    }

    void removeImage(String id) {
      images.value = images.value.where((i) => i.id != id).toList();
    }

    Future<void> takePhoto() async {
      showLoadingModal(context);
      final ImagePicker picker = ImagePicker();
      final XFile? result = await picker.pickImage(source: ImageSource.camera);

      if (result == null) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }

      // Check max images limit
      if (config.maxImages != null && images.value.length + 1 > config.maxImages!) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert('maxImagesError'.tr(args: [config.maxImages.toString()]));
        }
        return;
      }

      final newImage = EditableImage(
        file: result,
        id: '${DateTime.now().millisecondsSinceEpoch}_${result.name.hashCode}',
        displayName: result.name,
        compressionQuality: config.defaultCompressionQuality,
      );

      if (!config.allowMultiple) {
        images.value = [newImage];
      } else {
        images.value = [...images.value, newImage];
      }

      if (context.mounted) hideLoadingModal(context);
    }

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 20, right: 8, bottom: 12),
            child: Row(
              children: [
                Text(
                  title ?? 'pickImage'.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (config.maxImages != null)
                  Text(
                    '${images.value.length}/${config.maxImages}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    minimumSize: const Size(36, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upload progress
                  if (uploadOverallProgress != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'uploadingProgress'.tr(
                              args: [((uploadPosition.value ?? 0) + 1).toString(), images.value.length.toString()],
                            ),
                          ).opacity(0.85),
                          const Gap(6),
                          LinearProgressIndicator(value: uploadOverallProgress),
                        ],
                      ),
                    ),

                  // Selected images preview
                  if (images.value.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('selectedImages'.tr(), style: Theme.of(context).textTheme.titleMedium),
                          if (uploadOverallProgress == null)
                            FilledButton.icon(
                              onPressed: startUpload,
                              icon: const Icon(Symbols.cloud_upload, size: 18),
                              label: Text('upload'.tr()),
                            ),
                        ],
                      ),
                    ),
                    const Gap(12),

                    // Images grid
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: images.value.length,
                        separatorBuilder: (_, _) => const Gap(12),
                        itemBuilder: (context, index) {
                          final image = images.value[index];
                          return _ImagePreviewCard(
                            image: image,
                            onEdit: uploadOverallProgress == null ? () => editImage(image) : null,
                            onDelete: uploadOverallProgress == null ? () => removeImage(image.id) : null,
                            onCompression: config.allowCompression && uploadOverallProgress == null
                                ? () => showCompressionDialog(image)
                                : null,
                          );
                        },
                      ),
                    ),
                    const Gap(16),
                  ],

                  // Empty state
                  if (images.value.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(Symbols.photo_library, size: 64, color: Theme.of(context).colorScheme.outline),
                          const Gap(16),
                          Text(
                            'noImagesSelected'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
                          ),
                          const Gap(8),
                          Text(
                            config.allowMultiple ? 'selectImagesHint'.tr() : 'selectImageHint'.tr(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).padding(vertical: 48),

                  // Action buttons
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Symbols.photo_library),
                          title: Text('pickFromGallery'.tr()),
                          subtitle: config.allowMultiple ? Text('pickMultipleHint'.tr()) : null,
                          onTap: pickImages,
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Symbols.camera_alt),
                          title: Text('takePhoto'.tr()),
                          onTap: takePhoto,
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dialog for adjusting compression settings
class _CompressionDialog extends HookWidget {
  final int initialQuality;
  final Function(int) onSave;

  const _CompressionDialog({required this.initialQuality, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final quality = useState(initialQuality);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'compressionSettings'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(24),
          Text('compressionQuality'.tr(), style: Theme.of(context).textTheme.titleMedium),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: quality.value.toDouble(),
                  min: 10,
                  max: 100,
                  divisions: 18,
                  label: '${quality.value}%',
                  onChanged: (value) {
                    quality.value = value.toInt();
                  },
                ),
              ),
              Text('${quality.value}%'),
            ],
          ),
          const Gap(16),
          Text(
            'compressionHint'.tr(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
              const Gap(8),
              FilledButton(
                onPressed: () {
                  onSave(quality.value);
                  Navigator.pop(context);
                },
                child: Text('save'.tr()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A card widget that displays a preview of an editable image
class _ImagePreviewCard extends StatelessWidget {
  final EditableImage image;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onCompression;

  const _ImagePreviewCard({required this.image, this.onEdit, this.onDelete, this.onCompression});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: image.isEdited
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: image.isEdited ? 2 : 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image preview
            FutureBuilder<Uint8List>(
              future: image.getBytes(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(snapshot.data!, fit: BoxFit.cover);
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),

            // Edited indicator
            if (image.isEdited)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Symbols.edit, size: 12, color: Theme.of(context).colorScheme.onPrimary),
                      const Gap(4),
                      Text(
                        'edited'.tr(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Compression quality indicator
            if (onCompression != null)
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onCompression,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${image.compressionQuality}%',
                      style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ),

            // Action buttons overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (onEdit != null) _ActionButton(icon: Symbols.edit, onTap: onEdit!, tooltip: 'edit'.tr()),
                    if (onDelete != null)
                      _ActionButton(icon: Symbols.delete, onTap: onDelete!, tooltip: 'delete'.tr(), color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A small circular action button for image preview cards
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? color;

  const _ActionButton({required this.icon, required this.onTap, required this.tooltip, this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 18, color: color ?? Colors.white),
          ),
        ),
      ),
    );
  }
}

/// Shows the image picker editor as a bottom sheet
Future<dynamic> showImagePickerEditor(
  BuildContext context, {
  ImageEditorConfig config = const ImageEditorConfig(),
  String? title,
}) async {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => ImagePickerEditor(config: config, title: title),
  );
}
