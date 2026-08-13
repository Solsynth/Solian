import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/widgets/content/file_viewer_contents.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/content/audio.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/core/widgets/content/profile_decoration.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:island/core/data_saving_gate.dart';
import 'package:island/core/network.dart';
import 'package:island/core/utils/file_icon_utils.dart';
import 'package:island/drive/widgets/file_list_view.dart' show FileListViewMode;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:solar_network_foundation/solar_network_foundation.dart';

final folderChildrenProvider = FutureProvider.family<List<SnCloudFile>, String>(
  (ref, parentId) async {
    final driveApi = ref.read(solarNetworkClientProvider).drive;
    final result = await driveApi.listFolderChildren(parentId);
    return result.items;
  },
);

Widget _buildCloudImageLoadingIndicator(BuildContext _, double? progress) =>
    _CloudImageLoadingIndicator(progress: progress);

Widget _buildCloudAvatarLoadingIndicator(BuildContext _, double? progress) =>
    _CloudAvatarLoadingIndicator(progress: progress);

class CloudFileWidget extends HookConsumerWidget {
  final IDisplayableCloudFile item;
  final BoxFit fit;
  final String? heroTag;
  final bool noBlurhash;
  final bool useInternalGate;
  final SnPost? sourcePost;
  final String? workspaceId;
  const CloudFileWidget({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
    this.heroTag,
    this.noBlurhash = false,
    this.useInternalGate = true,
    this.sourcePost,
    this.workspaceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSaving = ref.watch(
      appSettingsProvider.select((s) => s.dataSavingMode),
    );
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = cloudFileUrl(
      serverUrl: serverUrl,
      id: item.id,
      storageUrl: item.storageUrl,
      workspaceId: workspaceId,
    );

    final unlocked = useState(false);

    final blurHash = noBlurhash ? null : item.blurhash;
    var ratio = item.ratio ?? 1.0;
    if (ratio == 0) ratio = 1.0;

    Widget cloudImage() => UniversalImage(
      uri: uri,
      blurHash: blurHash,
      fit: fit,
      loadingIndicatorBuilder: _buildCloudImageLoadingIndicator,
    );
    Widget cloudVideo() => CloudVideoWidget(
      item: item,
      sourcePost: sourcePost,
      workspaceId: workspaceId,
    );

    Widget cloudAudio() => UniversalAudio(uri: uri, filename: item.name);

    Widget dataPlaceHolder(IconData icon) => _DataSavingPlaceholder(
      icon: icon,
      onTap: () {
        unlocked.value = true;
      },
    );

    if (item.mimeType.startsWith('text/') == true) {
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
                        if (item is SnCloudFile) {
                          context.router.push(FileDetailRoute(id: item.id));
                        }
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

    final isFolderItem = item.isFolder;

    var content = switch (item.mimeType.split('/').firstOrNull) {
      'image' => AspectRatio(
        aspectRatio: ratio,
        child: (useInternalGate && dataSaving && !unlocked.value)
            ? dataPlaceHolder(Symbols.image)
            : cloudImage(),
      ),
      'video' => AspectRatio(
        aspectRatio: ratio,
        child: (useInternalGate && dataSaving && !unlocked.value)
            ? dataPlaceHolder(Symbols.play_arrow)
            : cloudVideo(),
      ),
      'audio' => () {
        if (useInternalGate && dataSaving && !unlocked.value) {
          return dataPlaceHolder(Symbols.audio_file);
        }
        return cloudAudio();
      }(),
      _ => () {
        if (useInternalGate && dataSaving && !unlocked.value) {
          return dataPlaceHolder(
            isFolderItem ? Symbols.folder : Symbols.insert_drive_file,
          );
        }

        final icon = isFolderItem ? Symbols.folder : Symbols.insert_drive_file;
        final subtitle = isFolderItem
            ? Text('folder'.tr(), style: Theme.of(context).textTheme.bodySmall)
            : Text(
                formatFileSize(item.size),
                style: Theme.of(context).textTheme.bodySmall,
              );

        Widget card = Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isFolderItem
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.primary,
                ),
              ).center(),
              const Gap(16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle,
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.info),
                onPressed: () {
                  if (item is SnCloudFile) {
                    context.router.push(FileDetailRoute(id: item.id));
                  }
                },
              ),
            ],
          ).padding(horizontal: 16, vertical: 12),
        );

        return card;
      }(),
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

