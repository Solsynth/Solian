import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/stickers/stickers_models/sticker.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/drive_widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';

part 'sticker_picker.g.dart';

/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me
@riverpod
Future<List<SnStickerPack>> myStickerPacks(Ref ref) async {
  final api = ref.watch(apiClientProvider);
  final resp = await api.get('/sphere/stickers/me');
  final data = resp.data;
  if (data is List) {
    return data
        .map((e) => SnStickerPack.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return const <SnStickerPack>[];
}

/// Sticker Picker popover dialog
/// - Displays user-owned sticker packs as tabs (chips)
/// - Shows grid of stickers in selected pack
/// - On tap, returns placeholder string :{prefix}+{slug}: via onPick callback
class StickerPicker extends HookConsumerWidget {
  final void Function(String placeholder) onPick;

  const StickerPicker({super.key, required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(myStickerPacksProvider);

    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 520),
        child: packsAsync.when(
          data: (packs) {
            if (packs.isEmpty) {
              return _EmptyState(
                onRefresh: () async {
                  ref.invalidate(myStickerPacksProvider);
                },
              );
            }

            // Maintain selected index locally with a ValueNotifier to avoid hooks dependency
            return _PackSwitcher(
              packs: packs,
              onPick: (pack, sticker) {
                final placeholder = ':${pack.prefix}+${sticker.slug}:';
                HapticFeedback.selectionClick();
                onPick(placeholder);
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              onRefresh: () async {
                ref.invalidate(myStickerPacksProvider);
              },
            );
          },
          loading: () => const SizedBox(
            width: 320,
            height: 320,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => SizedBox(
            width: 360,
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Symbols.error, size: 28),
                const Gap(8),
                Text('Error: $err', textAlign: TextAlign.center),
                const Gap(12),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(myStickerPacksProvider),
                  icon: const Icon(Symbols.refresh),
                  label: Text('retry').tr(),
                ),
              ],
            ).padding(all: 16),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;
  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Symbols.emoji_symbols, size: 28),
          const Gap(8),
          Text('noStickerPacks'.tr(), textAlign: TextAlign.center),
          const Gap(12),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Symbols.refresh),
            label: Text('refresh').tr(),
          ),
        ],
      ).padding(all: 16),
    );
  }
}

class _PackSwitcher extends StatefulWidget {
  final List<SnStickerPack> packs;
  final void Function(SnStickerPack pack, SnSticker sticker) onPick;
  final Future<void> Function() onRefresh;

  const _PackSwitcher({
    required this.packs,
    required this.onPick,
    required this.onRefresh,
  });

  @override
  State<_PackSwitcher> createState() => _PackSwitcherState();
}

class _PackSwitcherState extends State<_PackSwitcher> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final packs = widget.packs;
    _index = _index.clamp(0, packs.length - 1);

    final selectedPack = packs[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          children: [
            const Icon(Symbols.sticky_note_2, size: 20),
            const Gap(8),
            Text(
              'stickers'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              tooltip: 'close'.tr(),
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Symbols.close),
            ),
          ],
        ).padding(horizontal: 12, top: 8),

        // Vertical, scrollable packs rail like common emoji pickers
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: packs.length,
            separatorBuilder: (_, _) => const Gap(4),
            itemBuilder: (context, i) {
              final selected = _index == i;
              return Tooltip(
                message: packs[i].name,
                child: FilterChip(
                  label: Text(packs[i].name, overflow: TextOverflow.ellipsis),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _index = i);
                    HapticFeedback.selectionClick();
                  },
                ),
              );
            },
          ),
        ).padding(bottom: 8),
        const Divider(height: 1),

        // Content
        Expanded(
          child: ExtendedRefreshIndicator(
            onRefresh: widget.onRefresh,
            child: _StickersGrid(
              pack: selectedPack,
              onPick: (sticker) => widget.onPick(selectedPack, sticker),
            ),
          ),
        ),
      ],
    );
  }
}

class _StickersGrid extends StatelessWidget {
  final SnStickerPack pack;
  final void Function(SnSticker sticker) onPick;

