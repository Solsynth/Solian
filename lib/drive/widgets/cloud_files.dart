import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/widgets/content/file_viewer_contents.dart';
import 'package:island/core/config.dart';
import 'package:island/core/services/time.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/content/image.dart';
import 'package:island/core/widgets/content/profile_decoration.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:island/core/data_saving_gate.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CloudFileWidget extends HookConsumerWidget {
  final IDisplayableCloudFile item;
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
      appSettingsProvider.select((s) => s.dataSavingMode),
    );
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = item.storageUrl ?? '$serverUrl/drive/files/${item.id}';

    final unlocked = useState(false);

    final meta = item.fileMeta as Map;
    final rawE2eeMeta = meta['e2ee'];
    final e2eeMeta = rawE2eeMeta is Map ? Map<String, dynamic>.from(rawE2eeMeta) : <String, dynamic>{};
    final isEncrypted = e2eeMeta['scheme']?.toString().isNotEmpty == true;
    final e2eeScheme = e2eeMeta['scheme']?.toString();
    final blurHash = noBlurhash ? null : (meta['blur'] as String?);
    var ratio = meta['ratio'] is num ? (meta['ratio'] as num).toDouble() : 1.0;
    if (ratio == 0) ratio = 1.0;

Widget cloudImage() =>
        UniversalImage(uri: uri, blurHash: blurHash, fit: fit);
    Widget cloudVideo() {
      if (item is SnCloudFile) {
        return CloudVideoWidget(item: item as SnCloudFile);
      }
      return const SizedBox();
    }

    Widget dataPlaceHolder(IconData icon) => _DataSavingPlaceholder(
          icon: icon,
          onTap: () {
            unlocked.value = true;
          },
        );

    if (isEncrypted) {
      if (item is SnCloudFile) {
        return _EncryptedFileCard(item: item as SnCloudFile, scheme: e2eeScheme);
      }
      return const SizedBox();
    }

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
                          context.router.push(FileDetailRoute(item: item as SnCloudFile));
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
          if (item is SnCloudFile) {
            return AudioFileContent(item: item as SnCloudFile, uri: uri);
          }
          return const SizedBox();
        }(),
      _ => Builder(
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(16),
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
                      onPressed: () {
                        if (item is SnCloudFile) {
                          context.router.push(FileDetailRoute(item: item as SnCloudFile));
                        }
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

class _EncryptedFileCard extends ConsumerWidget {
  final SnCloudFile item;
  final String? scheme;
  const _EncryptedFileCard({required this.item, required this.scheme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = (scheme != null && scheme!.isNotEmpty)
        ? 'Encrypted file ($scheme)'
        : 'Encrypted file';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.lock,
            size: 42,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(8),
          Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          Text(
            formatFileSize(item.size),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () => ref
                    .read(driveFileDownloaderProvider)
                    .downloadWithProgress(item),
                icon: const Icon(Symbols.download),
                label: Text('download').tr(),
              ),
              TextButton.icon(
                onPressed: () {
                  context.router.push(FileDetailRoute(item: item));
                },
                icon: const Icon(Symbols.info),
                label: Text('info').tr(),
              ),
            ],
          ),
        ],
      ).padding(all: 12),
    );
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
    if (DriveE2eeFileEnvelope.isEncryptedFile(item)) {
      return _EncryptedFileCard(
        item: item,
        scheme: ((item.fileMeta as Map)['e2ee'] is Map)
            ? ((item.fileMeta as Map)['e2ee'] as Map)['scheme']?.toString()
            : null,
      );
    }

    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/drive/files/${item.id}';

    var ratio = item.fileMeta['ratio'] is num
        ? item.fileMeta['ratio'].toDouble()
        : 1.0;
    if (ratio == 0) ratio = 1.0;

    return GestureDetector(
      child: Stack(
        fit: StackFit.expand,
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
                    if (item.fileMeta['duration'] != null)
                      Text(
                        Duration(
                          milliseconds:
                              ((item.fileMeta['duration'] as num) * 1000)
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
                    if (item.fileMeta['bit_rate'] != null)
                      Text(
                        '${int.parse(item.fileMeta['bit_rate'] as String) ~/ 1000} Kbps',
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
        context.router.push(FileDetailRoute(item: item));
      },
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
  const CloudImageWidget({
    super.key,
    this.fileId,
    this.file,
    this.aspectRatio = 1,
    this.fit = BoxFit.cover,
    this.blurHash,
    this.noBlurhash = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri =
        file?.storageUrl ?? '$serverUrl/drive/files/${file?.id ?? fileId}';

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: file != null
          ? CloudFileWidget(item: file!, fit: fit, noBlurhash: noBlurhash)
          : UniversalImage(
              uri: uri,
              blurHash: noBlurhash ? null : blurHash,
              fit: fit,
            ),
    );
  }

  static ImageProvider provider({
    required IDisplayableCloudFile file,
    required String serverUrl,
    bool original = false,
  }) {
    final uri =
        file.storageUrl ??
        (original
            ? '$serverUrl/drive/files/${file.id}?original=true'
            : '$serverUrl/drive/files/${file.id}');
    return CachedNetworkImageProvider(uri);
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

    final meta = file?.fileMeta is Map ? (file!.fileMeta as Map) : const {};
    final blurHash = meta['blur'] as String?;

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
      child: UniversalImage(uri: uri, fit: BoxFit.cover),
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