class _CloudImageLoadingIndicator extends StatelessWidget {
  final double? progress;

  const _CloudImageLoadingIndicator({this.progress});

  @override
  Widget build(BuildContext context) {
    final target = (progress ?? 0).clamp(0.0, 1.0).toDouble();

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.black.withOpacity(0.35)),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: const Duration(milliseconds: 80),
            curve: Curves.linear,
            builder: (context, value, child) => Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                widthFactor: 1,
                heightFactor: value,
                child: child,
              ),
            ),
            child: ColoredBox(color: Colors.white.withOpacity(0.78)),
          ),
        ],
      ),
    );
  }
}

class _CloudAvatarLoadingIndicator extends StatelessWidget {
  final double? progress;

  const _CloudAvatarLoadingIndicator({this.progress});

  @override
  Widget build(BuildContext context) {
    final target = (progress ?? 0).clamp(0.0, 1.0).toDouble();

    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: Colors.black.withOpacity(0.35)),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: target),
            duration: const Duration(milliseconds: 80),
            curve: Curves.linear,
            builder: (context, value, child) => Align(
              alignment: Alignment.center,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: value,
                child: child,
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.78),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Layout density for [CloudVideoWidget] overlays based on available space.
enum _VideoOverlayDensity {
  /// Thumbnail / multi-attachment cell: play only.
  compact,

  /// Small card: play + duration chip.
  medium,

  /// Full preview: meta + filename.
  full,
}

class CloudVideoWidget extends HookConsumerWidget {
  final IDisplayableCloudFile item;
  final SnPost? sourcePost;
  final String? workspaceId;
  const CloudVideoWidget({
    super.key,
    required this.item,
    this.sourcePost,
    this.workspaceId,
  });

  /// Below this min side: hide all text overlays (play icon only).
  static const double _compactMaxSide = 120;

  /// Below this height: hide filename & secondary meta; keep duration.
  static const double _mediumMaxHeight = 180;

  /// Below this width: drop bitrate / resolution even in medium+.
  static const double _narrowMaxWidth = 200;

  Duration? _parseDuration(Map<String, dynamic> formatMeta) {
    final rawDuration = formatMeta['duration'];
    final seconds = rawDuration is num
        ? rawDuration.toDouble()
        : double.tryParse(rawDuration?.toString() ?? '');
    if (seconds == null || seconds <= 0) return null;
    return Duration(milliseconds: (seconds * 1000).round());
  }

  String? _formatBitrate(Map<String, dynamic> formatMeta) {
    final rawBitrate = formatMeta['bit_rate'];
    final bitrate = rawBitrate is num
        ? rawBitrate.toInt()
        : int.tryParse(rawBitrate?.toString() ?? '');
    if (bitrate == null || bitrate <= 0) return null;
    return '${(bitrate / 1000).round()} Kbps';
  }

  String? _formatResolution(Map<String, dynamic> rootMeta) {
    final width = rootMeta['width'];
    final height = rootMeta['height'];
    final parsedWidth = width is num
        ? width.toInt()
        : int.tryParse(width?.toString() ?? '');
    final parsedHeight = height is num
        ? height.toInt()
        : int.tryParse(height?.toString() ?? '');
    if (parsedWidth == null ||
        parsedHeight == null ||
        parsedWidth <= 0 ||
        parsedHeight <= 0) {
      return null;
    }
    return '$parsedWidth×$parsedHeight';
  }

  _VideoOverlayDensity _densityFor(BoxConstraints constraints) {
    final maxW = constraints.maxWidth;
    final maxH = constraints.maxHeight;
    final minSide = math.min(
      maxW.isFinite ? maxW : double.infinity,
      maxH.isFinite ? maxH : double.infinity,
    );

    if (!minSide.isFinite || minSide <= _compactMaxSide) {
      return _VideoOverlayDensity.compact;
    }
    if (!maxH.isFinite || maxH <= _mediumMaxHeight) {
      return _VideoOverlayDensity.medium;
    }
    return _VideoOverlayDensity.full;
  }

