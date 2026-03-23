import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_actions_sheet.dart';
import 'package:island/shared/widgets/content/video.native.dart';
import 'package:island/core/widgets/content/exif_info_overlay.dart';
import 'package:island/core/widgets/content/file_action_button.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CloudFileLightbox extends HookConsumerWidget {
  final List<SnCloudFile> items;
  final int initialIndex;
  final String? heroTag;

  const CloudFileLightbox({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(initialIndex);
    final showControls = useState(true);
    final controlsVisible = useState(true);
    final pageController = useMemoized(
      () => PageController(initialPage: initialIndex),
      [initialIndex],
    );
    final photoViewControllers = useMemoized(
      () => List.generate(items.length, (_) => PhotoViewController()),
      [items.length],
    );
    final rotation = useState(0);
    final showExif = useState(ExifInfoOverlay.precheck(items[initialIndex]));
    final showOriginal = useState(false);
    final focusNode = useFocusNode();

    void goToPage(int index) {
      if (index >= 0 && index < items.length) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void goToPrevious() {
      if (currentIndex.value > 0) {
        goToPage(currentIndex.value - 1);
      }
    }

    void goToNext() {
      if (currentIndex.value < items.length - 1) {
        goToPage(currentIndex.value + 1);
      }
    }

    useEffect(() {
      if (!showControls.value) return null;
      final timer = Timer(const Duration(seconds: 3), () {
        controlsVisible.value = false;
      });
      return timer.cancel;
    }, [showControls.value, controlsVisible.value]);

    void showActionsSheet() async {
      final result = await CloudFileActionsSheet.show(
        context: context,
        item: items[currentIndex.value],
      );

      if (result == null || !context.mounted) return;

      switch (result) {
        case 'save':
          ref
              .read(driveFileDownloaderProvider)
              .saveToGallery(items[currentIndex.value]);
          break;
        case 'toggle_original':
          showOriginal.value = !showOriginal.value;
          break;
        case 'share':
          break;
      }
    }

    PhotoViewController getCurrentController() =>
        photoViewControllers[currentIndex.value];

    Widget buildImageViewer(
      BuildContext context,
      WidgetRef ref,
      SnCloudFile item,
      PhotoViewControllerBase controller,
      bool original,
    ) {
      final serverUrl = ref.watch(serverUrlProvider);
      return _ImageViewerWidget(
        item: item,
        controller: controller,
        original: original,
        serverUrl: serverUrl,
      );
    }

    Widget buildContent() {
      return Positioned.fill(
        child: Stack(
          children: [
            PageView.builder(
              key: ValueKey(items.length),
              controller: pageController,
              itemCount: items.length,
              physics: items.length == 1
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              onPageChanged: (index) {
                currentIndex.value = index;
                rotation.value = 0;
                photoViewControllers[index].rotation = 0;
                showExif.value = ExifInfoOverlay.precheck(items[index]);
              },
              itemBuilder: (context, index) {
                final item = items[index];
                final isHero = heroTag != null && index == initialIndex;

                if (item.mimeType?.startsWith('image') == true) {
                  final image = buildImageViewer(
                    context,
                    ref,
                    item,
                    photoViewControllers[index],
                    showOriginal.value,
                  );
                  return isHero ? Hero(tag: heroTag!, child: image) : image;
                } else if (item.mimeType?.startsWith('video') == true) {
                  return _buildVideoViewer(context, ref, item);
                } else if (item.mimeType?.startsWith('audio') == true) {
                  return _buildAudioViewer(context, ref, item);
                } else if (item.mimeType == 'application/pdf') {
                  return _buildPdfViewer(context, ref, item);
                } else {
                  return _buildGenericViewer(context, ref, item);
                }
              },
            ),
            if (showExif.value && currentIndex.value < items.length)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 90,
                left: 0,
                right: 0,
                child: Center(
                  child: ExifInfoOverlay(item: items[currentIndex.value]),
                ),
              ),
          ],
        ),
      );
    }

    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
            goToPrevious();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
            goToNext();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            Navigator.of(context).pop();
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyI) {
            getCurrentController().scale =
                (getCurrentController().scale ?? 1) + 0.1;
            return KeyEventResult.handled;
          } else if (event.logicalKey == LogicalKeyboardKey.keyO) {
            getCurrentController().scale =
                (getCurrentController().scale ?? 1) - 0.1;
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            buildContent(),
            if (items.length > 1) ...[
              if (currentIndex.value > 0)
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      direction: AxisDirection.left,
                      onPressed: goToPrevious,
                    ),
                  ),
                ),
              if (currentIndex.value < items.length - 1)
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: _ArrowButton(
                      direction: AxisDirection.right,
                      onPressed: goToNext,
                    ),
                  ),
                ),
            ],
            GestureDetector(
              onTap: () {
                showControls.value = !showControls.value;
                controlsVisible.value = true;
              },
              onLongPress: showActionsSheet,
              onSecondaryTap: showActionsSheet,
              behavior: HitTestBehavior.translucent,
              child: AnimatedOpacity(
                opacity: showControls.value && controlsVisible.value
                    ? 1.0
                    : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !showControls.value || !controlsVisible.value,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).padding.top + 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery.of(context).padding.bottom + 80,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      _LightboxTopBar(
                        context: context,
                        items: items,
                        currentIndex: currentIndex.value,
                        onShowActions: showActionsSheet,
                      ),
                      _LightboxBottomBar(
                        context: context,
                        items: items,
                        currentIndex: currentIndex.value,
                        photoViewController: getCurrentController(),
                        rotation: rotation,
                        showOriginal: showOriginal.value,
                        showExif: showExif.value,
                        onToggleOriginal: () {
                          showOriginal.value = !showOriginal.value;
                        },
                        onToggleExif: () {
                          showExif.value = !showExif.value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoViewer(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile item,
  ) {
    final serverUrl = ref.watch(serverUrlProvider);
    final uri = item.url ?? '$serverUrl/drive/files/${item.id}';

    var ratio = 1.0;
    final meta = item.fileMeta is Map ? (item.fileMeta as Map) : const {};
    if (meta['ratio'] is num) {
      ratio = (meta['ratio'] as num).toDouble();
    }
    if (ratio == 0) ratio = 16 / 9;

    return Container(
      color: Colors.black,
      child: Center(
        child: Positioned.fill(
          child: AspectRatio(
            aspectRatio: ratio,
            child: UniversalVideo(uri: uri, aspectRatio: ratio, autoplay: true),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioViewer(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile item,
  ) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.audiotrack, size: 80, color: Colors.white54),
            const Gap(16),
            Text(
              item.name,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.router.push(FileDetailRoute(item: item));
              },
              icon: const Icon(Symbols.play_arrow),
              label: Text('play'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfViewer(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile item,
  ) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.picture_as_pdf, size: 80, color: Colors.white54),
            const Gap(16),
            Text(
              item.name,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.router.push(FileDetailRoute(item: item));
              },
              icon: const Icon(Symbols.open_in_new),
              label: Text('open'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericViewer(
    BuildContext context,
    WidgetRef ref,
    SnCloudFile item,
  ) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.insert_drive_file, size: 80, color: Colors.white54),
            const Gap(16),
            Text(
              item.name,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.router.push(FileDetailRoute(item: item));
              },
              icon: const Icon(Symbols.open_in_new),
              label: Text('open'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final AxisDirection direction;
  final VoidCallback onPressed;

  const _ArrowButton({required this.direction, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isLeft = direction == AxisDirection.left;

    return Material(
      color: Colors.black38,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            isLeft ? Symbols.chevron_left : Symbols.chevron_right,
            color: Colors.white,
            size: 28,
            shadows: WhiteShadows.standard,
          ),
        ),
      ),
    );
  }
}

class _LightboxTopBar extends StatelessWidget {
  final BuildContext context;
  final List<SnCloudFile> items;
  final int currentIndex;
  final VoidCallback onShowActions;

  const _LightboxTopBar({
    required this.context,
    required this.items,
    required this.currentIndex,
    required this.onShowActions,
  });

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    return Positioned(
      top: paddingTop + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (items.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${currentIndex + 1}/${items.length}',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            )
          else
            const SizedBox.shrink(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onShowActions,
                icon: Icon(
                  Symbols.menu,
                  color: Colors.white,
                  shadows: WhiteShadows.standard,
                ),
              ),
              FileActionButton.close(
                onPressed: () => Navigator.of(context).pop(),
                shadows: WhiteShadows.standard,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageViewerWidget extends HookWidget {
  final SnCloudFile item;
  final PhotoViewControllerBase controller;
  final bool original;
  final String serverUrl;

  const _ImageViewerWidget({
    required this.item,
    required this.controller,
    required this.original,
    required this.serverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final loadingProgress = useState<double?>(null);
    final isHighQualityLoaded = useState(!original);

    useEffect(() {
      if (original) {
        isHighQualityLoaded.value = false;
        loadingProgress.value = 0;
        final provider = CloudImageWidget.provider(
          file: item,
          serverUrl: serverUrl,
          original: true,
        );
        final listener = ImageStreamListener(
          (ImageInfo info, bool _) {
            if (info.image.width > 0 && info.image.height > 0) {
              isHighQualityLoaded.value = true;
              loadingProgress.value = null;
            }
          },
          onChunk: (imageChunkEvent) {
            if (imageChunkEvent.expectedTotalBytes != null &&
                imageChunkEvent.expectedTotalBytes! > 0) {
              loadingProgress.value =
                  imageChunkEvent.cumulativeBytesLoaded /
                  imageChunkEvent.expectedTotalBytes!;
            }
          },
        );
        final stream = provider.resolve(const ImageConfiguration());
        stream.addListener(listener);
        return () => stream.removeListener(listener);
      } else {
        isHighQualityLoaded.value = true;
        loadingProgress.value = null;
      }
      return null;
    }, [original, item.id, serverUrl]);

    final currentProvider = CloudImageWidget.provider(
      file: item,
      serverUrl: serverUrl,
      original: original,
    );

    final previousProvider = !original
        ? CloudImageWidget.provider(
            file: item,
            serverUrl: serverUrl,
            original: true,
          )
        : null;

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: PhotoView(
            key: ValueKey('$item-$original'),
            backgroundDecoration: const BoxDecoration(color: Colors.black),
            controller: controller,
            imageProvider: currentProvider,
            customSize: MediaQuery.of(context).size,
            basePosition: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (original && !isHighQualityLoaded.value && previousProvider != null)
          Positioned.fill(
            child: PhotoView(
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              controller: controller,
              imageProvider: previousProvider,
              customSize: MediaQuery.of(context).size,
              basePosition: Alignment.center,
              filterQuality: FilterQuality.medium,
            ),
          ),
        if (loadingProgress.value != null)
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        value: loadingProgress.value,
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      '${(loadingProgress.value! * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LightboxBottomBar extends StatelessWidget {
  final BuildContext context;
  final List<SnCloudFile> items;
  final int currentIndex;
  final PhotoViewControllerBase photoViewController;
  final ValueNotifier<int> rotation;
  final bool showOriginal;
  final bool showExif;
  final VoidCallback onToggleOriginal;
  final VoidCallback onToggleExif;

  const _LightboxBottomBar({
    required this.context,
    required this.items,
    required this.currentIndex,
    required this.photoViewController,
    required this.rotation,
    required this.showOriginal,
    required this.showExif,
    required this.onToggleOriginal,
    required this.onToggleExif,
  });

  @override
  Widget build(BuildContext context) {
    final currentItem = items[currentIndex];
    final isImage = currentItem.mimeType?.startsWith('image') == true;
    final hasExifData = ExifInfoOverlay.precheck(currentItem);
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    if (!isImage) return const SizedBox.shrink();

    return Positioned(
      bottom: paddingBottom + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onToggleOriginal,
            icon: Icon(
              showOriginal
                  ? Symbols.photo_size_select_large
                  : Symbols.photo_size_select_small,
              color: Colors.white,
              shadows: WhiteShadows.standard,
            ),
            tooltip: showOriginal ? 'High Quality' : 'Low Quality',
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove,
                  color: Colors.white,
                  shadows: WhiteShadows.standard,
                ),
                onPressed: () {
                  photoViewController.scale =
                      (photoViewController.scale ?? 1) - 0.05;
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                  shadows: WhiteShadows.standard,
                ),
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
                  shadows: WhiteShadows.standard,
                ),
                onPressed: () {
                  rotation.value = (rotation.value - 1) % 4;
                  photoViewController.rotation = rotation.value * -math.pi / 2;
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.rotate_right,
                  color: Colors.white,
                  shadows: WhiteShadows.standard,
                ),
                onPressed: () {
                  rotation.value = (rotation.value + 1) % 4;
                  photoViewController.rotation = rotation.value * -math.pi / 2;
                },
              ),
              if (hasExifData) ...[
                const Gap(8),
                IconButton(
                  icon: Icon(
                    showExif ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                    shadows: WhiteShadows.standard,
                  ),
                  onPressed: onToggleExif,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
