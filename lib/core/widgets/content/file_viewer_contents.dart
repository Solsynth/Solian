import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/content/audio.dart';
import 'package:island/shared/widgets/content/video.native.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/widgets/content/exif_info_overlay.dart';
import 'package:island/core/widgets/content/file_info_sheet.dart';
import 'package:island/core/widgets/content/image_control_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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

    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned.fill(
            child: Listener(
              onPointerSignal: (pointerSignal) {
                try {
                  final delta =
                      (pointerSignal as dynamic).scrollDelta.dy as double?;
                  if (delta != null && delta != 0) {
                    final currentScale = photoViewController.scale ?? 1.0;
                    final newScale = delta > 0
                        ? currentScale * 0.9
                        : currentScale * 1.1;
                    final clampedScale = newScale.clamp(0.1, 10.0);
                    photoViewController.scale = clampedScale;
                  }
                } catch (_) {
                  // Ignore non-scroll events.
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
                customSize: Size(constraints.maxWidth, constraints.maxHeight),
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
      ),
    );
  }
}

class VideoFileContent extends HookConsumerWidget {
  final SnCloudFile item;
  final String uri;

  const VideoFileContent({required this.item, required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var ratio = item.ratio;
    if (ratio == 0) ratio = 16 / 9;

    return Center(
      child: UniversalVideo(
        uri: uri,
        autoplay: true,
        aspectRatio: ratio ?? 16 / 9,
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
                onPressed: () => ref
                    .read(driveFileDownloaderProvider)
                    .downloadFile(
                      item,
                      useDownloadsFolder:
                          HardwareKeyboard.instance.isShiftPressed,
                    ),
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