  TextStyle _videoMetaStyle({double fontSize = 14}) => TextStyle(
    color: Colors.white,
    fontSize: fontSize,
    shadows: const [
      BoxShadow(
        color: Colors.black54,
        offset: Offset(1, 1),
        spreadRadius: 8,
        blurRadius: 8,
      ),
    ],
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = cloudFileUrl(
      serverUrl: serverUrl,
      id: item.id,
      storageUrl: item.storageUrl,
      workspaceId: workspaceId,
    );
    final rootMeta = Map<String, dynamic>.from(item.fileMeta as Map? ?? {});
    final mediaMeta = rootMeta['media'] is Map
        ? Map<String, dynamic>.from(rootMeta['media'] as Map)
        : <String, dynamic>{};
    final formatMeta = mediaMeta['format'] is Map
        ? Map<String, dynamic>.from(mediaMeta['format'] as Map)
        : <String, dynamic>{};
    final duration = _parseDuration(formatMeta);
    final bitrate = _formatBitrate(formatMeta);
    final resolution = _formatResolution(rootMeta);

    return GestureDetector(
      onTap: () {
        context.router.push(
          FileDetailRoute(id: item.id, sourcePost: sourcePost),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final density = _densityFor(constraints);
          final isNarrow =
              !constraints.maxWidth.isFinite ||
              constraints.maxWidth <= _narrowMaxWidth;
          final playSize = switch (density) {
            _VideoOverlayDensity.compact => 22.0,
            _VideoOverlayDensity.medium => 28.0,
            _VideoOverlayDensity.full => 32.0,
          };
          final showGradient = density != _VideoOverlayDensity.compact;
          final showDuration =
              duration != null && density != _VideoOverlayDensity.compact;
          final showResolution =
              resolution != null &&
              density == _VideoOverlayDensity.full &&
              !isNarrow;
          final showBitrate =
              bitrate != null &&
              density == _VideoOverlayDensity.full &&
              !isNarrow;
          final showFilename = density == _VideoOverlayDensity.full;
          final gradientHeight = switch (density) {
            _VideoOverlayDensity.compact => 0.0,
            _VideoOverlayDensity.medium => 48.0,
            _VideoOverlayDensity.full => 100.0,
          };
          final hPad = density == _VideoOverlayDensity.full ? 16.0 : 8.0;
          final bPad = density == _VideoOverlayDensity.full ? 12.0 : 6.0;
          final metaFontSize = density == _VideoOverlayDensity.medium
              ? 11.0
              : 14.0;

          return Stack(
            fit: StackFit.expand,
            children: [
              if (item.hasThumbnail)
                UniversalImage(
                  uri: '$uri?thumbnail=true',
                  loadingIndicatorBuilder: _buildCloudImageLoadingIndicator,
                )
              else
                ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Symbols.video_file,
                      fill: 1,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Positioned.fill(
                child: Center(
                  child: Icon(
                    Symbols.play_arrow,
                    fill: 1,
                    size: playSize,
                    color: Colors.white,
                    shadows: const [
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
              if (showGradient)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: gradientHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (showDuration || showResolution || showBitrate || showFilename)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showDuration || showResolution || showBitrate)
                        Wrap(
                          spacing: 8,
                          runSpacing: 2,
                          children: [
                            if (showResolution)
                              Text(
                                resolution,
                                style: _videoMetaStyle(fontSize: metaFontSize),
                              ),
                            if (showDuration)
                              Text(
                                duration.formatDuration(),
                                style: _videoMetaStyle(fontSize: metaFontSize),
                              ),
                            if (showBitrate)
                              Text(
                                bitrate,
                                style: _videoMetaStyle(fontSize: metaFontSize),
                              ),
                          ],
                        ),
                      if (showFilename)
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: metaFontSize,
                            shadows: const [
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
                  ).padding(horizontal: hPad, bottom: bPad),
                ),
            ],
          );
        },
      ),
    );
  }
}

class CloudImageWidget extends ConsumerWidget {
  final String? fileId;
  final IDisplayableCloudFile? file;
  final BoxFit fit;
  final double aspectRatio;
  final String? blurHash;
  final bool noBlurhash;
  final String? workspaceId;

  /// Always render as an image via [UniversalImage], even when a [file] is
  /// provided. Prevents non-image files (video, audio, text, ...) from being
  /// rendered as their own widget instead of a picture.
  final bool imageOnly;
  const CloudImageWidget({
    super.key,
    this.fileId,
    this.file,
    this.aspectRatio = 1,
    this.fit = BoxFit.cover,
    this.blurHash,
    this.noBlurhash = false,
    this.workspaceId,
    this.imageOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = cloudFileUrl(
      serverUrl: serverUrl,
      id: file?.id ?? fileId ?? '',
      storageUrl: file?.storageUrl,
      workspaceId: workspaceId,
    );

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: file != null && !imageOnly
          ? CloudFileWidget(
              item: file!,
              fit: fit,
              noBlurhash: noBlurhash,
              workspaceId: workspaceId,
            )
          : UniversalImage(
              uri: uri,
              blurHash: noBlurhash ? null : (file?.blurhash ?? blurHash),
              fit: fit,
              loadingIndicatorBuilder: _buildCloudImageLoadingIndicator,
            ),
    );
  }

  static ImageProvider provider({
    required IDisplayableCloudFile file,
    required String serverUrl,
    bool original = false,
    String? workspaceId,
  }) {
    return cloudFileImageProvider(
      serverUrl: serverUrl,
      id: file.id,
      storageUrl: file.storageUrl,
      original: original,
      workspaceId: workspaceId,
    );
  }
}

class ProfilePictureWidget extends ConsumerWidget {
  final String? fileId;
  final IDisplayableCloudFile? file;
  final double radius;
  final double? borderRadius;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  final ProfileDecoration? decoration;
  const ProfilePictureWidget({
    super.key,
    this.fileId,
    this.file,
    this.radius = 20,
    this.borderRadius,
    this.fallbackIcon,
    this.fallbackColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final String? id = file?.id ?? fileId;

    final blurHash = file?.blurhash;

    final fallback = Icon(
      fallbackIcon ?? Symbols.account_circle,
      size: radius,
      color: fallbackColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
    ).center();

    final image = id == null
        ? fallback
        : DataSavingGate(
            bypass: true,
            placeholder: fallback,
            content: () => UniversalImage(
              uri: '$serverUrl/drive/files/$id',
              blurHash: blurHash,
              fit: BoxFit.cover,
              loadingIndicatorBuilder: _buildCloudAvatarLoadingIndicator,
            ),
          );

    Widget content = Container(
      width: radius * 2,
      height: radius * 2,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: decoration != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                image,
                CustomPaint(
                  painter: _ProfileDecorationPainter(
                    text: decoration!.text,
                    color: decoration!.color,
                    textColor: decoration!.textColor ?? Colors.white,
                  ),
                ),
              ],
            )
          : image,
    );

    return ClipRRect(
      borderRadius: borderRadius == null
          ? BorderRadius.all(Radius.circular(radius))
          : BorderRadius.all(Radius.circular(borderRadius!)),
      child: content,
    );
  }
}

class SplitAvatarWidget extends ConsumerWidget {
  final List<IDisplayableCloudFile?> files;
  final double radius;
  final IconData fallbackIcon;
  final Color? fallbackColor;

