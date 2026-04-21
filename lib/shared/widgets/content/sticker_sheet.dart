import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:island/stickers/screens/pack_detail.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sticker_sheet.g.dart';

/// Shows a sticker pack info sheet when a sticker is tapped
void showStickerPackSheet(
  BuildContext context,
  String packPrefix,
  String stickerCode,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => StickerPackSheet(
      packPrefix: packPrefix,
      tappedStickerCode: stickerCode,
    ),
  );
}

/// Compact sticker pack info sheet shown when tapping a sticker
class StickerPackSheet extends HookConsumerWidget {
  final String packPrefix;
  final String tappedStickerCode;

  const StickerPackSheet({
    super.key,
    required this.packPrefix,
    required this.tappedStickerCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(stickerPackByPrefixProvider(packPrefix));

    return SheetScaffold(
      titleText: 'Sticker Pack',
      heightFactor: 0.6,
      child: packAsync.when(
        data: (pack) {
          if (pack == null) {
            return const Center(child: Text('Pack not found'));
          }
          return StickerPackCompactView(
            pack: pack,
            tappedStickerCode: tappedStickerCode,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Provider to fetch sticker pack by prefix
@riverpod
Future<SnStickerPack?> stickerPackByPrefix(Ref ref, String prefix) async {
  if (prefix.isEmpty) return null;
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.get('/sphere/stickers/by-prefix/$prefix');
    return SnStickerPack.fromJson(response.data);
  } catch (e) {
    return null;
  }
}

/// Provider to fetch stickers in a pack
@riverpod
Future<List<SnSticker>> stickerPackContent(Ref ref, String packId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.get('/sphere/stickers/$packId/content');
  return (response.data as List<dynamic>)
      .map((json) => SnSticker.fromJson(json as Map<String, dynamic>))
      .toList();
}

/// Provider to check if user owns the sticker pack
@riverpod
Future<bool> stickerPackOwnership(Ref ref, String packId) async {
  final client = ref.watch(apiClientProvider);
  try {
    await client.get('/sphere/stickers/$packId/own');
    // If not 404, consider owned
    return true;
  } on Object catch (e) {
    // Dio error handling agnostic: treat 404 as not-owned, rethrow others
    final msg = e.toString();
    if (msg.contains('404')) return false;
    rethrow;
  }
}

/// Compact view of sticker pack info for the sheet
class StickerPackCompactView extends HookConsumerWidget {
  final SnStickerPack pack;
  final String tappedStickerCode;

  const StickerPackCompactView({
    super.key,
    required this.pack,
    required this.tappedStickerCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final stickersAsync = ref.watch(stickerPackContentProvider(pack.id));
    final ownedAsync = ref.watch(marketplaceStickerPackOwnershipProvider(packId: pack.id));

    // Add entire pack to user's collection
    Future<void> addPackToMyCollection() async {
      final client = ref.read(apiClientProvider);
      await client.post('/sphere/stickers/${pack.id}/own');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceStickerPackOwnershipProvider(packId: pack.id));
      if (!context.mounted) return;
      showSnackBar('stickerPackAdded'.tr());
    }

    // Remove ownership of the pack
    Future<void> removePackFromMyCollection() async {
      final client = ref.read(apiClientProvider);
      await client.delete('/sphere/stickers/${pack.id}/own');
      HapticFeedback.selectionClick();
      ref.invalidate(marketplaceStickerPackOwnershipProvider(packId: pack.id));
      if (!context.mounted) return;
      showSnackBar('stickerPackRemoved'.tr());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pack info header
        Card.filled(
          margin: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 16,
              children: [
                // Pack icon
                Card.outlined(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: pack.icon != null
                          ? CloudImageWidget(
                              file: pack.icon!,
                              fit: BoxFit.cover,
                              noBlurhash: true,
                            )
                          : Icon(
                              Symbols.folder,
                              size: 28,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                    ),
                  ),
                ),
                // Pack details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        pack.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pack.description.isNotEmpty)
                        Text(
                          pack.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      // Metadata row
                      Wrap(
                        spacing: 8,
                        children: [
                          CompactMetadataChip(
                            icon: Symbols.sell,
                            label: pack.prefix,
                          ),
                          stickersAsync.when(
                            data: (stickers) => CompactMetadataChip(
                              icon: Symbols.folder,
                              label: '${stickers.length} stickers',
                            ),
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Stickers preview grid
        Expanded(
          child: stickersAsync.when(
            data: (stickers) {
              if (stickers.isEmpty) {
                return const Center(child: Text('No stickers in this pack'));
              }
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 72,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: stickers.length,
                itemBuilder: (context, index) {
                  final sticker = stickers[index];
                  final stickerCode = ':${pack.prefix}+${sticker.slug}:';
                  final isTappedSticker = stickerCode == tappedStickerCode;

                  return Tooltip(
                    message: stickerCode,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: isTappedSticker
                            ? Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              )
                            : null,
                      ),
                      child: Card.outlined(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            color: theme.colorScheme.surfaceContainerLow,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: CloudImageWidget(
                                file: sticker.image,
                                fit: BoxFit.contain,
                                noBlurhash: true,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
        // Add/Remove pack button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ownedAsync.when(
            data: (isOwned) => FilledButton.icon(
              onPressed: isOwned
                  ? removePackFromMyCollection
                  : addPackToMyCollection,
              icon: Icon(isOwned ? Symbols.remove_circle : Symbols.add_circle),
              label: Text(isOwned ? 'removePack'.tr() : 'addPack'.tr()),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            loading: () => const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => OutlinedButton.icon(
              onPressed: addPackToMyCollection,
              icon: const Icon(Symbols.add_circle),
              label: Text('addPack').tr(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact metadata chip for the sheet
class CompactMetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const CompactMetadataChip({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      visualDensity: VisualDensity.compact,
    );
  }
}
