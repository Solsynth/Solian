import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/file.dart';
import 'package:island/pods/config.dart';
import 'package:island/services/file_download.dart';
import 'package:island/widgets/content/file_action_button.dart';
import 'package:island/widgets/content/file_info_sheet.dart';
import 'package:island/widgets/content/image_control_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
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

    void saveToGallery() {
      FileDownloadService(ref).saveToGallery(item);
    }

    void showInfoSheet() {
      showModalBottomSheet(
        useRootNavigator: true,
        context: context,
        isScrollControlled: true,
        builder: (context) => FileInfoSheet(item: item),
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
                file: item,
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
                      FileActionButton.save(
                        onPressed: saveToGallery,
                        shadows: WhiteShadows.standard,
                      ),
                    IconButton(
                      onPressed: () {
                        showOriginal.value = !showOriginal.value;
                      },
                      icon: Icon(
                        showOriginal.value ? Symbols.hd : Symbols.sd,
                        color: Colors.white,
                        shadows: WhiteShadows.standard,
                      ),
                    ),
                  ],
                ),
                FileActionButton.close(
                  onPressed: () => Navigator.of(context).pop(),
                  shadows: WhiteShadows.standard,
                ),
              ],
            ),
          ),
          ImageControlOverlay(
            photoViewController: photoViewController,
            rotation: rotation,
            showOriginal: showOriginal.value,
            onToggleQuality: () {
              showOriginal.value = !showOriginal.value;
            },
            extraButtons: [
              FileActionButton.info(
                onPressed: showInfoSheet,
                shadows: WhiteShadows.standard,
              ),
              if (item.url != null)
                FileActionButton.more(
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
                  shadows: WhiteShadows.standard,
                ),
            ],
            showExtraOnLeft: true,
          ),
        ],
      ),
    );
  }
}
