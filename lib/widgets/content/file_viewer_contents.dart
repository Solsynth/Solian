import 'dart:io';
import 'dart:math' as math;

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/utils/format.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/audio.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/file_info_sheet.dart';
import 'package:island/widgets/content/video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show extension;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfFileContent extends HookConsumerWidget {
  final String uri;

  const PdfFileContent({required this.uri, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfViewer = useMemoized(() => SfPdfViewer.network(uri), [uri]);
    return pdfViewer;
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
    final showOriginal = useState(false);

    final shadow = [
      Shadow(color: Colors.black54, blurRadius: 5.0, offset: Offset(1.0, 1.0)),
    ];

    return Stack(
      children: [
        Positioned.fill(
          child: PhotoView(
            backgroundDecoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
            ),
            controller: photoViewController,
            imageProvider: CloudImageWidget.provider(
              fileId: item.id,
              serverUrl: ref.watch(serverUrlProvider),
              original: showOriginal.value,
            ),
            customSize: MediaQuery.of(context).size,
            basePosition: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        // Controls overlay
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 16,
          right: 16,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove, color: Colors.white, shadows: shadow),
                onPressed: () {
                  photoViewController.scale =
                      (photoViewController.scale ?? 1) - 0.05;
                },
              ),
              IconButton(
                icon: Icon(Icons.add, color: Colors.white, shadows: shadow),
                onPressed: () {
                  photoViewController.scale =
                      (photoViewController.scale ?? 1) + 0.05;
                },
              ),
              const Gap(8),
              IconButton(
                icon: Icon(
                  Icons.rotate_left,
                  color: Colors.white,
                  shadows: shadow,
                ),
                onPressed: () {
                  rotation.value = (rotation.value - 1) % 4;
                  photoViewController.rotation = rotation.value * -math.pi / 2;
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.rotate_right,
                  color: Colors.white,
                  shadows: shadow,
                ),
                onPressed: () {
                  rotation.value = (rotation.value + 1) % 4;
                  photoViewController.rotation = rotation.value * -math.pi / 2;
                },
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  showOriginal.value = !showOriginal.value;
                },
                icon: Icon(
                  showOriginal.value ? Symbols.hd : Symbols.sd,
                  color: Colors.white,
                  shadows: shadow,
                ),
              ),
            ],
          ),
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
    var ratio =
        item.fileMeta?['ratio'] is num
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
    Future<void> downloadFile() async {
      try {
        showSnackBar('Downloading file...');

        final client = ref.read(apiClientProvider);
        final tempDir = await getTemporaryDirectory();
        var extName = extension(item.name).trim();
        if (extName.isEmpty) {
          extName = item.mimeType?.split('/').lastOrNull ?? 'bin';
        }
        final filePath = '${tempDir.path}/${item.id}.$extName';

        await client.download(
          '/drive/files/${item.id}',
          filePath,
          queryParameters: {'original': true},
        );

        await FileSaver.instance.saveFile(
          name: item.name.isEmpty ? '${item.id}.$extName' : item.name,
          file: File(filePath),
        );
        showSnackBar('File saved to downloads');
      } catch (e) {
        showErrorAlert(e);
      }
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
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
                  onPressed: downloadFile,
                  icon: const Icon(Symbols.download),
                  label: Text('download'),
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
                  label: Text('info'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
