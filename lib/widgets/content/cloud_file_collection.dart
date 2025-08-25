import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:island/widgets/content/sensitive.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
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
  final bool isColumn;
  const CloudFileList({
    super.key,
    required this.files,
    this.maxHeight = 560,
    this.maxWidth = double.infinity,
    this.minWidth,
    this.disableZoomIn = false,
    this.disableConstraint = false,
    this.padding,
    this.isColumn = false,
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

    if (isColumn) {
      final children = <Widget>[];
      const maxFiles = 2;
      final filesToShow = files.take(maxFiles).toList();

      for (var i = 0; i < filesToShow.length; i++) {
        final file = filesToShow[i];
        final isImage = file.mimeType?.startsWith('image') ?? false;
        final isAudio = file.mimeType?.startsWith('audio') ?? false;
        final widgetItem = ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: _CloudFileListEntry(
            file: file,
            heroTag: heroTags[i],
            isImage: isImage,
            disableZoomIn: disableZoomIn,
            onTap: () {
              if (!isImage) {
                return;
              }
              if (!disableZoomIn) {
                context.pushTransparentRoute(
                  CloudFileZoomIn(item: file, heroTag: heroTags[i]),
                  rootNavigator: true,
                );
              }
            },
          ),
        );

        Widget item;
        if (isAudio) {
          item = SizedBox(height: 120, child: widgetItem);
        } else {
          item = AspectRatio(
            aspectRatio: file.fileMeta?['ratio'] as double? ?? 1.0,
            child: widgetItem,
          );
        }
        children.add(item);
        if (i < filesToShow.length - 1) {
          children.add(const Gap(8));
        }
      }

      if (files.length > maxFiles) {
        children.add(const Gap(8));
        children.add(
          Text(
            'filesListAdditional'.plural(files.length - filesToShow.length),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
      }

      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }
    if (files.length == 1) {
      final isImage = files.first.mimeType?.startsWith('image') ?? false;
      final isAudio = files.first.mimeType?.startsWith('audio') ?? false;
      final widgetItem = ClipRRect(
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
      );
      return Container(
        padding: padding,
        constraints: BoxConstraints(
          maxHeight: disableConstraint ? double.infinity : maxHeight,
          minWidth: minWidth ?? 0,
          maxWidth: files.length == 1 ? maxWidth : double.infinity,
        ),
        height: isAudio ? 120 : null,
        child:
            isAudio
                ? widgetItem
                : AspectRatio(
                  aspectRatio: calculateAspectRatio(),
                  child: widgetItem,
                ),
      );
    }

    final allImages =
        !files.any(
          (e) => e.mimeType == null || !e.mimeType!.startsWith('image'),
        );

    if (allImages) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, minWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: CarouselView(
              itemSnapping: true,
              itemExtent: math.min(
                math.min(
                  MediaQuery.of(context).size.width * 0.75,
                  maxWidth * 0.75,
                ),
                640,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
              ),
              children: [
                for (var i = 0; i < files.length; i++)
                  Stack(
                    children: [
                      _CloudFileListEntry(
                        file: files[i],
                        heroTag: heroTags[i],
                        isImage:
                            files[i].mimeType?.startsWith('image') ?? false,
                        disableZoomIn: disableZoomIn,
                      ),
                      Positioned(
                        bottom: 12,
                        left: 16,
                        child: Text('${i + 1}/${files.length}')
                            .textColor(Colors.white)
                            .textShadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                      ),
                    ],
                  ),
              ],
              onTap: (i) {
                if (!(files[i].mimeType?.startsWith('image') ?? false)) {
                  return;
                }
                if (!disableZoomIn) {
                  context.pushTransparentRoute(
                    CloudFileZoomIn(item: files[i], heroTag: heroTags[i]),
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

    final showOriginal = useState(false);

    Future<void> saveToGallery() async {
      try {
        // Show loading indicator
        showSnackBar('Saving image...');

        // Get the image URL
        final client = ref.watch(apiClientProvider);

        // Create a temporary file to save the image
        final tempDir = await getTemporaryDirectory();
        var extName = extension(item.name).trim();
        if (extName.isEmpty) {
          extName = item.mimeType?.split('/').lastOrNull ?? 'jpeg';
        }
        final filePath = '${tempDir.path}/${item.id}.$extName';

        await client.download(
          '/drive/files/${item.id}',
          filePath,
          queryParameters: {'original': true},
        );
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
          // Save to gallery
          await Gal.putImage(filePath, album: 'Solar Network');
          // Show success message
          showSnackBar('Image saved to gallery');
        } else {
          await FileSaver.instance.saveFile(
            name: item.name.isEmpty ? '${item.id}.$extName' : item.name,
            file: File(filePath),
          );
          showSnackBar('Image saved to $filePath');
        }
      } catch (e) {
        showErrorAlert(e);
      }
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
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('mimeType').tr(),
                              Text(
                                item.mimeType ?? 'unknown'.tr(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 28, child: const VerticalDivider()),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('fileSize').tr(),
                              Text(
                                formatFileSize(item.size),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.hash != null)
                          SizedBox(height: 28, child: const VerticalDivider()),
                        if (item.hash != null)
                          Expanded(
                            child: GestureDetector(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('fileHash').tr(),
                                  Text(
                                    '${item.hash!.substring(0, 6)}...',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              onLongPress: () {
                                Clipboard.setData(
                                  ClipboardData(text: item.hash!),
                                );
                                showSnackBar('File hash copied to clipboard');
                              },
                            ),
                          ),
                      ],
                    ).padding(horizontal: 24, vertical: 16),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Symbols.tag),
                      title: Text('ID').tr(),
                      subtitle: Text(
                        item.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.id));
                          showSnackBar('File ID copied to clipboard');
                        },
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Symbols.file_present),
                      title: Text('Name').tr(),
                      subtitle: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 24),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.name));
                          showSnackBar('File name copied to clipboard');
                        },
                      ),
                    ),
                    if (exifData.isNotEmpty) ...[
                      const Divider(height: 1),
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          title: Text(
                            'exifData'.tr(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...exifData.entries.map(
                                  (entry) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    title:
                                        Text(
                                          entry.key.contains('-')
                                              ? entry.key.split('-').last
                                              : entry.key,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ).bold(),
                                    subtitle: Text(
                                      '${entry.value}'.isNotEmpty
                                          ? '${entry.value}'
                                          : 'N/A',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(text: '${entry.value}'),
                                      );
                                      showSnackBar('Value copied to clipboard');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (item.fileMeta != null && item.fileMeta!.isNotEmpty) ...[
                      const Divider(height: 1),
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          title: Text(
                            'File Metadata',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...item.fileMeta!.entries.map(
                                  (entry) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    title:
                                        Text(
                                          entry.key,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ).bold(),
                                    subtitle: Text(
                                      jsonEncode(entry.value),
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: jsonEncode(entry.value),
                                        ),
                                      );
                                      showSnackBar('Value copied to clipboard');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (item.userMeta != null && item.userMeta!.isNotEmpty) ...[
                      const Divider(height: 1),
                      Theme(
                        data: theme.copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                          ),
                          title: Text(
                            'User Metadata',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...item.userMeta!.entries.map(
                                  (entry) => ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                    ),
                                    title:
                                        Text(
                                          entry.key,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ).bold(),
                                    subtitle: Text(
                                      jsonEncode(entry.value),
                                      style: theme.textTheme.bodyMedium,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: jsonEncode(entry.value),
                                        ),
                                      );
                                      showSnackBar('Value copied to clipboard');
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
      );
    }

    final shadow = [
      Shadow(color: Colors.black54, blurRadius: 5.0, offset: Offset(1.0, 1.0)),
    ];

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
                original: showOriginal.value,
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
                    if (!kIsWeb)
                      IconButton(
                        icon: Icon(
                          Icons.save_alt,
                          color: Colors.white,
                          shadows: shadow,
                        ),
                        onPressed: () async {
                          saveToGallery();
                        },
                      ),
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
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, shadows: shadow),
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
                    shadows: shadow,
                  ),
                  onPressed: showInfoSheet,
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.remove,
                    color: Colors.white,
                    shadows: shadow,
                  ),
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

class _CloudFileListEntry extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final showMature = useState(false);

    var content = Stack(
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

    if (file.sensitiveMarks.isNotEmpty) {
      // Show a blurred overlay only when not revealed yet, with a smooth transition
      content = Stack(
        children: [
          content,
          // Toggle blur overlay with animation
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              layoutBuilder:
                  (currentChild, previousChildren) => Stack(
                    fit: StackFit.expand,
                    children: [
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  ),
              child:
                  showMature.value
                      ? const SizedBox.shrink(key: ValueKey('revealed'))
                      : ColoredBox(
                        key: const ValueKey('blurred'),
                        color: Colors.transparent,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const ColoredBox(color: Colors.transparent),
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.all(12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 280,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.warning,
                                          color: Colors.white,
                                          fill: 1,
                                          size: 24,
                                        ),
                                        const Gap(4),
                                        Text(
                                          file.sensitiveMarks
                                              .map(
                                                (e) =>
                                                    SensitiveCategory
                                                        .values[e]
                                                        .i18nKey
                                                        .tr(),
                                              )
                                              .join(' · '),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'Sensitive Content',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Gap(4),
                                        Text(
                                          'Tap to Reveal',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).padding(horizontal: 24, vertical: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
            ),
          ),
          // When revealed (no blur), show a small control at top-left to re-enable blur
          if (showMature.value)
            Positioned(
              top: 3,
              left: 4,
              child: IconButton(
                iconSize: 16,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.visibility_off, color: Colors.white),
                tooltip: 'Blur content',
                onPressed: () {
                  showMature.value = false;
                },
              ),
            ),
        ],
      );
    }

    if (onTap != null) {
      return InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: () {
          if (!showMature.value) {
            showMature.value = true;
          } else {
            onTap?.call();
          }
        },
        child: content,
      );
    }

    return content;
  }
}
