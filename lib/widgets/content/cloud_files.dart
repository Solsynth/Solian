import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

class ProfilePictureWidget extends ConsumerWidget {
  final SnCloudFile? item;
  final double radius;
  const ProfilePictureWidget({super.key, required this.item, this.radius = 24});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (item == null) return const SizedBox.shrink();
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: Container(
        width: radius * 2,
        height: radius * 2,
        color: Theme.of(context).colorScheme.primaryContainer,
        child:
            item == null
                ? Icon(LucideIcons.userCircle)
                : CloudFileWidget(item: item!),
      ),
    );
  }
}
