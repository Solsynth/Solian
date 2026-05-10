import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';

part 'sticker_picker.g.dart';

/// Fetch user-added sticker packs (with stickers) from API:
/// GET /sphere/stickers/me
@riverpod
Future<List<SnStickerOwnership>> myStickerOwnerships(Ref ref) async {
  final client = ref.watch(solarNetworkClientProvider);
  final data = await client.stickers.getUserPacks();
  return data
      .map((e) => SnStickerOwnership.fromJson(e as Map<String, dynamic>))
      .toList();
}

@riverpod
Future<List<SnStickerPack>> myStickerPacks(Ref ref) async {
  final ownerships = await ref.watch(myStickerOwnershipsProvider.future);
  return ownerships
      .map((ownership) => ownership.pack)
      .whereType<SnStickerPack>()
      .toList();
}

/// Sticker Picker popover dialog
/// - Displays user-owned sticker packs as tabs (chips)
/// - Shows grid of stickers in selected pack
/// - On tap, returns placeholder string :{prefix}+{slug}: via onPick callback
class StickerPicker extends HookConsumerWidget {
  final void Function(SnStickerPack pack, SnSticker sticker) onPick;
  final void Function(SnStickerPack pack, SnSticker sticker)? onLongPress;

  const StickerPicker({super.key, required this.onPick, this.onLongPress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Card(
        margin: EdgeInsets.zero,
        child: _StickerPickerView(
          onPick: (pack, sticker) {
            HapticFeedback.selectionClick();
            onPick(pack, sticker);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}

class _StickerPickerView extends HookConsumerWidget {
  final void Function(SnStickerPack pack, SnSticker sticker) onPick;
  final void Function(SnStickerPack pack, SnSticker sticker)? onLongPress;

  const _StickerPickerView({required this.onPick, this.onLongPress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packsAsync = ref.watch(myStickerPacksProvider);

    return ConstrainedBox(
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

          return _PackSwitcher(
            packs: packs,
            onPick: onPick,
            onLongPress: onLongPress,
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
  final void Function(SnStickerPack pack, SnSticker sticker)? onLongPress;
  final Future<void> Function() onRefresh;

  const _PackSwitcher({
    required this.packs,
    required this.onPick,
    this.onLongPress,
    required this.onRefresh,
  });

  @override
  State<_PackSwitcher> createState() => _PackSwitcherState();
}

class _PackSwitcherState extends State<_PackSwitcher> {
  int _index = 0;

  String _packLabel(String name) =>
      name.length <= 8 ? name : '${name.substring(0, 8)}…';

  Widget _packAvatar(SnStickerPack pack) {
    final image =
        pack.icon ??
        (pack.stickers.isNotEmpty ? pack.stickers.first.image : null);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 18,
        height: 18,
        child: image != null
            ? CloudImageWidget(file: image, fit: BoxFit.cover, noBlurhash: true)
            : Icon(
                Symbols.sticky_note_2,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }

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
                  avatar: _packAvatar(packs[i]),
                  label: Text(_packLabel(packs[i].name)),
                  selected: selected,
                  showCheckmark: false,
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
              onLongPress: widget.onLongPress == null
                  ? null
                  : (sticker) => widget.onLongPress!(selectedPack, sticker),
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
  final void Function(SnSticker sticker)? onLongPress;
  final double maxCrossAxisExtent;

  const _StickersGrid({
    required this.pack,
    required this.onPick,
    this.onLongPress,
    this.maxCrossAxisExtent = 56,
  });

  @override
  Widget build(BuildContext context) {
    final stickers = pack.stickers;

    if (stickers.isEmpty) {
      return Center(child: Text('noStickersInPack'.tr()));
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: stickers.length,
      itemBuilder: (context, index) {
        final sticker = stickers[index];
        final placeholder = ':${pack.prefix}+${sticker.slug}:';
        final isEmote = sticker.mode == 1;
        return Tooltip(
          message: sticker.name?.trim().isNotEmpty == true
              ? '${sticker.name} ($placeholder)'
              : placeholder,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onPick(sticker),
            onLongPress: onLongPress == null
                ? null
                : () => onLongPress!(sticker),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CloudImageWidget(
                          file: sticker.image,
                          fit: BoxFit.contain,
                          noBlurhash: true,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color:
                                (isEmote
                                        ? Theme.of(context).colorScheme.tertiary
                                        : Theme.of(context).colorScheme.primary)
                                    .withOpacity(0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            isEmote ? Symbols.mood : Symbols.sticky_note_2,
                            size: 8,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
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
  final void Function(SnStickerPack pack, SnSticker sticker) onPick;
  final void Function(SnStickerPack pack, SnSticker sticker)? onLongPress;

  const StickerPickerEmbedded({
    super.key,
    required this.onPick,
    this.onLongPress,
    this.height,
  });

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
            HapticFeedback.selectionClick();
            onPick(pack, sticker);
          },
          onLongPress: onLongPress,
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
  final void Function(SnStickerPack pack, SnSticker sticker)? onLongPress;
  final Future<void> Function() onRefresh;

  const _EmbeddedPackSwitcher({
    required this.packs,
    required this.onPick,
    this.onLongPress,
    required this.onRefresh,
  });

  @override
  State<_EmbeddedPackSwitcher> createState() => _EmbeddedPackSwitcherState();
}

class _EmbeddedPackSwitcherState extends State<_EmbeddedPackSwitcher> {
  int _index = 0;

  String _packLabel(String name) =>
      name.length <= 8 ? name : '${name.substring(0, 8)}…';

  Widget _packAvatar(SnStickerPack pack) {
    final image =
        pack.icon ??
        (pack.stickers.isNotEmpty ? pack.stickers.first.image : null);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 18,
        height: 18,
        child: image != null
            ? CloudImageWidget(file: image, fit: BoxFit.cover, noBlurhash: true)
            : Icon(
                Symbols.sticky_note_2,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final packs = widget.packs;
    _index = _index.clamp(0, packs.length - 1);

    final selectedPack = packs[_index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Gap(8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: packs.length,
            separatorBuilder: (_, _) => const Gap(4),
            itemBuilder: (context, i) {
              final selected = _index == i;
              return Tooltip(
                message: packs[i].name,
                child: FilterChip(
                  avatar: _packAvatar(packs[i]),
                  label: Text(_packLabel(packs[i].name)),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() => _index = i);
                    HapticFeedback.selectionClick();
                  },
                ),
              );
            },
          ),
        ),

        // Content
        Expanded(
          child: ExtendedRefreshIndicator(
            onRefresh: widget.onRefresh,
            child: _StickersGrid(
              pack: selectedPack,
              onPick: (sticker) => widget.onPick(selectedPack, sticker),
              onLongPress: widget.onLongPress == null
                  ? null
                  : (sticker) => widget.onLongPress!(selectedPack, sticker),
              maxCrossAxisExtent: 96,
            ).padding(horizontal: 2, top: 4),
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
  required void Function(SnStickerPack pack, SnSticker sticker) onPick,
  void Function(SnStickerPack pack, SnSticker sticker)? onLongPress,
}) async {
  // Use flutter_popup_card to present the anchored popup near trigger.
  await showPopupCard<void>(
    context: context,
    offset: offset,
    alignment: alignment ?? Alignment.topLeft,
    dimBackground: true,
    builder: (ctx) => PopupCard(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: SizedBox(
        width: math.min(480, MediaQuery.of(context).size.width * 0.9),
        height: 480,
        child: ProviderScope(
          child: _StickerPickerView(onPick: onPick, onLongPress: onLongPress),
        ),
      ),
    ),
  );
}
