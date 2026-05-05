import 'dart:math' as math;
import 'dart:ui';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/core/widgets/content/cloud_file_lightbox.dart';
import 'package:island/core/widgets/content/sensitive.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class CloudFileList extends HookConsumerWidget {
  final List<SnCloudFile> files;
  final double maxHeight;
  final double maxWidth;
  final double? minWidth;
  final bool disableZoomIn;
  final bool disableConstraint;
  final EdgeInsets? padding;
  final bool isColumn;
  final bool initiallyCollapsed;
  final String heroTagPrefix;
  const CloudFileList({
    super.key,
    required this.files,
    this.maxHeight = 560,
    this.maxWidth = double.infinity,
    this.minWidth,
    this.disableZoomIn = false,
    this.disableConstraint = false,
    this.padding,
    this.isColumn = false,
    this.initiallyCollapsed = true,
    this.heroTagPrefix = 'cloud-file',
  });

  String _heroTag(String fileId) => '$heroTagPrefix-$fileId';

  double calculateAspectRatio() {
    final ratios = <double>[];

    // Collect all valid ratios
    for (final file in files) {
      final meta = file.fileMeta;
      if (meta is Map<String, dynamic> && meta.containsKey('ratio')) {
        final ratioValue = meta['ratio'];
        if (ratioValue is num && ratioValue > 0) {
          ratios.add(ratioValue.toDouble());
        } else if (ratioValue is String) {
          try {
            final parsed = double.parse(ratioValue);
            if (parsed > 0) ratios.add(parsed);
          } catch (_) {
            // Skip invalid string ratios
          }
        }
      }
    }

    if (ratios.isEmpty) {
      // Default to 4:3 aspect ratio when no valid ratios found
      return 4 / 3;
    }

    if (ratios.length == 1) {
      return ratios.first;
    }

    // Group similar ratios and find the most common one
    final commonRatios = <double, int>{};

    // Common aspect ratios to round to (with tolerance)
    const tolerance = 0.05;
    final standardRatios = [
      1.0,
      4 / 3,
      3 / 2,
      16 / 9,
      5 / 3,
      5 / 4,
      7 / 5,
      9 / 16,
      2 / 3,
      3 / 4,
      4 / 5,
    ];

    for (final ratio in ratios) {
      // Find the closest standard ratio within tolerance
      double closestRatio = ratio;
      double minDiff = double.infinity;

      for (final standard in standardRatios) {
        final diff = (ratio - standard).abs();
        if (diff < minDiff && diff <= tolerance) {
          minDiff = diff;
          closestRatio = standard;
        }
      }

      // If no standard ratio is close enough, keep original
      if (minDiff == double.infinity || minDiff > tolerance) {
        closestRatio = ratio;
      }

      commonRatios[closestRatio] = (commonRatios[closestRatio] ?? 0) + 1;
    }

    // Find the most frequent ratio(s)
    int maxCount = 0;
    final mostFrequent = <double>[];

    for (final entry in commonRatios.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent.clear();
        mostFrequent.add(entry.key);
      } else if (entry.value == maxCount) {
        mostFrequent.add(entry.key);
      }
    }

    // If only one most frequent ratio, return it
    if (mostFrequent.length == 1) {
      return mostFrequent.first;
    }

    // If multiple ratios have the same highest frequency, use median of them
    mostFrequent.sort();
    final mid = mostFrequent.length ~/ 2;
    return mostFrequent.length.isEven
        ? (mostFrequent[mid - 1] + mostFrequent[mid]) / 2
        : mostFrequent[mid];
  }

  void _openLightbox(BuildContext context, int index) {
    if (disableZoomIn) return;
    final viewableFiles = files
        .asMap()
        .entries
        .where((e) => e.value.mimeType?.startsWith('image') == true)
        .toList();
    final viewableIndex = viewableFiles.indexWhere((e) => e.key == index);
    if (viewableIndex == -1) return;
    context.pushTransparentRoute(
      CloudFileLightbox(
        items: viewableFiles.map((e) => e.value).toList(),
        initialIndex: viewableIndex,
        heroTag: _heroTag(files[index].id),
      ),
      rootNavigator: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (files.isEmpty) return const SizedBox.shrink();

    final settings = ref.watch(appSettingsProvider);

    void openLightbox(int index) => _openLightbox(context, index);

    final renderInColumn =
        settings.attachmentsListStyle == 'column' || isColumn;

    if (renderInColumn) {
      final isExpanded = useState(!initiallyCollapsed);

      final children = <Widget>[];
      const maxFiles = 2;
      final filesToShow = isExpanded.value
          ? files
          : files.take(maxFiles).toList();

      for (var i = 0; i < filesToShow.length; i++) {
        final file = filesToShow[i];
        final isImage = file.mimeType?.startsWith('image') ?? false;
        final isAudio = file.mimeType?.startsWith('audio') ?? false;
        final widgetItem = ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: _CloudFileListEntry(
            file: file,
            heroTag: _heroTag(files[i].id),
            isImage: isImage,
            disableZoomIn: disableZoomIn,
            onTap: () {
              if (!isImage) {
                return;
              }
              _openLightbox(context, i);
            },
          ),
        );

        Widget item;
        if (isAudio) {
          item = SizedBox(height: 120, child: widgetItem);
        } else {
          item = AspectRatio(
            aspectRatio: (file.fileMeta?['ratio'] as num?)?.toDouble() ?? 1.0,
            child: widgetItem,
          );
        }
        children.add(item);
        if (i < filesToShow.length - 1) {
          children.add(const Gap(8));
        }
      }

      if (!isExpanded.value && files.length > maxFiles) {
        children.add(const Gap(8));
        children.add(
          Text(
            'filesListAdditional'.plural(files.length - maxFiles),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        );
      }

      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < filesToShow.length; i++)
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: files.length == 1 ? double.infinity : 320,
                      ),
                      child:
                          filesToShow[i].mimeType?.startsWith('audio') ?? false
                          ? SizedBox(
                              height: 120,
                              child: _CloudFileListEntry(
                                file: filesToShow[i],
                                heroTag: _heroTag(files[i].id),
                                isImage: false,
                                disableZoomIn: disableZoomIn,
                              ),
                            )
                          : AspectRatio(
                              aspectRatio:
                                  (filesToShow[i].fileMeta?['ratio'] as num?)
                                      ?.toDouble() ??
                                  1.0,
                              child: _CloudFileListEntry(
                                file: filesToShow[i],
                                heroTag: _heroTag(files[i].id),
                                isImage:
                                    filesToShow[i].mimeType?.startsWith(
                                      'image',
                                    ) ??
                                    false,
                                disableZoomIn: disableZoomIn,
                                onTap: () {
                                  if (!(filesToShow[i].mimeType?.startsWith(
                                        'image',
                                      ) ??
                                      false)) {
                                    return;
                                  }
                                  openLightbox(i);
                                },
                              ),
                            ),
                    ).clipRRect(all: 8),
                ],
              ),
            ),
            if (!isExpanded.value && files.length > maxFiles) ...[
              const Gap(8),
              Text(
                'filesListAdditional'.plural(files.length - maxFiles),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            if (files.length > maxFiles) ...[
              const Gap(4),
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isExpanded.value
                            ? Symbols.expand_less
                            : Symbols.expand_more,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const Gap(4),
                      Text(
                        isExpanded.value ? 'collapse' : 'expand',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      ).tr(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (files.length == 1) {
      final isImage = files.first.mimeType?.startsWith('image') ?? false;
      final isAudio = files.first.mimeType?.startsWith('audio') ?? false;
      final ratio = files.first.fileMeta?['ratio'] as num?;
      final widgetItem = ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: _CloudFileListEntry(
          file: files.first,
          heroTag: _heroTag(files.first.id),
          isImage: isImage,
          disableZoomIn: disableZoomIn,
          onTap: () {
            if (!isImage) {
              return;
            }
            openLightbox(0);
          },
        ),
      );
      return Container(
        padding: padding,
        constraints: BoxConstraints(
          maxHeight: disableConstraint ? double.infinity : maxHeight,
          minWidth: minWidth ?? 0,
          maxWidth: files.length == 1 ? maxWidth : double.infinity,
        ),
        child: (ratio == null && isImage)
            ? IntrinsicWidth(child: IntrinsicHeight(child: widgetItem))
            : (ratio == null && isAudio)
            ? IntrinsicHeight(child: widgetItem)
            : AspectRatio(
                aspectRatio: ratio?.toDouble() ?? 1,
                child: widgetItem,
              ),
      );
    }

    final allImages = !files.any(
      (e) => e.mimeType == null || !e.mimeType!.startsWith('image'),
    );

    if (allImages) {
      return ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight, minWidth: maxWidth),
        child: AspectRatio(
          aspectRatio: calculateAspectRatio(),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.of(context).size.width;
                final itemExtent = math.min(
                  math.min(availableWidth * 0.75, maxWidth * 0.75).toDouble(),
                  640.0,
                );

                return _HoverScrollableGallery(
                  padding: padding,
                  itemExtent: itemExtent,
                  children: [
                    for (var i = 0; i < files.length; i++)
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            child: _CloudFileListEntry(
                              file: files[i],
                              heroTag: _heroTag(files[i].id),
                              isImage:
                                  files[i].mimeType?.startsWith('image') ??
                                  false,
                              disableZoomIn: disableZoomIn,
                              onTap: () {
                                if (!(files[i].mimeType?.startsWith('image') ??
                                    false)) {
                                  return;
                                }
                                openLightbox(i);
                              },
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 16,
                            child: Text('${i + 1}/${files.length}')
                                .textColor(Colors.white)
                                .textShadow(
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                  blurRadius: 3,
                                ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight, minWidth: maxWidth),
      child: AspectRatio(
        aspectRatio: calculateAspectRatio(),
        child: _HoverScrollableGallery(
          padding: padding,
          children: [
            for (var index = 0; index < files.length; index++)
              AspectRatio(
                aspectRatio: files[index].fileMeta?['ratio'] is num
                    ? files[index].fileMeta!['ratio'].toDouble()
                    : 1.0,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      child: _CloudFileListEntry(
                        file: files[index],
                        heroTag: _heroTag(files[index].id),
                        isImage:
                            files[index].mimeType?.startsWith('image') ?? false,
                        disableZoomIn: disableZoomIn,
                        onTap: () {
                          if (!(files[index].mimeType?.startsWith('image') ??
                              false)) {
                            return;
                          }
                          openLightbox(index);
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 16,
                      child: Text('${index + 1}/${files.length}')
                          .textColor(Colors.white)
                          .textShadow(
                            color: Colors.black54,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HoverScrollableGallery extends HookWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? itemExtent;

  const _HoverScrollableGallery({
    required this.children,
    this.padding,
    this.itemExtent,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final isHovered = useState(false);
    final canScrollLeft = useState(false);
    final canScrollRight = useState(false);

    void updateScrollState() {
      if (!controller.hasClients) {
        canScrollLeft.value = false;
        canScrollRight.value = false;
        return;
      }

      final position = controller.position;
      canScrollLeft.value = position.pixels > 0;
      canScrollRight.value = position.pixels < position.maxScrollExtent;
    }

    useEffect(() {
      void listener() => updateScrollState();

      controller.addListener(listener);
      WidgetsBinding.instance.addPostFrameCallback((_) => updateScrollState());

      return () => controller.removeListener(listener);
    }, [controller, children.length, itemExtent, padding]);

    Future<void> scrollBy(double direction) async {
      if (!controller.hasClients) return;
      final position = controller.position;
      final delta = math.max(position.viewportDimension * 0.8, 240.0);
      final target = (position.pixels + delta * direction).clamp(
        0.0,
        position.maxScrollExtent,
      );
      await controller.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }

    final scrollBehavior = ScrollConfiguration.of(context).copyWith(
      dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.trackpad},
    );

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: Stack(
        children: [
          Positioned.fill(
            child: ScrollConfiguration(
              behavior: scrollBehavior,
              child: ListView.separated(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: padding,
                itemCount: children.length,
                itemBuilder: (context, index) => itemExtent == null
                    ? children[index]
                    : SizedBox(width: itemExtent, child: children[index]),
                separatorBuilder: (_, _) => const Gap(8),
              ),
            ),
          ),
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _AnimatedScrollArrowButton(
                icon: Symbols.chevron_left,
                isVisible: isHovered.value && canScrollLeft.value,
                hiddenOffset: const Offset(-0.4, 0),
                onTap: () => scrollBy(-1),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: _AnimatedScrollArrowButton(
                icon: Symbols.chevron_right,
                isVisible: isHovered.value && canScrollRight.value,
                hiddenOffset: const Offset(0.4, 0),
                onTap: () => scrollBy(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedScrollArrowButton extends StatelessWidget {
  final IconData icon;
  final bool isVisible;
  final Offset hiddenOffset;
  final VoidCallback onTap;

  const _AnimatedScrollArrowButton({
    required this.icon,
    required this.isVisible,
    required this.hiddenOffset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isVisible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: isVisible ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          opacity: isVisible ? 1 : 0,
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloudFileListEntry extends HookConsumerWidget {
  final SnCloudFile file;
  final String heroTag;
  final bool isImage;
  final bool disableZoomIn;
  final VoidCallback? onTap;

  const _CloudFileListEntry({
    required this.file,
    required this.heroTag,
    required this.isImage,
    required this.disableZoomIn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataSaving = ref.watch(
      appSettingsProvider.select((s) => s.dataSavingMode),
    );
    final showMature = useState(false);
    final showDataSaving = useState(!dataSaving);
    final lockedByDS = dataSaving && !showDataSaving.value;
    final lockedByMature = file.sensitiveMarks.isNotEmpty && !showMature.value;
    final meta = file.fileMeta is Map ? file.fileMeta as Map : const {};

    final fit = BoxFit.cover;

    Widget bg = const SizedBox.shrink();
    if (isImage) {
      if (meta['blur'] is String) {
        bg = BlurHash(hash: meta['blur'] as String);
      } else if (!lockedByDS && !lockedByMature) {
        bg = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: CloudFileWidget(
            fit: BoxFit.cover,
            item: file,
            noBlurhash: true,
            useInternalGate: false,
          ),
        );
      } else {
        bg = const ColoredBox(color: Colors.black26);
      }
    }

    final bool fullyUnlocked = !lockedByDS && !lockedByMature;
    Widget fg = fullyUnlocked
        ? (isImage
              ? CloudFileWidget(
                  item: file,
                  heroTag: heroTag,
                  noBlurhash: true,
                  fit: fit,
                  useInternalGate: false,
                )
              : CloudFileWidget(
                  item: file,
                  heroTag: heroTag,
                  fit: fit,
                  useInternalGate: false,
                ))
        : const SizedBox.shrink();

    Widget overlays = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: lockedByDS
          ? _DataSavingOverlay(key: const ValueKey('ds'))
          : (file.sensitiveMarks.isNotEmpty && !showMature.value
                ? _SensitiveOverlay(
                    key: const ValueKey('sensitive-blur'),
                    file: file,
                  )
                : const SizedBox.shrink(key: ValueKey('none'))),
    );

    Widget hideButton = const SizedBox.shrink();
    if (file.sensitiveMarks.isNotEmpty && showMature.value) {
      hideButton = Positioned(
        top: 3,
        left: 4,
        child: IconButton(
          iconSize: 16,
          constraints: const BoxConstraints(),
          icon: const Icon(
            Icons.visibility_off,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5.0,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
          tooltip: 'Blur content',
          onPressed: () => showMature.value = false,
        ),
      );
    }

    final content = Stack(
      fit: StackFit.expand,
      children: [
        if (isImage) Positioned.fill(child: bg),
        fg,
        overlays,
        hideButton,
      ],
    );

    return InkWell(
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      onTap: () {
        if (lockedByDS) {
          showDataSaving.value = true;
        } else if (lockedByMature) {
          showMature.value = true;
        } else {
          onTap?.call();
        }
      },
      child: content,
    );
  }
}

class _SensitiveOverlay extends StatelessWidget {
  final SnCloudFile file;

  const _SensitiveOverlay({required this.file, super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 64, sigmaY: 64),
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: _OverlayCard(
            icon: Icons.warning,
            title: file.sensitiveMarks
                .map((e) => SensitiveCategory.values[e].i18nKey.tr())
                .join(' · '),
            subtitle: 'Sensitive Content',
            hint: 'Tap to Reveal',
          ),
        ),
      ),
    );
  }
}

class _DataSavingOverlay extends StatelessWidget {
  const _DataSavingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black38,
      child: Center(
        child: _OverlayCard(
          icon: Symbols.image,
          title: 'Data Saving Mode',
          subtitle: '',
          hint: 'Tap to Load',
        ),
      ),
    );
  }
}

class _OverlayCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String hint;

  const _OverlayCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      constraints: const BoxConstraints(maxWidth: 280),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const Gap(4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const Gap(4),
          Text(hint, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}
