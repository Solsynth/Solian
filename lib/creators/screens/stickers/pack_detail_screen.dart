import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/creators/screens/stickers/pack_detail.dart';
import 'package:island/creators/screens/stickers/stickers.dart';
import 'package:island/shared/widgets/app_scaffold.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';

@RoutePage()
class CreatorStickerPackDetailScreen extends HookConsumerWidget {
  final String packId;
  final String pubName;

  const CreatorStickerPackDetailScreen({
    super.key,
    required this.packId,
    required this.pubName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(stickerPackProvider(packId));

    return AppScaffold(
      isNoBackground: true,
      appBar: AppBar(
        title: Text(pack.value?.name ?? 'loading'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Symbols.add_circle),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SheetScaffold(
                  titleText: 'createSticker'.tr(),
                  child: StickerForm(packId: packId),
                ),
              );
            },
          ),
          StickerPackActionMenu(
            pubName: pubName,
            packId: packId,
            iconShadow: Shadow(),
          ),
        ],
      ),
      body: StickerPackDetailContent(id: packId, pubName: pubName),
    );
  }
}
