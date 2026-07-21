import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/utils/format.dart';
import 'package:island/core/widgets/content/cloud_file_actions_sheet.dart';
import 'package:island/core/widgets/content/exif_info_overlay.dart';
import 'package:island/core/widgets/content/file_action_button.dart';
import 'package:island/core/widgets/content/image_quality_loading.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/content/video.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Desktop mouse platforms where pinch/gesture zoom is awkward.
bool _isDesktopImageControlsPlatform() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return true;
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      return false;
  }
}

/// Images and videos that can be opened in [CloudFileLightbox].
bool isLightboxMedia(IDisplayableCloudFile file) {
  final mime = file.mimeType;
  return mime.startsWith('image') || mime.startsWith('video');
}

bool isLightboxImage(IDisplayableCloudFile file) =>
    file.mimeType.startsWith('image');

bool isLightboxVideo(IDisplayableCloudFile file) =>
    file.mimeType.startsWith('video');

class CloudFileLightbox extends HookConsumerWidget {
  final List<IDisplayableCloudFile> items;
  final int initialIndex;
  final String? heroTag;
  final SnPost? sourcePost;

  const CloudFileLightbox({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.heroTag,
    this.sourcePost,
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
    useEffect(() {
      return () {
        pageController.dispose();
        for (final controller in photoViewControllers) {
          controller.dispose();
        }
      };
    }, [pageController, photoViewControllers]);
    final showExif = useState(ExifInfoOverlay.precheck(items[initialIndex]));
    final showOriginal = useState(false);
    final focusNode = useFocusNode();
    final serverUrl = ref.watch(serverUrlProvider);
    final mediaQuery = MediaQuery.of(context);
    final currentItemForLoad = items[currentIndex.value];
    final qualityProvider = CloudImageWidget.provider(
      file: currentItemForLoad,
      serverUrl: serverUrl,
      original: showOriginal.value,
    );
    final qualityLoad = useImageQualityLoad(
      provider: qualityProvider,
      showOriginal: showOriginal.value,
      reloadToken: '${currentItemForLoad.id}:${showOriginal.value}',
    );

    void revealControls() {
      showControls.value = true;
      controlsVisible.value = true;
    }

    void toggleControls() {
      if (showControls.value && controlsVisible.value) {
        controlsVisible.value = false;
        showControls.value = false;
      } else {
        revealControls();
      }
    }

    void goToPage(int index) {
      if (index >= 0 && index < items.length) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
        );
        revealControls();
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

    final currentItem = items[currentIndex.value];
    final currentIsVideo = isLightboxVideo(currentItem);
    final showDesktopImageTools =
        _isDesktopImageControlsPlatform() && isLightboxImage(currentItem);
    PhotoViewController currentPhotoController() =>
        photoViewControllers[currentIndex.value];

    void zoomBy(double delta) {
      final controller = currentPhotoController();
      final currentScale = controller.scale ?? 1.0;
      controller.scale = (currentScale + delta).clamp(0.1, 10.0);
      revealControls();
    }

    void rotateBy(double radians) {
      final controller = currentPhotoController();
      controller.rotation = controller.rotation + radians;
      revealControls();
    }

    // Auto-hide chrome for images only; video keeps chrome so seek bar isn't
    // fighting a disappearing overlay, and top bar stays available.
    useEffect(() {
      if (currentIsVideo) return null;
      if (!showControls.value || !controlsVisible.value) return null;
      final timer = Timer(const Duration(seconds: 3), () {
        controlsVisible.value = false;
      });
      return timer.cancel;
    }, [
      showControls.value,
      controlsVisible.value,
      currentIndex.value,
      currentIsVideo,
    ]);

    void showActionsSheet() async {
      revealControls();
      final result = await CloudFileActionsSheet.show(
        context: context,
        item: items[currentIndex.value],
      );

      if (result == null || !context.mounted) return;

      switch (result) {
        case 'save':
          final item = items[currentIndex.value];
          if (item is SnCloudFile) {
            ref.read(driveFileDownloaderProvider).saveToGallery(item);
          }
          break;
        case 'toggle_original':
          showOriginal.value = !showOriginal.value;
          break;
        case 'share':
          break;
        case 'open_in_viewer':
          final item = items[currentIndex.value];
          final router = context.router;
          Navigator.of(context).pop();
          await Future<void>.delayed(Duration.zero);
          router.push(FileDetailRoute(id: item.id, sourcePost: sourcePost));
          break;
      }
    }

    Future<void> openDetail() async {
      final router = context.router;
      Navigator.of(context).pop();
      await Future<void>.delayed(Duration.zero);
      router.push(
        FileDetailRoute(id: currentItem.id, sourcePost: sourcePost),
      );
    }

    final controlsShown =
        currentIsVideo || (showControls.value && controlsVisible.value);

    // A drag-to-dismiss recognizer competes with PhotoView's vertical pan once
    // an image is enlarged. Keeping the gallery as the sole gesture owner
    // avoids transform contention and the resulting jitter while zooming.
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
          }
        }
        return KeyEventResult.ignored;
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PhotoViewGallery.builder(
                key: ValueKey(items.length),
                pageController: pageController,
                itemCount: items.length,
                scrollPhysics: items.length == 1
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  currentIndex.value = index;
                  showExif.value = ExifInfoOverlay.precheck(items[index]);
                  revealControls();
                },
                builder: (context, index) {
                  final item = items[index];
                  final isImage = isLightboxImage(item);
                  final isVideo = isLightboxVideo(item);
                  final isHero = heroTag != null && index == initialIndex;
                  final isActive = index == currentIndex.value;

                  if (isImage) {
                    final imageProvider = CloudImageWidget.provider(
                      file: item,
                      serverUrl: serverUrl,
                      original: showOriginal.value,
                    );
                    return PhotoViewGalleryPageOptions(
                      imageProvider: imageProvider,
                      controller: photoViewControllers[index],
                      heroAttributes: isHero
                          ? PhotoViewHeroAttributes(tag: heroTag!)
                          : null,
                      basePosition: Alignment.center,
                      minScale: PhotoViewComputedScale.contained * 0.9,
                      maxScale: PhotoViewComputedScale.covered * 3,
                      initialScale: PhotoViewComputedScale.contained * 1.0,
                      onTapUp: (context, details, controller) {
                        toggleControls();
                      },
                    );
                  }

                  if (isVideo) {
                    Widget videoChild = _LightboxVideoPage(
                      item: item,
                      serverUrl: serverUrl,
                      isActive: isActive,
                    );
                    if (isHero) {
                      videoChild = Hero(tag: heroTag!, child: videoChild);
                    }
                    return PhotoViewGalleryPageOptions.customChild(
                      child: videoChild,
                      disableGestures: true,
                      onTapUp: (context, details, controller) {
                        toggleControls();
                      },
                    );
                  }

                  return PhotoViewGalleryPageOptions.customChild(
                    child: _LightboxUnsupportedPage(item: item),
                    disableGestures: true,
                  );
                },
                loadingBuilder: (context, event) {
                  if (event == null || event.expectedTotalBytes == null) {
                    return const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                    );
                  }
                  final progress =
                      event.cumulativeBytesLoaded / event.expectedTotalBytes!;
                  return Center(
                    child: MediaChromeSurface(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                gaplessPlayback: true,
                enableRotation: true,
              ),

              if (showExif.value && isLightboxImage(currentItem))
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 0,
                  child: IgnorePointer(
                    child: AnimatedPadding(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      padding: EdgeInsets.only(
                        bottom: mediaQuery.padding.bottom +
                            (controlsShown ? 88 : 24),
                      ),
                      child: ExifInfoOverlay(item: currentItem),
                    ),
                  ),
                ),

