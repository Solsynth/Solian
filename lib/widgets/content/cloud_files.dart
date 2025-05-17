import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

import 'image.dart';
import 'video.dart';

class CloudFileWidget extends ConsumerWidget {
  final SnCloudFile item;
  final BoxFit fit;
  const CloudFileWidget({
    super.key,
    required this.item,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/files/${item.id}';
    switch (item.mimeType?.split('/').firstOrNull) {
      case "image":
        return AspectRatio(
          aspectRatio: (item.fileMeta?['ratio'] ?? 1).toDouble(),
          child: UniversalImage(uri: uri, blurHash: item.fileMeta?['blur']),
        );
      case "video":
        return AspectRatio(
          aspectRatio: (item.fileMeta?['ratio'] ?? 16 / 9).toDouble(),
          child: UniversalVideo(
            uri: uri,
            aspectRatio: (item.fileMeta?['ratio'] ?? 16 / 9).toDouble(),
          ),
        );
      default:
        return Text('Unable render for ${item.mimeType}');
    }
  }
}

class CloudImageWidget extends ConsumerWidget {
  final String fileId;
  final BoxFit fit;
  final double aspectRatio;
  final String? blurHash;
  const CloudImageWidget({
    super.key,
    required this.fileId,
    this.aspectRatio = 1,
    this.fit = BoxFit.cover,
    this.blurHash,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/files/$fileId';
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: UniversalImage(uri: uri, blurHash: blurHash),
    );
  }

  static ImageProvider provider({
    required String fileId,
    required String serverUrl,
  }) {
    final uri = '$serverUrl/files/$fileId';
    return CachedNetworkImageProvider(uri);
  }
}

class ProfilePictureWidget extends ConsumerWidget {
  final String? fileId;
  final double radius;
  final IconData? fallbackIcon;
  final Color? fallbackColor;
  const ProfilePictureWidget({
    super.key,
    required this.fileId,
    this.radius = 20,
    this.fallbackIcon,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = '$serverUrl/files/$fileId';

    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: Theme.of(context).colorScheme.primaryContainer,
        child:
            fileId == null
                ? Icon(
                  fallbackIcon ?? Symbols.account_circle,
                  size: radius,
                  color:
                      fallbackColor ??
                      Theme.of(context).colorScheme.onPrimaryContainer,
                ).center()
                : CachedNetworkImage(imageUrl: uri, fit: BoxFit.cover),
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
            else ...[
              Positioned(
                top: 0,
                left: 0,
                child: _buildQuadrant(context, filesId[0], ref, radius),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: _buildQuadrant(context, filesId[1], ref, radius),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: _buildQuadrant(context, filesId[2], ref, radius),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child:
                    filesId.length > 4
                        ? Container(
                          width: radius,
                          height: radius,
                          color: Theme.of(context).colorScheme.primaryContainer,
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
                        : _buildQuadrant(context, filesId[3], ref, radius),
              ),
            ],
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
    final uri = '$serverUrl/files/$fileId';

    return SizedBox(
      width: radius,
      height: radius,
      child: CachedNetworkImage(imageUrl: uri, fit: BoxFit.cover),
    );
  }
}
