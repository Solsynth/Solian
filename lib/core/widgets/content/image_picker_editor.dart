import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/widgets/compose/compose_link_attachments.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
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

  /// Usage context for the uploaded file (e.g. 'profile_picture', 'post')
  final String? usage;

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
    this.usage,
  });

  /// Preset for avatar/profile picture (1:1 aspect ratio, single image)
  static const avatar = ImageEditorConfig(
    allowedAspectRatios: [ImageAspectRatio.square],
    allowMultiple: false,
    allowCompression: true,
    defaultCompressionQuality: 90,
    usage: 'profile_picture',
  );

  /// Preset for banner/background (16:9 aspect ratio, single image)
  static const banner = ImageEditorConfig(
    allowedAspectRatios: [ImageAspectRatio(width: 16, height: 9)],
    allowMultiple: false,
    allowCompression: true,
    defaultCompressionQuality: 85,
    usage: 'profile_background',
  );

  /// Preset for post attachments (freeform, multiple images)
  static const postAttachments = ImageEditorConfig(
    allowedAspectRatios: null,
    allowMultiple: true,
    allowCompression: true,
    defaultCompressionQuality: 85,
    usage: 'post',
  );

  /// Preset for story (9:16 aspect ratio, single image)
  static const story = ImageEditorConfig(
    allowedAspectRatios: [ImageAspectRatio(width: 9, height: 16)],
    allowMultiple: false,
    allowCompression: true,
    defaultCompressionQuality: 90,
    usage: 'post',
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
      defaultCompressionQuality:
          defaultCompressionQuality ?? this.defaultCompressionQuality,
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
  bool isCropped;

  EditableImage({
    required this.file,
    required this.id,
    this.editedBytes,
    this.displayName,
    this.isEdited = false,
    this.compressionQuality = 85,
    this.isCropped = false,
  });

  EditableImage copyWith({
    XFile? file,
    String? id,
    Uint8List? editedBytes,
    String? displayName,
    bool? isEdited,
    int? compressionQuality,
    bool? isCropped,
  }) {
    return EditableImage(
      file: file ?? this.file,
      id: id ?? this.id,
      editedBytes: editedBytes ?? this.editedBytes,
      displayName: displayName ?? this.displayName,
      isEdited: isEdited ?? this.isEdited,
      compressionQuality: compressionQuality ?? this.compressionQuality,
      isCropped: isCropped ?? this.isCropped,
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

/// Format bytes to human readable string
String _formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

String _editedImageName(String originalName, {required bool isEdited}) {
  if (!isEdited) return originalName;

  final extension = p.extension(originalName);
  if (extension.isEmpty) return '${originalName}_cropped.png';
  return originalName.replaceRange(
    originalName.length - extension.length,
    originalName.length,
    '.png',
  );
}

String _imageMimeType(String fileName, {required bool isEdited}) {
  if (isEdited) return 'image/png';
  return lookupMimeType(fileName) ?? 'image/jpeg';
}

Future<Uint8List?> showCropImageEditor(
  BuildContext context, {
  required Uint8List imageBytes,
  List<ImageAspectRatio>? allowedAspectRatios,
}) {
  return Navigator.of(context, rootNavigator: true).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _CropImageEditorScreen(
        imageBytes: imageBytes,
        allowedAspectRatios: allowedAspectRatios,
      ),
    ),
  );
}

class _CropImageEditorScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final List<ImageAspectRatio>? allowedAspectRatios;

  const _CropImageEditorScreen({
    required this.imageBytes,
    required this.allowedAspectRatios,
  });

  @override
  State<_CropImageEditorScreen> createState() => _CropImageEditorScreenState();
}

class _CropImageEditorScreenState extends State<_CropImageEditorScreen> {
  late CropController _controller;
  late double? _activeAspectRatio;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _activeAspectRatio = widget.allowedAspectRatios?.firstOrNull?.ratio;
    _controller = CropController(aspectRatio: _activeAspectRatio);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetCrop() {
    _controller
      ..aspectRatio = _activeAspectRatio
      ..crop = const Rect.fromLTWH(0, 0, 1, 1)
      ..rotation = CropRotation.up;
  }