  const _StickersGrid({required this.pack, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final stickers = pack.stickers;

    if (stickers.isEmpty) {
      return Center(child: Text('noStickersInPack'.tr()));
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 56,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        final placeholder = ':${pack.prefix}+${sticker.slug}:';
        return Tooltip(
          message: placeholder,
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            onTap: () => onPick(sticker),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CloudImageWidget(
                    file: sticker.image,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Embedded Sticker Picker variant
/// No background card, no title header, suitable for embedding in other UI
class StickerPickerEmbedded extends HookConsumerWidget {
  final double? height;
  final void Function(String placeholder) onPick;

  const StickerPickerEmbedded({super.key, required this.onPick, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(myStickerPacksProvider);

    return packsAsync.when(
      data: (packs) {
        if (packs.isEmpty) {
          return _EmptyState(
            onRefresh: () async {
              ref.invalidate(myStickerPacksProvider);
            },
          );
        }

        return _EmbeddedPackSwitcher(
          packs: packs,
          onPick: (pack, sticker) {
            final placeholder = ':${pack.prefix}+${sticker.slug}:';
            HapticFeedback.selectionClick();
            onPick(placeholder);
          },
          onRefresh: () async {
            ref.invalidate(myStickerPacksProvider);
          },
        );
      },
      loading: () => SizedBox(
        width: 320,
        height: height ?? 320,
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => SizedBox(
        width: 360,
        height: height ?? 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Symbols.error, size: 28),
            const Gap(8),
            Text('Error: $err', textAlign: TextAlign.center),
            const Gap(12),
            FilledButton.icon(
              onPressed: () => ref.invalidate(myStickerPacksProvider),
              icon: const Icon(Symbols.refresh),
              label: Text('retry').tr(),
            ),
          ],
        ).padding(all: 16),
      ),
    );
  }
}

class _EmbeddedPackSwitcher extends StatefulWidget {
  final List<SnStickerPack> packs;
  final void Function(SnStickerPack pack, SnSticker sticker) onPick;
  final Future<void> Function() onRefresh;

  const _EmbeddedPackSwitcher({
    required this.packs,
    required this.onPick,
    required this.onRefresh,
  });

  @override
  State<_EmbeddedPackSwitcher> createState() => _EmbeddedPackSwitcherState();
}

class _EmbeddedPackSwitcherState extends State<_EmbeddedPackSwitcher> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final packs = widget.packs;
    _index = _index.clamp(0, packs.length - 1);

    final selectedPack = packs[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(12),
        // Vertical, scrollable packs rail like common emoji pickers
        Card(
          margin: EdgeInsets.zero,
          child: SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: packs.length,
              separatorBuilder: (_, _) => const Gap(4),
              itemBuilder: (context, i) {
                final selected = _index == i;
                return Tooltip(
                  message: packs[i].name,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: selected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 4,
                            )
                          : null,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      onTap: () {
                        setState(() => _index = i);
                        HapticFeedback.selectionClick();
                      },
                      child: TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: selected ? 4 : 8),
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        builder: (context, value, _) {
                          return packs[i].icon != null
                              ? CloudImageWidget(
                                  file: packs[i].icon!,
                                ).clipRRect(all: value)
                              : CloudImageWidget(
                                  file: packs[i].stickers.firstOrNull?.image,
                                ).clipRRect(all: value);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ).padding(vertical: 4),
        ).padding(horizontal: 12),

        // Content
        Expanded(
          child: ExtendedRefreshIndicator(
            onRefresh: widget.onRefresh,
            child: _StickersGrid(
              pack: selectedPack,
              onPick: (sticker) => widget.onPick(selectedPack, sticker),
            ).padding(horizontal: 2),
          ),
        ),
      ],
    );
  }
}

/// Helper to show sticker picker as an anchored popover near the trigger.
/// Provide the button's BuildContext (typically from the onPressed closure).
/// Fallbacks to dialog if overlay cannot be found (e.g., during tests).
Future<void> showStickerPickerPopover(
  BuildContext context,
  Offset offset, {
  Alignment? alignment,
  required void Function(String placeholder) onPick,
}) async {
  // Use flutter_popup_card to present the anchored popup near trigger.
  await showPopupCard<void>(
    context: context,
    offset: offset,
    alignment: alignment ?? Alignment.topLeft,
    dimBackground: true,
    builder: (ctx) => SizedBox(
      width: math.min(480, MediaQuery.of(context).size.width * 0.9),
      height: 480,
      child: ProviderScope(
        child: StickerPicker(
          onPick: (ph) {
            onPick(ph);
            Navigator.of(ctx).maybePop();
          },
        ),
      ),
    ),
  );
}
