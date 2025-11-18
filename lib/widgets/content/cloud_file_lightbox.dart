import 'dart:io';
import 'dart:math' as math;

import 'package:dismissible_page/dismissible_page.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/content/file_info_sheet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart' show extension;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';

import 'cloud_files.dart';

class CloudFileLightbox extends HookConsumerWidget {
  final SnCloudFile item;
  final String heroTag;
  const CloudFileLightbox({
    super.key,
    required this.item,
    required this.heroTag,
  });

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

    void showInfoSheet() {
      showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        builder: (context) => FileInfoSheet(item: item),
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
                IconButton(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop(context);
                    Future(() {
                      router.pushNamed(
                        'fileDetail',
                        pathParameters: {'id': item.id},
                        extra: item,
                      );
                    });
                  },
                  icon: Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    shadows: shadow,
                  ),
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
