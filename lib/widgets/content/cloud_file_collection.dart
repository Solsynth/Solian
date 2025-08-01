import 'dart:math' as math;
import 'dart:ui';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:gal/gal.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:path/path.dart' show extension;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:uuid/uuid.dart';

class CloudFileList extends HookConsumerWidget {
  final List<SnCloudFile> files;
  final double maxHeight;
  final double maxWidth;
  final double? minWidth;
  final bool disableZoomIn;
  final bool disableConstraint;
  final EdgeInsets? padding;
  const CloudFileList({
    super.key,
    required this.files,
    this.maxHeight = 560,
    this.maxWidth = double.infinity,
    this.minWidth,
    this.disableZoomIn = false,
    this.disableConstraint = false,
    this.padding,
  });

  double calculateAspectRatio() {
    double total = 0;
    for (var ratio in files.map((e) => e.fileMeta?['ratio'] ?? 1)) {
      if (ratio is double) total += ratio;
      if (ratio is String) total += double.parse(ratio);
    }
    if (total == 0) return 1;
    return total / files.length;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final heroTags = useMemoized(
      () => List.generate(
        files.length,
        (index) => 'cloud-files#${const Uuid().v4()}',
      ),
      [files],
    );

    if (files.isEmpty) return const SizedBox.shrink();
    if (files.length == 1) {
      final isImage = files.first.mimeType?.startsWith('image') ?? false;
      return Container(
        padding: padding,
        constraints: BoxConstraints(
          maxHeight: disableConstraint ? double.infinity : maxHeight,
          minWidth: minWidth ?? 0,
          maxWidth: files.length == 1 ? maxWidth : double.infinity,
        ),
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: _CloudFileListEntry(
              file: files.first,
              heroTag: heroTags.first,
              isImage: isImage,
              disableZoomIn: disableZoomIn,
              onTap: () {
                if (!isImage) {
                  return;
                }
                if (!disableZoomIn) {
                  context.pushTransparentRoute(
                    CloudFileZoomIn(item: files.first, heroTag: heroTags.first),
                    rootNavigator: true,
                  );
                }
              },
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight, minWidth: maxWidth),
      child: AspectRatio(
        aspectRatio: calculateAspectRatio(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: files.length,
          padding: padding,
          itemBuilder: (context, index) {
            return AspectRatio(
              aspectRatio:
                  files[index].fileMeta?['ratio'] is num
                      ? files[index].fileMeta!['ratio'].toDouble()
                      : 1.0,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: _CloudFileListEntry(
                      file: files[index],
                      heroTag: heroTags[index],
                      isImage:
                          files[index].mimeType?.startsWith('image') ?? false,
                      disableZoomIn: disableZoomIn,
                      onTap: () {
                        if (!(files[index].mimeType?.startsWith('image') ??
                            false)) {
                          return;
                        }
                        if (!disableZoomIn) {
                          context.pushTransparentRoute(
                            CloudFileZoomIn(
                              item: files[index],
                              heroTag: heroTags[index],
                            ),
                            rootNavigator: true,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Text('${index + 1}/${files.length}')
                        .textColor(Colors.white)
                        .textShadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, _) => const Gap(8),
        ),
      ),
    );
  }
}

class CloudFileZoomIn extends HookConsumerWidget {
  final SnCloudFile item;
  final String heroTag;
  const CloudFileZoomIn({super.key, required this.item, required this.heroTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final photoViewController = useMemoized(() => PhotoViewController(), []);
    final rotation = useState(0);

    Future<void> saveToGallery() async {
      try {
        // Show loading indicator
        showSnackBar('Saving image to gallery...');

        // Get the image URL
        final client = ref.watch(apiClientProvider);

        // Create a temporary file to save the image
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/${item.id}.${extension(item.name)}';

        await client.download(
          '/drive/files/${item.id}',
          filePath,
          queryParameters: {'original': true},
        );
        await Gal.putImage(filePath, album: 'Solar Network');

        // Show success message
        showSnackBar('Image saved to gallery');
      } catch (e) {
        showErrorAlert(e);
      }
    }

    Widget buildInfoRow(IconData icon, String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    String formatFileSize(int bytes) {
      if (bytes <= 0) return '0 B';
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
      if (bytes < 1024 * 1024 * 1024) {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
      }
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }

    void showInfoSheet() {
      final theme = Theme.of(context);
      final exifData = item.fileMeta?['exif'] as Map<String, dynamic>? ?? {};

      showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        builder:
            (context) => SheetScaffold(
              titleText: 'File Information',
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildInfoRow(Icons.description, 'Name', item.name),
                    const Divider(height: 1),
                    buildInfoRow(
                      Icons.storage,
                      'Size',
                      formatFileSize(item.size),
                    ),
                    const Divider(height: 1),
                    buildInfoRow(
                      Icons.category,
                      'Type',
                      item.mimeType?.toUpperCase() ?? 'UNKNOWN',
                    ),
                    if (exifData.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'EXIF Data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ).padding(horizontal: 24),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...exifData.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ${entry.key.contains('-') ? entry.key.split('-').last : entry.key}: ',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${entry.value}'.isNotEmpty
                                          ? '${entry.value}'
                                          : 'N/A',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ).padding(horizontal: 24),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      );
    }

    return DismissiblePage(
      isFullScreen: true,
      backgroundColor: Colors.transparent,
      direction: DismissiblePageDismissDirection.down,
      onDismissed: () {
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: PhotoView(
              backgroundDecoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
              ),
              controller: photoViewController,
              heroAttributes: PhotoViewHeroAttributes(tag: heroTag),
              imageProvider: CloudImageWidget.provider(
                fileId: item.id,
                serverUrl: serverUrl,
              ),
              // Apply rotation transformation
              customSize: MediaQuery.of(context).size,
              basePosition: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
          ),
          // Close button and save button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            left: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.save_alt,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 5.0,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                      onPressed: () async {
                        saveToGallery();
                      },
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Rotation controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  onPressed: showInfoSheet,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.remove, color: Colors.white),
                  onPressed: () {
                    photoViewController.scale =
                        (photoViewController.scale ?? 1) - 0.05;
                  },
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.white),
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
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  onPressed: () {
                    rotation.value = (rotation.value - 1) % 4;
                    photoViewController.rotation =
                        rotation.value * -math.pi / 2;
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5.0,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                  onPressed: () {
                    rotation.value = (rotation.value + 1) % 4;
                    photoViewController.rotation =
                        rotation.value * -math.pi / 2;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CloudFileListEntry extends StatelessWidget {
  final SnCloudFile file;
  final String heroTag;
  final bool isImage;
  final bool disableZoomIn;
  final VoidCallback? onTap;

  const _CloudFileListEntry({
    required this.file,
    required this.heroTag,
    required this.isImage,
    required this.disableZoomIn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Stack(
      fit: StackFit.expand,
      children: [
        if (isImage)
          Positioned.fill(
            child:
                file.fileMeta?['blur'] is String
                    ? BlurHash(hash: file.fileMeta?['blur'])
                    : ImageFiltered(
                      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: CloudFileWidget(item: file, noBlurhash: true),
                    ),
          ),
        if (isImage)
          CloudFileWidget(
            item: file,
            heroTag: heroTag,
            noBlurhash: true,
            fit: BoxFit.contain,
          )
        else
          CloudFileWidget(item: file, heroTag: heroTag, fit: BoxFit.contain),
      ],
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
