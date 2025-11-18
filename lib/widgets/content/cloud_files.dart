import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/services/time.dart';
import 'package:island/utils/format.dart';
import 'package:island/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show extension;
import 'package:path_provider/path_provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:island/widgets/data_saving_gate.dart';
import 'package:island/widgets/content/file_info_sheet.dart';

import 'file_viewer_contents.dart';
import 'image.dart';
import 'video.dart';

class CloudFileWidget extends HookConsumerWidget {
  final SnCloudFile item;
  final BoxFit fit;
  final String? heroTag;
  final bool noBlurhash;
  final bool useInternalGate;
  const CloudFileWidget({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.heroTag,
    this.noBlurhash = false,
    this.useInternalGate = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSaving = ref.watch(
      appSettingsNotifierProvider.select((s) => s.dataSavingMode),
    );
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/${item.id}';

    final unlocked = useState(false);

    final meta = item.fileMeta is Map ? (item.fileMeta as Map) : const {};
    final blurHash = noBlurhash ? null : (meta['blur'] as String?);
    var ratio = meta['ratio'] is num ? (meta['ratio'] as num).toDouble() : 1.0;
    if (ratio == 0) ratio = 1.0;

    Widget cloudImage() =>
        UniversalImage(uri: uri, blurHash: blurHash, fit: fit);
    Widget cloudVideo() => CloudVideoWidget(item: item);

    Widget dataPlaceHolder(IconData icon) => _DataSavingPlaceholder(
      icon: icon,
      onTap: () {
        unlocked.value = true;
      },
    );

    if (item.mimeType == 'application/pdf') {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            PdfFileContent(uri: uri),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 7,
                  children: [
                    Icon(
                      Symbols.picture_as_pdf,
                      size: 16,
                      color: Colors.white,
                    ).padding(top: 2),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          formatFileSize(item.size),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).padding(vertical: 4, horizontal: 8),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Symbols.more_horiz,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: () {
                        context.pushNamed(
                          'fileDetail',
                          pathParameters: {'id': item.id},
                          extra: item,
                        );
                      },
                      padding: EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (item.mimeType?.startsWith('text/') == true) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 68, 20, 20),
              child: TextFileContent(uri: uri),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 7,
                  children: [
                    Icon(
                      Symbols.file_present,
                      size: 16,
                      color: Colors.white,
                    ).padding(top: 2),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          formatFileSize(item.size),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ).padding(vertical: 4, horizontal: 8),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Symbols.more_horiz,
                        color: Colors.white,
                        size: 16,
                      ),
                      onPressed: () {
                        context.pushNamed(
                          'fileDetail',
                          pathParameters: {'id': item.id},
                          extra: item,
                        );
                      },
                      padding: EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    var content = switch (item.mimeType?.split('/').firstOrNull) {
      'image' => AspectRatio(
        aspectRatio: ratio,
        child:
            (useInternalGate && dataSaving && !unlocked.value)
                ? dataPlaceHolder(Symbols.image)
                : cloudImage(),
      ),
      'video' => AspectRatio(
        aspectRatio: ratio,
        child:
            (useInternalGate && dataSaving && !unlocked.value)
                ? dataPlaceHolder(Symbols.play_arrow)
                : cloudVideo(),
      ),
      'audio' => AudioFileContent(item: item, uri: uri),
      _ => Builder(
        builder: (context) {
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

          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Symbols.insert_drive_file,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const Gap(8),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  formatFileSize(item.size),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      onPressed: downloadFile,
                      icon: const Icon(Symbols.download),
                      label: Text('download').tr(),
                    ),
                    const Gap(8),
                    TextButton.icon(
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
            ).padding(all: 8),
          );
        },
      ),
    };

    if (heroTag != null) {
      content = Hero(tag: heroTag!, child: content);
    }

    return content;
  }
}

