import 'dart:io';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/file_download.dart';
import 'package:island/utils/format.dart';
import 'package:island/widgets/content/audio.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/exif_info_overlay.dart';
import 'package:island/widgets/content/file_info_sheet.dart';
import 'package:island/widgets/content/image_control_overlay.dart';
import 'package:island/widgets/content/video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfFileContent extends HookConsumerWidget {
  final String uri;

  const PdfFileContent({required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileFuture = useMemoized(
      () => DefaultCacheManager().getSingleFile(uri),
      [uri],
    );

    final pdfController = useMemoized(() => PdfViewerController(), []);

    final shadow = [
      Shadow(color: Colors.black54, blurRadius: 5.0, offset: Offset(1.0, 1.0)),
    ];

    return FutureBuilder<File>(
      future: fileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading PDF: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return Stack(
            children: [
              SfPdfViewer.file(snapshot.data!, controller: pdfController),
              // Controls overlay
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove,
                        color: Colors.white,
                        shadows: shadow,
                      ),
                      onPressed: () {
                        pdfController.zoomLevel = pdfController.zoomLevel * 0.9;
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                        shadows: shadow,
                      ),
                      onPressed: () {
                        pdfController.zoomLevel = pdfController.zoomLevel * 1.1;
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const Center(child: Text('No PDF data'));
      },
    );
  }
}

class TextFileContent extends HookConsumerWidget {
  final String uri;

  const TextFileContent({required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textFuture = useMemoized(
      () => ref
          .read(apiClientProvider)
          .get(uri)
          .then((response) => response.data as String),
      [uri],
    );

    return FutureBuilder<String>(
      future: textFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading text: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: SelectableText(
              snapshot.data!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            ),
          );
        }
        return const Center(child: Text('No content'));
      },
    );
  }
}

class ImageFileContent extends HookConsumerWidget {
  final SnCloudFile item;
  final String uri;

  const ImageFileContent({required this.item, required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoViewController = useMemoized(() => PhotoViewController(), []);
    final rotation = useState(0);

    final hasExifData = ExifInfoOverlay.precheck(item);
    final showOriginal = useState(false);
    final showExif = useState(hasExifData);

    return Stack(
      children: [
        Positioned.fill(
          child: Listener(
            onPointerSignal: (pointerSignal) {
              try {
                // Handle mouse wheel zoom - cast to dynamic to access scrollDelta
                final delta =
                    (pointerSignal as dynamic).scrollDelta.dy as double?;
                if (delta != null && delta != 0) {
                  final currentScale = photoViewController.scale ?? 1.0;
                  // Adjust scale based on scroll direction (invert for natural zoom)
                  final newScale = delta > 0
                      ? currentScale * 0.9
                      : currentScale * 1.1;
                  // Clamp scale to reasonable bounds
                  final clampedScale = newScale.clamp(0.1, 10.0);
                  photoViewController.scale = clampedScale;
                }
              } catch (e) {
                // Ignore non-scroll events
              }
            },
            child: PhotoView(
              backgroundDecoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
              ),
              controller: photoViewController,
              imageProvider: CloudImageWidget.provider(
                file: item,
                serverUrl: ref.watch(serverUrlProvider),
                original: showOriginal.value,
              ),
              customSize: MediaQuery.of(context).size,
              basePosition: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        if (showExif.value)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 60,
            left: 16,
            right: 16,
            child: ExifInfoOverlay(item: item),
          ),
        ImageControlOverlay(
          photoViewController: photoViewController,
          rotation: rotation,
          showOriginal: showOriginal.value,
          onToggleQuality: () {
            showOriginal.value = !showOriginal.value;
          },
          showExifInfo: showExif.value,
          onToggleExif: () {
            showExif.value = !showExif.value;
          },
          hasExifData: hasExifData,
        ),
      ],
    );
  }
}

class VideoFileContent extends HookConsumerWidget {
  final SnCloudFile item;
  final String uri;

  const VideoFileContent({required this.item, required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var ratio = item.fileMeta?['ratio'] is num
        ? item.fileMeta!['ratio'].toDouble()
        : 1.0;
    if (ratio == 0) ratio = 1.0;

    return Center(
      child: AspectRatio(
        aspectRatio: ratio,
        child: UniversalVideo(uri: uri, autoplay: true),
      ),
    );
  }
}

class AudioFileContent extends HookConsumerWidget {
  final SnCloudFile item;
  final String uri;

  const AudioFileContent({required this.item, required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(360, MediaQuery.of(context).size.width * 0.8),
        ),
        child: UniversalAudio(uri: uri, filename: item.name),
      ),
    );
  }
}

class GenericFileContent extends HookConsumerWidget {
  final SnCloudFile item;

  const GenericFileContent({required this.item, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.insert_drive_file,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const Gap(16),
          Text(
            item.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            formatFileSize(item.size),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: () => FileDownloadService(ref).downloadFile(item),
                icon: const Icon(Symbols.download),
                label: Text('download').tr(),
              ),
              const Gap(16),
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    useRootNavigator: true,
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => FileInfoSheet(item: item),
                  );
                },
                icon: const Icon(Symbols.info),
                label: Text('info').tr(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
