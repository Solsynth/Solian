import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';

import 'image.dart';
import 'video.dart';

class CloudFileWidget extends ConsumerWidget {
  final SnCloudFile item;
  const CloudFileWidget({super.key, required this.item});

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
          child: UniversalVideo(uri: uri),
        );
      default:
        return Placeholder();
    }
  }
}