  void _setAspectRatio(double? ratio) {
    setState(() {
      _activeAspectRatio = ratio;
      _controller.aspectRatio = ratio;
      _controller.crop = const Rect.fromLTWH(0, 0, 1, 1);
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final bitmap = await _controller.croppedBitmap();
      final byteData = await bitmap.toByteData(format: ui.ImageByteFormat.png);
      if (!mounted) return;
      Navigator.pop(context, byteData?.buffer.asUint8List());
    } catch (err) {
      showErrorAlert(err);
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowedAspectRatios = widget.allowedAspectRatios ?? const [];
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: theme.appBarTheme.copyWith(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Symbols.close),
          ),
          title: Text('imageEditorCrop'.tr()),
          actions: [
            IconButton(
              onPressed: _isSaving ? null : _resetCrop,
              icon: const Icon(Symbols.history),
            ),
            IconButton(
              onPressed: _isSaving ? null : _save,
              icon: const Icon(Symbols.check),
            ),
            const Gap(8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CropImage(
                  controller: _controller,
                  image: Image.memory(widget.imageBytes, fit: BoxFit.contain),
                  gridColor: Colors.white70,
                  gridCornerColor: theme.colorScheme.primary,
                  gridInnerColor: Colors.white54,
                  gridThinWidth: 1.5,
                  gridThickWidth: 3,
                  scrimColor: Colors.black54,
                  alwaysShowThirdLines: true,
                  paddingSize: 24,
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  border: Border(top: BorderSide(color: Colors.white12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12,
                  children: [
                    if (_isSaving) const LinearProgressIndicator(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isSaving ? null : _controller.rotateLeft,
                          icon: const Icon(Symbols.rotate_90_degrees_ccw),
                          label: Text('imageEditorRotate'.tr()),
                        ),
                        if (allowedAspectRatios.isNotEmpty)
                          PopupMenuButton<double?>(
                            enabled: !_isSaving,
                            initialValue: _activeAspectRatio,
                            onSelected: _setAspectRatio,
                            itemBuilder: (context) => [
                              PopupMenuItem<double?>(
                                value: null,
                                child: Text('imageEditorFree'.tr()),
                              ),
                              ...allowedAspectRatios.map(
                                (ratio) => PopupMenuItem<double?>(
                                  value: ratio.ratio,
                                  child: Text(ratio.label),
                                ),
                              ),
                            ],
                            child: OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Symbols.aspect_ratio),
                              label: Text(
                                _activeAspectRatio == null
                                    ? 'imageEditorFree'.tr()
                                    : allowedAspectRatios
                                          .firstWhere(
                                            (ratio) =>
                                                ratio.ratio ==
                                                _activeAspectRatio,
                                            orElse: () => ImageAspectRatio(
                                              width: _activeAspectRatio!
                                                  .round(),
                                              height: 1,
                                            ),
                                          )
                                          .label,
                              ),
                            ),
                          ),
                      ],
                    ),
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

/// A dedicated image picker widget with preview and cropping capabilities.
class ImagePickerEditor extends HookConsumerWidget {
  final ImageEditorConfig config;
  final String? title;
  final bool allowLinkAttachment;

  const ImagePickerEditor({
    super.key,
    this.config = const ImageEditorConfig(),
    this.title,
    this.allowLinkAttachment = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = useState<List<EditableImage>>([]);
    final linkedFiles = useState<List<SnCloudFile>>([]);
    final uploadPosition = useState<int?>(null);
    final uploadProgress = useState<double?>(null);

    final totalCount = images.value.length + linkedFiles.value.length;

    final uploadOverallProgress = useMemoized<double?>(() {
      if (uploadPosition.value == null || uploadProgress.value == null) {
        return null;
      }
      final completedProgress = uploadPosition.value! * 100.0;
      final currentProgress = uploadProgress.value!;
      return (completedProgress + currentProgress) /
          (images.value.length * 100.0);
    }, [uploadPosition.value, uploadProgress.value, images.value.length]);

    Future<void> startUpload() async {
      if (totalCount == 0) return;

      List<SnCloudFile> result = List.from(linkedFiles.value);

      if (images.value.isEmpty) {
        if (context.mounted) {
          if (config.allowMultiple) {
            Navigator.pop(context, result);
          } else {
            Navigator.pop(context, result.isNotEmpty ? result.first : null);
          }
        }
        return;
      }

      uploadProgress.value = 0;
      uploadPosition.value = 0;

      try {
        for (var idx = 0; idx < images.value.length; idx++) {
          uploadPosition.value = idx;
          final image = images.value[idx];

          final bytes = await image.getBytes();
          final xfile = XFile.fromData(
            bytes,
            name: _editedImageName(
              image.displayName ?? image.file.name,
              isEdited: image.isEdited,
            ),
            mimeType: _imageMimeType(
              image.displayName ?? image.file.name,
              isEdited: image.isEdited,
            ),
          );

          final cloudFile = await ref
              .read(driveFileUploaderProvider)
              .createCloudFile(
                fileData: UniversalFile(
                  data: xfile,
                  type: UniversalFileType.image,
                ),
                usage: config.usage,
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

    Future<void> editImage(EditableImage image) async {
      final bytes = await image.getBytes();

      if (!context.mounted) return;

      final editedBytes = await showCropImageEditor(
        context,
        imageBytes: bytes,
        allowedAspectRatios: config.allowedAspectRatios,
      );

      if (editedBytes == null) return;

      final idx = images.value.indexWhere((i) => i.id == image.id);
      if (idx != -1) {
        final updatedImages = [...images.value];
        updatedImages[idx] = images.value[idx].copyWith(
          editedBytes: editedBytes,
          isEdited: true,
          isCropped: true,
        );
        images.value = updatedImages;
      }
    }

    void pickImages() async {
      showLoadingModal(context);
      final ImagePicker picker = ImagePicker();

      List<XFile> results;
      if (config.allowMultiple) {
        results = await picker.pickMultiImage();
      } else {
        final XFile? result = await picker.pickImage(
          source: ImageSource.gallery,
        );
        results = result != null ? [result] : [];
      }

      if (results.isEmpty) {
        if (context.mounted) hideLoadingModal(context);
        return;
      }

      // Check max images limit
      if (config.maxImages != null &&
          totalCount + results.length > config.maxImages!) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert(
            'maxImagesError'.tr(args: [config.maxImages.toString()]),
          );
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

      // Check if cropping is required
      final croppingRequired =
          config.allowedAspectRatios != null &&
          config.allowedAspectRatios!.isNotEmpty;

      if (!config.allowMultiple) {
        images.value = newImages;
        if (context.mounted) {
          hideLoadingModal(context);
        }
        // Auto-open crop editor if cropping is required
        if (croppingRequired && newImages.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            editImage(newImages.first);
          });
        }
        return;
      }

      images.value = [...images.value, ...newImages];
      if (context.mounted) hideLoadingModal(context);

      // Auto-open crop editor for each new image if cropping is required
      if (croppingRequired && newImages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (final image in newImages) {
            editImage(image);
          }
        });
      }
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
                updatedImages[idx] = images.value[idx].copyWith(
                  compressionQuality: quality,
                );
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

    void removeLinkedFile(int index) {
      linkedFiles.value = linkedFiles.value
          .asMap()
          .entries
          .where((e) => e.key != index)
          .map((e) => e.value)
          .toList();
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
      if (config.maxImages != null && totalCount + 1 > config.maxImages!) {
        if (context.mounted) {
          hideLoadingModal(context);
          showErrorAlert(
            'maxImagesError'.tr(args: [config.maxImages.toString()]),
          );
        }
        return;
      }

      final newImage = EditableImage(
        file: result,
        id: '${DateTime.now().millisecondsSinceEpoch}_${result.name.hashCode}',
        displayName: result.name,
        compressionQuality: config.defaultCompressionQuality,
      );

      // Check if cropping is required
      final croppingRequired =
          config.allowedAspectRatios != null &&
          config.allowedAspectRatios!.isNotEmpty;

      if (!config.allowMultiple) {
        images.value = [newImage];
        linkedFiles.value = [];
      } else {
        images.value = [...images.value, newImage];
      }

      if (context.mounted) hideLoadingModal(context);

      // Auto-open crop editor if cropping is required
      if (croppingRequired) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          editImage(newImage);
        });
      }
    }

    Future<void> pickLinkAttachment() async {
      final result = await showModalBottomSheet<SnCloudFile>(
        context: context,
        isScrollControlled: true,
        builder: (context) => const ComposeLinkAttachment(),
      );

      if (result == null) return;
      if (!context.mounted) return;

      // Check max images limit
      if (config.maxImages != null && totalCount + 1 > config.maxImages!) {
        showErrorAlert(
          'maxImagesError'.tr(args: [config.maxImages.toString()]),
        );
        return;
      }

      if (!config.allowMultiple) {
        Navigator.pop(context, result);
        return;
      }

      linkedFiles.value = [...linkedFiles.value, result];
    }

    // Check if camera is available (mobile only)
    final isCameraAvailable = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    // Calculate if cropping is required and the target aspect ratio
    final requiresCropping =
        config.allowedAspectRatios != null &&
        config.allowedAspectRatios!.isNotEmpty;
    final targetAspectRatio = requiresCropping
        ? config.allowedAspectRatios!.first.ratio
        : null;

    // Check if all images are cropped when cropping is required
    final allImagesCropped =
        !requiresCropping || images.value.every((img) => img.isCropped);

    return SheetScaffold(
      titleText: title ?? 'pickImage'.tr(),
      actions: [
        if (config.maxImages != null)
          Text(
            '$totalCount/${config.maxImages}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
      ],
      heightFactor: 0.7,
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
                        args: [
                          ((uploadPosition.value ?? 0) + 1).toString(),
                          images.value.length.toString(),
                        ],
                      ),
                    ).opacity(0.85),
                    const Gap(6),
                    LinearProgressIndicator(value: uploadOverallProgress),
                  ],
                ),
              ),

            // Selected images preview
            if (totalCount > 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    const Icon(Symbols.image).padding(horizontal: 4),
                    FutureBuilder<int>(
                      future: Future.wait(
                        images.value.map((img) => img.getSize()),
                      ).then((sizes) => sizes.fold<int>(0, (a, b) => a + b)),
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'selectedImages'.tr(),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (snapshot.hasData)
                              Text(
                                _formatFileSize(snapshot.data!),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context).hintColor,
                                    ),
                              ),
                          ],
                        );
                      },
                    ),
                    const Spacer(),
                    if (uploadOverallProgress == null)
                      FilledButton.icon(
                        onPressed: allImagesCropped ? startUpload : null,
                        icon: const Icon(Symbols.cloud_upload, size: 18),
                        label: Text('upload'.tr()),
                      ),
                  ],
                ),
              ),

              // Crop required hint
              if (!allImagesCropped && uploadOverallProgress == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.crop,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(8),
                      Text(
                        'cropRequiredHint'.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              const Gap(8),

              // Images grid
              if (images.value.isNotEmpty)
                config.allowMultiple
                    ? SizedBox(
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
                              aspectRatio: targetAspectRatio,
                              onEdit: uploadOverallProgress == null
                                  ? () => editImage(image)
                                  : null,
                              onDelete: uploadOverallProgress == null
                                  ? () => removeImage(image.id)
                                  : null,
                              onCompression:
                                  config.allowCompression &&
                                      uploadOverallProgress == null
                                  ? () => showCompressionDialog(image)
                                  : null,
                            );
                          },
                        ),
                      )
                    : ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 280),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: AspectRatio(
                            aspectRatio: targetAspectRatio ?? 1.0,
                            child: _ImagePreviewCard(
                              image: images.value.first,
                              isFullWidth: true,
                              aspectRatio:
                                  null, // Don't apply aspect ratio inside the card
                              onEdit: uploadOverallProgress == null
                                  ? () => editImage(images.value.first)
                                  : null,
                              onDelete: uploadOverallProgress == null
                                  ? () => removeImage(images.value.first.id)
                                  : null,
                              onCompression:
                                  config.allowCompression &&
                                      uploadOverallProgress == null
                                  ? () => showCompressionDialog(
                                      images.value.first,
                                    )
                                  : null,
                            ),
                          ),
                        ).alignment(Alignment.centerLeft),
                      ),

              // Linked files preview
              if (linkedFiles.value.isNotEmpty) ...[
                const Gap(16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.link,
                        size: 18,
                        color: Theme.of(context).hintColor,
                      ),
                      const Gap(8),
                      Text(
                        'linkedAttachments'.tr(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(8),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: linkedFiles.value.length,
                    separatorBuilder: (_, _) => const Gap(12),
                    itemBuilder: (context, index) {
                      final file = linkedFiles.value[index];
                      return _LinkedFileCard(
                        file: file,
                        onDelete: uploadOverallProgress == null
                            ? () => removeLinkedFile(index)
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ],

            // Empty state
            if (totalCount == 0)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Symbols.photo_library,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const Gap(16),
                    Text(
                      'noImagesSelected'.tr(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      config.allowMultiple
                          ? 'selectImagesHint'.tr()
                          : 'selectImageHint'.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
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
                  if (allowLinkAttachment) ...[
                    ListTile(
                      leading: const Icon(Symbols.link),
                      title: Text('addLinkAttachment'.tr()),
                      onTap: pickLinkAttachment,
                    ),
                    const Divider(height: 1),
                  ],
                  ListTile(
                    leading: const Icon(Symbols.photo_library),
                    title: Text('pickFromGallery'.tr()),
                    subtitle: config.allowMultiple
                        ? Text('pickMultipleHint'.tr())
                        : null,
                    onTap: pickImages,
                  ),
                  if (isCameraAvailable) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Symbols.camera_alt),
                      title: Text('takePhoto'.tr()),
                      onTap: takePhoto,
                    ),
                  ],
                ],
              ),
            ),

            const Gap(16),
          ],
        ),
      ),
    );
  }
}

