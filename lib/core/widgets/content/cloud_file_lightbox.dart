import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/widgets/content/cloud_file_actions_sheet.dart';
import 'package:island/core/widgets/content/exif_info_overlay.dart';
import 'package:island/core/widgets/content/file_action_button.dart';
import 'package:island/drive/drive_service.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/route.gr.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

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
    final showExif = useState(ExifInfoOverlay.precheck(items[initialIndex]));
    final showOriginal = useState(false);
    final focusNode = useFocusNode();
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final serverUrl = ref.watch(serverUrlProvider);

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

    Widget buildContent() {
      return Positioned.fill(
        child: Stack(
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
              },
              builder: (context, index) {
                final item = items[index];
                final isImage = item.mimeType.startsWith('image') == true;
                final isHero = heroTag != null && index == initialIndex;

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
                      showControls.value = !showControls.value;
                      controlsVisible.value = true;
                    },
                  );
                } else {
                  return PhotoViewGalleryPageOptions.customChild(
                    child: const SizedBox.shrink(),
                    disableGestures: true,
                  );
                }
              },
              loadingBuilder: (context, event) {
                if (event == null || event.expectedTotalBytes == null) {
                  return const SizedBox.shrink();
                }
                final progress =
                    event.cumulativeBytesLoaded / event.expectedTotalBytes!;
                return Center(
                  child: Material(
                    color: Colors.transparent,
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
                              value: progress,
                              strokeWidth: 2,
                              color: primaryColor,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              backgroundDecoration: const BoxDecoration(color: Colors.black),
              gaplessPlayback: true,
              enableRotation: true,
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
          }
        }
        return KeyEventResult.ignored;
      },
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              buildContent(),
              GestureDetector(
                onTap: () {
                  final currentItem = items[currentIndex.value];
                  if (currentItem.mimeType.startsWith('image') == true) {
                    showControls.value = !showControls.value;
                    controlsVisible.value = true;
                  }
                },
                onDoubleTap: () {
                  showControls.value = !showControls.value;
                  controlsVisible.value = true;
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 300) {
                    Navigator.of(context).pop();
                  }
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
            ],
          ),
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
  final List<IDisplayableCloudFile> items;
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
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Positioned(
      top: paddingTop + 8,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (items.length > 1)
            Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${currentIndex + 1}/${items.length}',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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

class _LightboxBottomBar extends StatelessWidget {
  final BuildContext context;
  final List<IDisplayableCloudFile> items;
  final int currentIndex;
  final bool showOriginal;
  final bool showExif;
  final VoidCallback onToggleOriginal;
  final VoidCallback onToggleExif;

  const _LightboxBottomBar({
    required this.context,
    required this.items,
    required this.currentIndex,
    required this.showOriginal,
    required this.showExif,
    required this.onToggleOriginal,
    required this.onToggleExif,
  });

  @override
  Widget build(BuildContext context) {
    final currentItem = items[currentIndex];
    final isImage = currentItem.mimeType.startsWith('image') == true;
    final hasExifData = ExifInfoOverlay.precheck(currentItem);
    final paddingBottom = MediaQuery.of(context).padding.bottom;

    return Positioned(
      bottom: paddingBottom + 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (isImage)
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
            )
          else
            const SizedBox(width: 48),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasExifData) ...[
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
