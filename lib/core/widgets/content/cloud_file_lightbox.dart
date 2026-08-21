import 'dart:async';
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
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
    final showOriginal = useState(false);
    final isZoomed = useState(false);

    // Chrome-only state. Kept in ValueNotifiers so toggling/auto-hiding the
    // controls or flipping EXIF rebuilds just the overlays in
    // [_LightboxChrome], never the dismissible page or the gallery.
    final showControls = useMemoized(() => ValueNotifier(true), const []);
    final controlsVisible = useMemoized(() => ValueNotifier(true), const []);
    final showExif = useMemoized(
      () => ValueNotifier(ExifInfoOverlay.precheck(items[initialIndex])),
      const [],
    );

    // [DismissiblePage] swaps between a plain [DecoratedBox] and its
    // drag-aware wrapper whenever `disabled` flips (zoomed image <-> normal).
    // Without this key the whole content subtree — gallery, scroll position,
    // image streams, video player — would be disposed and rebuilt from
    // scratch on every zoom threshold crossing. GlobalKey reparenting keeps
    // the subtree (and all its State) alive across the flip.
    final contentKey = useMemoized(() => GlobalKey(), const []);

    final pageController = useMemoized(
      () => PageController(initialPage: initialIndex),
      [initialIndex],
    );
    final photoViewControllers = useMemoized(
      () => List.generate(items.length, (_) => PhotoViewController()),
      [items.length],
    );
    final photoViewScaleStateControllers = useMemoized(
      () => List.generate(items.length, (_) => PhotoViewScaleStateController()),
      [items.length],
    );
    useEffect(() {
      return () {
        pageController.dispose();
        for (final controller in photoViewControllers) {
          controller.dispose();
        }
        for (final controller in photoViewScaleStateControllers) {
          controller.dispose();
        }
      };
    }, [pageController, photoViewControllers, photoViewScaleStateControllers]);
    final focusNode = useFocusNode();
    final serverUrl = ref.watch(serverUrlProvider);

    final currentItem = items[currentIndex.value];
    final currentIsVideo = isLightboxVideo(currentItem);

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

    PhotoViewController currentPhotoController() =>
        photoViewControllers[currentIndex.value];

    // Let a zoomed-in image own vertical drags for panning; otherwise a
    // downward swipe dismisses the lightbox.
    useEffect(() {
      final controller = photoViewScaleStateControllers[currentIndex.value];
      void syncZoom(PhotoViewScaleState state) {
        isZoomed.value = state == PhotoViewScaleState.zoomedIn;
      }

      syncZoom(controller.scaleState);
      final sub = controller.outputScaleStateStream.listen(syncZoom);
      return sub.cancel;
    }, [currentIndex.value, photoViewScaleStateControllers]);

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
    // fighting a disappearing overlay, and top bar stays available. Listens on
    // the notifiers instead of hook state so re-arming never rebuilds the
    // gallery.
    useEffect(() {
      if (currentIsVideo) return null;
      Timer? timer;
      void restart() {
        timer?.cancel();
        if (showControls.value && controlsVisible.value) {
          timer = Timer(const Duration(seconds: 3), () {
            controlsVisible.value = false;
          });
        }
      }

      showControls.addListener(restart);
      controlsVisible.addListener(restart);
      restart();
      return () {
        timer?.cancel();
        showControls.removeListener(restart);
        controlsVisible.removeListener(restart);
      };
    }, [showControls, controlsVisible, currentIsVideo]);

    void showActionsSheet() async {
      revealControls();
      await CloudFileActionsSheet.show(
        context: context,
        item: items[currentIndex.value],
        sourcePost: sourcePost,
      );
    }

    Future<void> openDetail() async {
      final router = context.router;
      Navigator.of(context).pop();
      await Future<void>.delayed(Duration.zero);
      router.push(FileDetailRoute(id: currentItem.id, sourcePost: sourcePost));
    }

    void onPageChanged(int index) {
      currentIndex.value = index;
      showExif.value = ExifInfoOverlay.precheck(items[index]);
      revealControls();
    }

    return DismissiblePage(
      isFullScreen: true,
      backgroundColor: Colors.black,
      direction: DismissiblePageDismissDirection.down,
      disabled: isZoomed.value,
      onDismissed: () => Navigator.of(context).pop(),
      child: KeyedSubtree(
        key: contentKey,
        child: Focus(
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
                  _LightboxGallery(
                    items: items,
                    pageController: pageController,
                    photoViewControllers: photoViewControllers,
                    photoViewScaleStateControllers:
                        photoViewScaleStateControllers,
                    serverUrl: serverUrl,
                    heroTag: heroTag,
                    initialIndex: initialIndex,
                    currentIndex: currentIndex.value,
                    showOriginal:
                        showOriginal.value && currentItem.hasCompression,
                    onPageChanged: onPageChanged,
                    onTapToggle: toggleControls,
                  ),
                  _LightboxChrome(
                    items: items,
                    currentIndex: currentIndex.value,
                    currentItem: currentItem,
                    serverUrl: serverUrl,
                    showOriginal:
                        showOriginal.value && currentItem.hasCompression,
                    showControls: showControls,
                    controlsVisible: controlsVisible,
                    showExif: showExif,
                    onClose: () => Navigator.of(context).pop(),
                    onShowActions: showActionsSheet,
                    onGoPrevious: goToPrevious,
                    onGoNext: goToNext,
                    onZoomOut: () => zoomBy(-0.15),
                    onZoomIn: () => zoomBy(0.15),
                    onRotateLeft: () => rotateBy(-math.pi / 2),
                    onRotateRight: () => rotateBy(math.pi / 2),
                    onToggleOriginal: () {
                      showOriginal.value = !showOriginal.value;
                      revealControls();
                    },
                    onOpenDetail: openDetail,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The pannable photo/video gallery. Kept separate from [_LightboxChrome] so
/// chrome-only state changes (controls auto-hide, EXIF toggle, quality
/// progress) never rebuild the gallery pages.
class _LightboxGallery extends StatelessWidget {
  final List<IDisplayableCloudFile> items;
  final PageController pageController;
  final List<PhotoViewController> photoViewControllers;
  final List<PhotoViewScaleStateController> photoViewScaleStateControllers;
  final String serverUrl;
  final String? heroTag;
  final int initialIndex;
  final int currentIndex;
  final bool showOriginal;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onTapToggle;

  const _LightboxGallery({
    required this.items,
    required this.pageController,
    required this.photoViewControllers,
    required this.photoViewScaleStateControllers,
    required this.serverUrl,
    required this.heroTag,
    required this.initialIndex,
    required this.currentIndex,
    required this.showOriginal,
    required this.onPageChanged,
    required this.onTapToggle,
  });

  @override
  Widget build(BuildContext context) {
    return PhotoViewGallery.builder(
      key: ValueKey(items.length),
      pageController: pageController,
      itemCount: items.length,
      scrollPhysics: items.length == 1
          ? const NeverScrollableScrollPhysics()
          : const BouncingScrollPhysics(),
      onPageChanged: onPageChanged,
      builder: (context, index) {
        final item = items[index];
        final isImage = isLightboxImage(item);
        final isVideo = isLightboxVideo(item);
        final isHero = heroTag != null && index == initialIndex;
        final isActive = index == currentIndex;

        if (isImage) {
          final imageProvider = CloudImageWidget.provider(
            file: item,
            serverUrl: serverUrl,
            original: showOriginal,
          );
          return PhotoViewGalleryPageOptions(
            imageProvider: imageProvider,
            controller: photoViewControllers[index],
            scaleStateController: photoViewScaleStateControllers[index],
            heroAttributes: isHero
                ? PhotoViewHeroAttributes(tag: heroTag!)
                : null,
            minScale: PhotoViewComputedScale.contained * 0.9,
            maxScale: PhotoViewComputedScale.covered * 3,
            initialScale: PhotoViewComputedScale.contained * 1.0,
            onTapUp: (context, details, controller) {
              onTapToggle();
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
              onTapToggle();
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
    );
  }
}

/// All chrome overlaid on the gallery: gradients, top/bottom bars, EXIF
/// overlay, quality progress and page arrows.
///
/// Owns the frequently-toggled overlay state (controls visibility, EXIF,
/// quality loading) so those rebuilds never reach the gallery.
class _LightboxChrome extends HookConsumerWidget {
  final List<IDisplayableCloudFile> items;
  final int currentIndex;
  final IDisplayableCloudFile currentItem;
  final String serverUrl;
  final bool showOriginal;
  final ValueNotifier<bool> showControls;
  final ValueNotifier<bool> controlsVisible;
  final ValueNotifier<bool> showExif;
  final VoidCallback onClose;
  final VoidCallback onShowActions;
  final VoidCallback onGoPrevious;
  final VoidCallback onGoNext;
  final VoidCallback onZoomOut;
  final VoidCallback onZoomIn;
  final VoidCallback onRotateLeft;
  final VoidCallback onRotateRight;
  final VoidCallback onToggleOriginal;
  final VoidCallback onOpenDetail;

  const _LightboxChrome({
    required this.items,
    required this.currentIndex,
    required this.currentItem,
    required this.serverUrl,
    required this.showOriginal,
    required this.showControls,
    required this.controlsVisible,
    required this.showExif,
    required this.onClose,
    required this.onShowActions,
    required this.onGoPrevious,
    required this.onGoNext,
    required this.onZoomOut,
    required this.onZoomIn,
    required this.onRotateLeft,
    required this.onRotateRight,
    required this.onToggleOriginal,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qualityProvider = useMemoized(
      () => CloudImageWidget.provider(
        file: currentItem,
        serverUrl: serverUrl,
        original: showOriginal,
      ),
      [currentItem, serverUrl, showOriginal],
    );
    final qualityLoad = useImageQualityLoad(
      provider: qualityProvider,
      showOriginal: showOriginal,
      reloadToken: '${currentItem.id}:$showOriginal',
    );

    final chromeState = useMemoized(
      () => Listenable.merge([showControls, controlsVisible, showExif]),
      [showControls, controlsVisible, showExif],
    );

    final isImage = isLightboxImage(currentItem);
    final isVideo = isLightboxVideo(currentItem);
    final showDesktopImageTools = _isDesktopImageControlsPlatform() && isImage;
    final mediaQuery = MediaQuery.of(context);

    void revealControls() {
      showControls.value = true;
      controlsVisible.value = true;
    }

    void handleToggleOriginal() {
      if (qualityLoad.isLoading) return;
      qualityLoad.beginLoad();
      onToggleOriginal();
    }

    void handleToggleExif() {
      showExif.value = !showExif.value;
      revealControls();
    }

    return ListenableBuilder(
      listenable: chromeState,
      builder: (context, _) {
        final controlsShown =
            isVideo || (showControls.value && controlsVisible.value);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (showExif.value && isImage)
              Positioned(
                left: 16,
                right: 16,
                bottom: 0,
                child: IgnorePointer(
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(
                      bottom:
                          mediaQuery.padding.bottom + (controlsShown ? 88 : 24),
                    ),
                    child: ExifInfoOverlay(item: currentItem),
                  ),
                ),
              ),

            if (isImage)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ImageQualityProgressBar(
                  isLoading: qualityLoad.isLoading,
                  progress: qualityLoad.progress,
                  loadingOriginal: showOriginal,
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
                    if (!isVideo)
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
                      currentIndex: currentIndex,
                      onClose: onClose,
                      onShowActions: onShowActions,
                    ),
                    if (!isVideo)
                      _LightboxBottomBar(
                        item: currentItem,
                        showOriginal: showOriginal,
                        showExif: showExif.value,
                        isQualityLoading: qualityLoad.isLoading,
                        showTransformControls: showDesktopImageTools,
                        onZoomOut: onZoomOut,
                        onZoomIn: onZoomIn,
                        onRotateLeft: onRotateLeft,
                        onRotateRight: onRotateRight,
                        onToggleOriginal: handleToggleOriginal,
                        onToggleExif: handleToggleExif,
                        onOpenDetail: onOpenDetail,
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
                      if (currentIndex > 0)
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: MediaIconButton(
                              icon: Symbols.chevron_left,
                              size: 44,
                              iconSize: 28,
                              onPressed: onGoPrevious,
                              tooltip: 'Previous',
                            ),
                          ),
                        ),
                      if (currentIndex < items.length - 1)
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: MediaIconButton(
                              icon: Symbols.chevron_right,
                              size: 44,
                              iconSize: 28,
                              onPressed: onGoNext,
                              tooltip: 'Next',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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

  String get _uri => item.storageUrl ?? '$serverUrl/drive/files/${item.id}';

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
            const Icon(
              Symbols.insert_drive_file,
              size: 56,
              color: Colors.white54,
            ),
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
    final name = item.name.isEmpty ? (isVideo ? 'Video' : 'Image') : item.name;
    final counter = items.length > 1
        ? '${currentIndex + 1} / ${items.length}'
        : null;
    final kindLabel = isVideo
        ? 'Video'
        : (isLightboxImage(item) ? 'Image' : null);

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
      icon: iconWidget ?? Icon(icon, color: Colors.white, size: 22),
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
            if (item.hasCompression || hasExifData)
              MediaChromeSurface.pill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.hasCompression)
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