  const SplitAvatarWidget({
    super.key,
    required this.files,
    this.radius = 20,
    this.fallbackIcon = Symbols.account_circle,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (files.isEmpty) {
      return ProfilePictureWidget(
        file: null,
        radius: radius,
        fallbackIcon: fallbackIcon,
        fallbackColor: fallbackColor,
      );
    }
    if (files.length == 1) {
      return ProfilePictureWidget(
        file: files[0],
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
            if (files.length == 2)
              Row(
                children: [
                  Expanded(
                    child: _buildQuadrant(context, files[0], ref, radius),
                  ),
                  Expanded(
                    child: _buildQuadrant(context, files[1], ref, radius),
                  ),
                ],
              )
            else if (files.length == 3)
              Row(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: _buildQuadrant(context, files[0], ref, radius),
                      ),
                      Expanded(
                        child: _buildQuadrant(context, files[1], ref, radius),
                      ),
                    ],
                  ),
                  Expanded(
                    child: _buildQuadrant(context, files[2], ref, radius),
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
                          child: _buildQuadrant(context, files[0], ref, radius),
                        ),
                        Expanded(
                          child: _buildQuadrant(context, files[1], ref, radius),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuadrant(context, files[2], ref, radius),
                        ),
                        Expanded(
                          child: files.length > 4
                              ? Container(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Center(
                                    child: Text(
                                      '+${files.length - 3}',
                                      style: TextStyle(
                                        fontSize: radius * 0.4,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                )
                              : _buildQuadrant(context, files[3], ref, radius),
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
    IDisplayableCloudFile? file,
    WidgetRef ref,
    double radius,
  ) {
    if (file == null) {
      return Container(
        width: radius,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          fallbackIcon,
          size: radius * 0.6,
          color:
              fallbackColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
        ).center(),
      );
    }

    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/${file.id}';

    return SizedBox(
      width: radius,
      child: UniversalImage(
        uri: uri,
        fit: BoxFit.cover,
        loadingIndicatorBuilder: _buildCloudAvatarLoadingIndicator,
      ),
    );
  }
}

class CloudFileTile extends ConsumerWidget {
  final SnCloudFile file;
  final VoidCallback onTap;
  final bool isWaterfall;

  const CloudFileTile({
    super.key,
    required this.file,
    required this.onTap,
    this.isWaterfall = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isWaterfall) {
      return _buildWaterfall(context, ref);
    }
    return _buildList(context);
  }

  Widget _buildList(BuildContext context) {
    final theme = Theme.of(context);
    if (file.isFolder) {
      return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
          leading: SizedBox(
            width: 40,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Symbols.folder,
                fill: 1,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          title: Text(
            file.name.isEmpty ? 'untitled'.tr() : file.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              const Icon(Symbols.folder, size: 12),
              Text(
                file.childrenCount > 0
                    ? file.childrenCount.toString()
                    : 'folder'.tr(),
                style: theme.textTheme.bodySmall?.copyWith(height: 1),
              ),
            ],
          ).opacity(0.85).padding(top: 2, bottom: 4),
        ),
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: SizedBox(
          width: 40,
          height: 40,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: getFileIcon(file, size: 22),
          ),
        ),
        title: Text(
          file.name.isEmpty ? 'untitled'.tr() : file.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 6,
          children: [
            const Icon(Symbols.insert_drive_file, size: 12),
            Text(
              formatFileSize(file.size),
              style: theme.textTheme.bodySmall?.copyWith(height: 1),
            ),
          ],
        ).opacity(0.85).padding(top: 2, bottom: 4),
      ),
    );
  }

  Widget _buildWaterfall(BuildContext context, WidgetRef ref) {
    if (file.isFolder) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Symbols.folder,
                fill: 1,
                size: 24,
                color: Theme.of(context).colorScheme.primaryFixedDim,
              ),
              const Gap(16),
              Text(
                file.name.isEmpty ? 'untitled'.tr() : file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    final ratio = file.ratio ?? 1.0;
    final itemType = file.mimeType.split('/').first;

    Widget previewWidget;
    switch (itemType) {
      case 'image':
        previewWidget = CloudImageWidget(
          file: file,
          aspectRatio: ratio,
          fit: BoxFit.cover,
        );
        break;
      case 'video':
        previewWidget = CloudVideoWidget(item: file);
        break;
      default:
        previewWidget = getFileIcon(file, size: 48);
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: AspectRatio(
                aspectRatio: ratio,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: previewWidget,
                ),
              ),
            ),
            Row(
              children: [
                getFileIcon(file, size: 22, tinyPreview: false),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      file.name.isEmpty
                          ? Text('untitled').tr().italic()
                          : Text(
                              file.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      Text(
                        formatFileSize(file.size),
                        maxLines: 1,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall!.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ).padding(horizontal: 10, vertical: 6),
          ],
        ),
      ),
    );
  }
}