class _DataSavingPlaceholder extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DataSavingPlaceholder({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black26,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 36,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const Gap(8),
            Text(
              'dataSavingHint'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class CloudVideoWidget extends HookConsumerWidget {
  final SnCloudFile item;
  const CloudVideoWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = useState(false);

    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/${item.id}';

    var ratio =
        item.fileMeta?['ratio'] is num
            ? item.fileMeta!['ratio'].toDouble()
            : 1.0;
    if (ratio == 0) ratio = 1.0;

    if (open.value) {
      return UniversalVideo(uri: uri, aspectRatio: ratio, autoplay: true);
    }

    return GestureDetector(
      child: Stack(
        children: [
          UniversalImage(uri: '$uri?thumbnail=true'),
          Positioned.fill(
            child: Center(
              child: const Icon(
                Symbols.play_arrow,
                fill: 1,
                size: 32,
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    spreadRadius: 8,
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Theme.of(context).colorScheme.surface.withOpacity(0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    if (item.fileMeta?['duration'] != null)
                      Text(
                        Duration(
                          milliseconds:
                              ((item.fileMeta?['duration'] as num) * 1000)
                                  .toInt(),
                        ).formatDuration(),
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              spreadRadius: 8,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    if (item.fileMeta?['bit_rate'] != null)
                      Text(
                        '${int.parse(item.fileMeta?['bit_rate'] as String) ~/ 1000} Kbps',
                        style: TextStyle(
                          color: Colors.white,
                          shadows: [
                            BoxShadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              spreadRadius: 8,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      BoxShadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        spreadRadius: 8,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ).padding(horizontal: 16, bottom: 12),
          ),
        ],
      ),
      onTap: () {
        open.value = true;
      },
    );
  }
}

class CloudImageWidget extends ConsumerWidget {
  final String? fileId;
  final SnCloudFile? file;
  final BoxFit fit;
  final double aspectRatio;
  final String? blurHash;
  const CloudImageWidget({
    super.key,
    this.fileId,
    this.file,
    this.aspectRatio = 1,
    this.fit = BoxFit.cover,
    this.blurHash,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/${file?.id ?? fileId}';

    return AspectRatio(
      aspectRatio: aspectRatio,
      child:
          file != null
              ? CloudFileWidget(item: file!, fit: fit)
              : UniversalImage(uri: uri, blurHash: blurHash, fit: fit),
    );
  }

  static ImageProvider provider({
    required String fileId,
    required String serverUrl,
    bool original = false,
  }) {
    final uri =
        original
            ? '$serverUrl/drive/files/$fileId?original=true'
            : '$serverUrl/drive/files/$fileId';
    return CachedNetworkImageProvider(uri);
  }
}

class ProfilePictureWidget extends ConsumerWidget {
  final String? fileId;
  final SnCloudFile? file;
  final double radius;
  final double? borderRadius;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  const ProfilePictureWidget({
    super.key,
    this.fileId,
    this.file,
    this.radius = 20,
    this.borderRadius,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final String? id = file?.id ?? fileId;

    final fallback =
        Icon(
          fallbackIcon ?? Symbols.account_circle,
          size: radius,
          color:
              fallbackColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
        ).center();

    return ClipRRect(
      borderRadius:
          borderRadius == null
              ? BorderRadius.all(Radius.circular(radius))
              : BorderRadius.all(Radius.circular(borderRadius!)),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: Theme.of(context).colorScheme.primaryContainer,
        child:
            id == null
                ? fallback
                : DataSavingGate(
                  bypass: true,
                  placeholder: fallback,
                  content:
                      () => UniversalImage(
                        uri: '$serverUrl/drive/files/$id',
                        fit: BoxFit.cover,
                      ),
                ),
      ),
    );
  }
}

class SplitAvatarWidget extends ConsumerWidget {
  final List<String?> filesId;
  final double radius;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const SplitAvatarWidget({
    super.key,
    required this.filesId,
    this.radius = 20,
    this.fallbackIcon = Symbols.account_circle,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (filesId.isEmpty) {
      return ProfilePictureWidget(
        fileId: null,
        radius: radius,
        fallbackIcon: fallbackIcon,
        fallbackColor: fallbackColor,
      );
    }
    if (filesId.length == 1) {
      return ProfilePictureWidget(
        fileId: filesId[0],
        radius: radius,
        fallbackIcon: fallbackIcon,
        fallbackColor: fallbackColor,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Stack(
          children: [
            if (filesId.length == 2)
              Row(
                children: [
                  Expanded(
                    child: _buildQuadrant(context, filesId[0], ref, radius),
                  ),
                  Expanded(
                    child: _buildQuadrant(context, filesId[1], ref, radius),
                  ),
                ],
              )
            else if (filesId.length == 3)
              Row(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: _buildQuadrant(context, filesId[0], ref, radius),
                      ),
                      Expanded(
                        child: _buildQuadrant(context, filesId[1], ref, radius),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _buildQuadrant(context, filesId[2], ref, radius),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuadrant(
                            context,
                            filesId[0],
                            ref,
                            radius,
                          ),
                        ),
                        Expanded(
                          child: _buildQuadrant(
                            context,
                            filesId[1],
                            ref,
                            radius,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuadrant(
                            context,
                            filesId[2],
                            ref,
                            radius,
                          ),
                        ),
                        Expanded(
                          child:
                              filesId.length > 4
                                  ? Container(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                    child: Center(
                                      child: Text(
                                        '+${filesId.length - 3}',
                                        style: TextStyle(
                                          fontSize: radius * 0.4,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  )
                                  : _buildQuadrant(
                                    context,
                                    filesId[3],
                                    ref,
                                    radius,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadrant(
    BuildContext context,
    String? fileId,
    WidgetRef ref,
    double radius,
  ) {
    if (fileId == null) {
      return Container(
        width: radius,
        height: radius,
        color: Theme.of(context).colorScheme.primaryContainer,
        child:
            Icon(
              fallbackIcon,
              size: radius * 0.6,
              color:
                  fallbackColor ??
                  Theme.of(context).colorScheme.onPrimaryContainer,
            ).center(),
      );
    }

    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/$fileId';

    return SizedBox(
      width: radius,
      height: radius,
      child: UniversalImage(uri: uri, fit: BoxFit.cover),
    );
  }
}