/// A dialog for adjusting compression settings
class _CompressionDialog extends HookWidget {
  final int initialQuality;
  final Function(int) onSave;

  const _CompressionDialog({
    required this.initialQuality,
    required this.onSave,
  });

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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Gap(24),
          Text(
            'compressionQuality'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(year2023: true),
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
              ),
              Text('${quality.value}%'),
            ],
          ),
          const Gap(16),
          Text(
            'compressionHint'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor),
          ),
          const Gap(24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('cancel'.tr()),
              ),
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
  final bool isFullWidth;
  final double? aspectRatio;

  const _ImagePreviewCard({
    required this.image,
    this.onEdit,
    this.onDelete,
    this.onCompression,
    this.isFullWidth = false,
    this.aspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageContent = ClipRRect(
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
                    Icon(
                      Symbols.edit,
                      size: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${image.compressionQuality}%',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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
                spacing: 6,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onEdit != null)
                    _ActionButton(
                      icon: Symbols.edit,
                      onTap: onEdit!,
                      tooltip: 'edit'.tr(),
                    ),
                  if (onDelete != null)
                    _ActionButton(
                      icon: Symbols.delete,
                      onTap: onDelete!,
                      tooltip: 'delete'.tr(),
                      color: Colors.red,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Wrap in AspectRatio if specified
    if (aspectRatio != null) {
      imageContent = AspectRatio(
        aspectRatio: aspectRatio!,
        child: imageContent,
      );
    }

    return Container(
      width: isFullWidth ? double.infinity : 140,
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
      child: imageContent,
    );
  }
}

/// A card widget that displays a linked cloud file
class _LinkedFileCard extends StatelessWidget {
  final SnCloudFile file;
  final VoidCallback? onDelete;

  const _LinkedFileCard({required this.file, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isImage = file.mimeType.startsWith('image/');

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: isImage
                      ? CloudImageWidget(file: file, fit: BoxFit.cover)
                      : Icon(
                          Symbols.link,
                          size: 32,
                          color: Theme.of(context).colorScheme.outline,
                        ).center(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  file.name.isEmpty ? 'untitled'.tr() : file.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          // Link indicator
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.link,
                    size: 12,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                  const Gap(4),
                  Text(
                    'linked'.tr(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Delete button
          if (onDelete != null)
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      icon: Symbols.delete,
                      onTap: onDelete!,
                      tooltip: 'delete'.tr(),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
        ],
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

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.color,
  });

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