              if (isLightboxImage(currentItem))
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ImageQualityProgressBar(
                    isLoading: qualityLoad.isLoading,
                    progress: qualityLoad.progress,
                    loadingOriginal: showOriginal.value,
                  ),
                ),

              // Control chrome
              AnimatedOpacity(
                opacity: controlsShown ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: IgnorePointer(
                  ignoring: !controlsShown,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: mediaQuery.padding.top + 72,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Avoid overlapping the video player controls at bottom.
                      if (!currentIsVideo)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: mediaQuery.padding.bottom + 96,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      _LightboxTopBar(
                        items: items,
                        currentIndex: currentIndex.value,
                        onClose: () => Navigator.of(context).pop(),
                        onShowActions: showActionsSheet,
                      ),
                      if (!currentIsVideo)
                        _LightboxBottomBar(
                          item: currentItem,
                          showOriginal: showOriginal.value,
                          showExif: showExif.value,
                          isQualityLoading: qualityLoad.isLoading,
                          showTransformControls: showDesktopImageTools,
                          onZoomOut: () => zoomBy(-0.15),
                          onZoomIn: () => zoomBy(0.15),
                          onRotateLeft: () => rotateBy(-math.pi / 2),
                          onRotateRight: () => rotateBy(math.pi / 2),
                          onToggleOriginal: () {
                            if (qualityLoad.isLoading) return;
                            qualityLoad.beginLoad();
                            showOriginal.value = !showOriginal.value;
                            revealControls();
                          },
                          onToggleExif: () {
                            showExif.value = !showExif.value;
                            revealControls();
                          },
                          onOpenDetail: openDetail,
                        ),
                    ],
                  ),
                ),
              ),

              if (items.length > 1)
                AnimatedOpacity(
                  opacity: controlsShown ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: IgnorePointer(
                    ignoring: !controlsShown,
                    child: Stack(
                      children: [
                        if (currentIndex.value > 0)
                          Positioned(
                            left: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: MediaIconButton(
                                icon: Symbols.chevron_left,
                                size: 44,
                                iconSize: 28,
                                onPressed: goToPrevious,
                                tooltip: 'Previous',
                              ),
                            ),
                          ),
                        if (currentIndex.value < items.length - 1)
                          Positioned(
                            right: 12,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: MediaIconButton(
                                icon: Symbols.chevron_right,
                                size: 44,
                                iconSize: 28,
                                onPressed: goToNext,
                                tooltip: 'Next',
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LightboxVideoPage extends StatelessWidget {
  final IDisplayableCloudFile item;
  final String serverUrl;
  final bool isActive;

  const _LightboxVideoPage({
    required this.item,
    required this.serverUrl,
    required this.isActive,
  });

  String get _uri =>
      item.storageUrl ?? '$serverUrl/drive/files/${item.id}';

  double get _ratio {
    final ratio = item.ratio;
    if (ratio == null || ratio == 0) return 16 / 9;
    return ratio;
  }

  @override
  Widget build(BuildContext context) {
    // Only mount the heavy player for the active page so swiping away stops
    // playback and frees the decoder.
    if (!isActive) {
      return _LightboxVideoPlaceholder(item: item, serverUrl: serverUrl);
    }

    return ColoredBox(
      color: Colors.black,
      child: SafeArea(
        child: Center(
          child: AspectRatio(
            aspectRatio: _ratio,
            child: UniversalVideo(
              uri: _uri,
              aspectRatio: _ratio,
              autoplay: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _LightboxVideoPlaceholder extends StatelessWidget {
  final IDisplayableCloudFile item;
  final String serverUrl;

  const _LightboxVideoPlaceholder({
    required this.item,
    required this.serverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final thumbUri = '$serverUrl/drive/files/${item.id}?thumbnail=true';

    return ColoredBox(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            thumbUri,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: Colors.black),
          ),
          const Center(
            child: MediaIconButton(
              icon: Icons.play_arrow_rounded,
              size: 56,
              iconSize: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class _LightboxUnsupportedPage extends StatelessWidget {
  final IDisplayableCloudFile item;

  const _LightboxUnsupportedPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Symbols.insert_drive_file, size: 56, color: Colors.white54),
            const Gap(12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                item.name.isEmpty ? 'Unsupported file' : item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LightboxTopBar extends StatelessWidget {
  final List<IDisplayableCloudFile> items;
  final int currentIndex;
  final VoidCallback onClose;
  final VoidCallback onShowActions;

  const _LightboxTopBar({
    required this.items,
    required this.currentIndex,
    required this.onClose,
    required this.onShowActions,
  });

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;
    final item = items[currentIndex];
    final isVideo = isLightboxVideo(item);
    final name = item.name.isEmpty
        ? (isVideo ? 'Video' : 'Image')
        : item.name;
    final counter = items.length > 1
        ? '${currentIndex + 1} / ${items.length}'
        : null;
    final kindLabel = isVideo ? 'Video' : (isLightboxImage(item) ? 'Image' : null);

    return Positioned(
      top: paddingTop + 8,
      left: 12,
      right: 12,
      child: Row(
        children: [
          MediaIconButton(
            icon: Icons.close,
            onPressed: onClose,
            tooltip: 'Close',
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (counter != null || item.size > 0 || kindLabel != null)
                  Text(
                    [
                      ?counter,
                      ?kindLabel,
                      if (item.size > 0) formatFileSize(item.size),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const Gap(8),
          MediaIconButton(
            icon: Icons.more_horiz,
            onPressed: onShowActions,
            tooltip: 'More',
          ),
        ],
      ),
    );
  }
}

class _LightboxBottomBar extends StatelessWidget {
  final IDisplayableCloudFile item;
  final bool showOriginal;
  final bool showExif;
  final bool isQualityLoading;
  final bool showTransformControls;
  final VoidCallback? onZoomOut;
  final VoidCallback? onZoomIn;
  final VoidCallback? onRotateLeft;
  final VoidCallback? onRotateRight;
  final VoidCallback onToggleOriginal;
  final VoidCallback onToggleExif;
  final VoidCallback onOpenDetail;

  const _LightboxBottomBar({
    required this.item,
    required this.showOriginal,
    required this.showExif,
    this.isQualityLoading = false,
    this.showTransformControls = false,
    this.onZoomOut,
    this.onZoomIn,
    this.onRotateLeft,
    this.onRotateRight,
    required this.onToggleOriginal,
    required this.onToggleExif,
    required this.onOpenDetail,
  });

  Widget _pillIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    Widget? iconWidget,
  }) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      padding: EdgeInsets.zero,
      tooltip: tooltip,
      onPressed: onPressed,
      icon:
          iconWidget ??
          Icon(icon, color: Colors.white, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isImage = isLightboxImage(item);
    final hasExifData = ExifInfoOverlay.precheck(item);
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: paddingBottom + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          if (isImage) ...[
            if (showTransformControls) ...[
              MediaChromeSurface.pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _pillIconButton(
                      icon: Icons.remove,
                      tooltip: 'Zoom out',
                      onPressed: onZoomOut,
                    ),
                    _pillIconButton(
                      icon: Icons.add,
                      tooltip: 'Zoom in',
                      onPressed: onZoomIn,
                    ),
                    _pillIconButton(
                      icon: Icons.rotate_left,
                      tooltip: 'Rotate left',
                      onPressed: onRotateLeft,
                    ),
                    _pillIconButton(
                      icon: Icons.rotate_right,
                      tooltip: 'Rotate right',
                      onPressed: onRotateRight,
                    ),
                  ],
                ),
              ),
              const Gap(8),
            ],
            MediaChromeSurface.pill(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _pillIconButton(
                    icon: showOriginal ? Symbols.hd : Symbols.sd,
                    tooltip: isQualityLoading
                        ? 'Loading…'
                        : (showOriginal
                              ? 'Original quality (HD)'
                              : 'Compressed quality (SD)'),
                    onPressed: isQualityLoading ? null : onToggleOriginal,
                    iconWidget: isQualityLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  if (hasExifData)
                    _pillIconButton(
                      icon: showExif ? Icons.info : Icons.info_outline,
                      tooltip: showExif ? 'Hide EXIF' : 'Show EXIF',
                      onPressed: onToggleExif,
                    ),
                ],
              ),
            ),
          ] else
            const SizedBox(width: 48),
          const Spacer(),
          MediaChromeSurface.pill(
            child: _pillIconButton(
              icon: Symbols.open_in_new,
              tooltip: 'Open details',
              onPressed: onOpenDetail,
            ),
          ),
        ],
      ),
    );
  }
}