class FolderContentsSheet extends HookConsumerWidget {
  final String folderId;
  final String folderName;

  const FolderContentsSheet({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderPath = useState<List<({String name, String id})>>([
      (name: folderName, id: folderId),
    ]);
    final currentFolderId = folderPath.value.last.id;
    final children = ref.watch(folderChildrenProvider(currentFolderId));
    final viewMode = useState<FileListViewMode>(FileListViewMode.list);

    return SheetScaffold(
      titleText: folderPath.value.last.name,
      actions: [
        SegmentedButton<FileListViewMode>(
          segments: [
            ButtonSegment<FileListViewMode>(
              value: FileListViewMode.list,
              icon: const Icon(Symbols.list),
              tooltip: 'listView'.tr(),
            ),
            ButtonSegment<FileListViewMode>(
              value: FileListViewMode.waterfall,
              icon: const Icon(Symbols.view_module),
              tooltip: 'waterfallView'.tr(),
            ),
          ],
          selected: {viewMode.value},
          onSelectionChanged: (Set<FileListViewMode> newSelection) {
            viewMode.value = newSelection.first;
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
      child: Column(
        children: [
          if (folderPath.value.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: folderPath.value.length,
                  separatorBuilder: (_, _) =>
                      const Icon(Symbols.chevron_right, size: 18),
                  itemBuilder: (context, index) {
                    final entry = folderPath.value[index];
                    final isLast = index == folderPath.value.length - 1;
                    return TextButton(
                      onPressed: isLast
                          ? null
                          : () {
                              folderPath.value = folderPath.value.sublist(
                                0,
                                index + 1,
                              );
                            },
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(entry.name),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: children.when(
              data: (items) => items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.folder_open,
                            size: 48,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const Gap(12),
                          Text(
                            'folder'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    )
                  : viewMode.value == FileListViewMode.list
                  ? ListView.builder(
                      itemCount: items.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final file = items[index];
                        return CloudFileTile(
                          file: file,
                          onTap: file.isFolder
                              ? () {
                                  folderPath.value = [
                                    ...folderPath.value,
                                    (name: file.name, id: file.id),
                                  ];
                                }
                              : () => context.router.push(
                                  FileDetailRoute(id: file.id),
                                ),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(12),
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final file = items[index];
                          return CloudFileTile(
                            file: file,
                            isWaterfall: true,
                            onTap: file.isFolder
                                ? () {
                                    folderPath.value = [
                                      ...folderPath.value,
                                      (name: file.name, id: file.id),
                                    ];
                                  }
                                : () => context.router.push(
                                    FileDetailRoute(id: file.id),
                                  ),
                          );
                        },
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDecorationPainter extends CustomPainter {
  final String text;
  final Color color;
  final Color textColor;

  _ProfileDecorationPainter({
    required this.text,
    required this.color,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (text.isEmpty) return;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    final strokeWidth = radius * 0.4; // Increased thickness
    final centerAngle = 3 * math.pi / 4;
    final sweepAngle = math.pi / 1;
    final startAngle = centerAngle - (sweepAngle / 2);

    final arcRadius = radius - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: arcRadius);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [color.withOpacity(0), color, color, color.withOpacity(0)],
        stops: const [0.0, 0.25, 0.75, 1.0],
      ).createShader(rect);

    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    _drawTextOnArc(canvas, center, arcRadius, text, centerAngle);
  }

  void _drawTextOnArc(
    Canvas canvas,
    Offset center,
    double radius,
    String text,
    double centerAngle,
  ) {
    final textStyle = TextStyle(
      color: textColor,
      fontSize: radius * 0.28,
      fontWeight: FontWeight.bold,
    );

    double totalAngle = 0;
    List<double> charAngles = [];

    // Calculate total angle occupied by text
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final span = TextSpan(text: char, style: textStyle);
      final tp = TextPainter(text: span, textDirection: ui.TextDirection.ltr);
      tp.layout();
      final charWidth = tp.width;
      final angle = charWidth / radius;
      charAngles.add(angle);
      totalAngle += angle;
    }

    // Start from "Left" of the center (High angle)
    // We want to traverse from centerAngle + total/2 to centerAngle - total/2
    double currentAngle = centerAngle + (totalAngle / 2);

    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final span = TextSpan(text: char, style: textStyle);
      final tp = TextPainter(text: span, textDirection: ui.TextDirection.ltr);
      tp.layout();

      final charAngle = charAngles[i];
      final midCharAngle = currentAngle - charAngle / 2;

      final x = center.dx + radius * math.cos(midCharAngle);
      final y = center.dy + radius * math.sin(midCharAngle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(midCharAngle - math.pi / 2);

      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));

      canvas.restore();

      currentAngle -= charAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
