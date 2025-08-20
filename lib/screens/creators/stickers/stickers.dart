import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/models/sticker.dart';
import 'package:island/pods/network.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';

part 'stickers.g.dart';

class StickersScreen extends HookConsumerWidget {
  final String pubName;
  const StickersScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('stickers').tr(),
        actions: [
          IconButton(
            onPressed: () {
              context
                  .pushNamed(
                    'creatorStickerPackNew',
                    pathParameters: {'name': pubName},
                  )
                  .then((value) {
                    if (value != null) {
                      ref.invalidate(stickerPacksNotifierProvider(pubName));
                    }
                  });
            },
            icon: const Icon(Symbols.add_circle),
          ),
          const Gap(8),
        ],
      ),
      body: SliverStickerPacksList(pubName: pubName),
    );
  }
}

class SliverStickerPacksList extends HookConsumerWidget {
  final String pubName;
  const SliverStickerPacksList({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PagingHelperView(
      provider: stickerPacksNotifierProvider(pubName),
      futureRefreshable: stickerPacksNotifierProvider(pubName).future,
      notifierRefreshable: stickerPacksNotifierProvider(pubName).notifier,
      contentBuilder:
          (data, widgetCount, endItemView) => ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: widgetCount,
            itemBuilder: (context, index) {
              if (index == widgetCount - 1) {
                return endItemView;
              }

              final sticker = data.items[index];
              return ListTile(
                title: Text(sticker.name),
                subtitle: Text(sticker.description),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () {
                  context.pushNamed(
                    'creatorStickerPackDetail',
                    pathParameters: {'name': pubName, 'packId': sticker.id},
                  );
                },
              );
            },
          ),
    );
  }
}

@riverpod
class StickerPacksNotifier extends _$StickerPacksNotifier
    with CursorPagingNotifierMixin<SnStickerPack> {
  static const int _pageSize = 20;

  @override
  Future<CursorPagingData<SnStickerPack>> build(String pubName) {
    return fetch(cursor: null);
  }

  @override
  Future<CursorPagingData<SnStickerPack>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);

    try {
      final response = await client.get(
        '/sphere/stickers',
        queryParameters: {'offset': offset, 'take': _pageSize, 'pub': pubName},
      );

      final total = int.parse(response.headers.value('X-Total') ?? '0');
      final List<dynamic> data = response.data;
      final stickers = data.map((e) => SnStickerPack.fromJson(e)).toList();

      final hasMore = offset + stickers.length < total;
      final nextCursor = hasMore ? (offset + stickers.length).toString() : null;

      return CursorPagingData(
        items: stickers,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } catch (err) {
      rethrow;
    }
  }
}

@riverpod
Future<SnStickerPack?> stickerPack(Ref ref, String? packId) async {
  if (packId == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/stickers/$packId');
  return SnStickerPack.fromJson(resp.data);
}

class NewStickerPacksScreen extends HookConsumerWidget {
  final String pubName;
  const NewStickerPacksScreen({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EditStickerPacksScreen(pubName: pubName);
  }
}

class EditStickerPacksScreen extends HookConsumerWidget {
  final String pubName;
  final String? packId;
  const EditStickerPacksScreen({super.key, required this.pubName, this.packId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>(), []);
    final initialPack = ref.watch(stickerPackProvider(packId));

    final nameController = useTextEditingController();
    final descriptionController = useTextEditingController();
    final prefixController = useTextEditingController();

    useEffect(() {
      if (initialPack.value != null) {
        nameController.text = initialPack.value!.name;
        descriptionController.text = initialPack.value!.description;
        prefixController.text = initialPack.value!.prefix;
      }
      return null;
    }, [initialPack]);

    final submitting = useState(false);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        submitting.value = true;
        final apiClient = ref.watch(apiClientProvider);
        final resp = await apiClient.request(
          '/sphere/stickers',
          data: {
            'name': nameController.text,
            'description': descriptionController.text,
            'prefix': prefixController.text,
          },
          queryParameters: {'pub': pubName},
          options: Options(method: packId == null ? 'POST' : 'PATCH'),
        );
        if (!context.mounted) return;
        context.pop(SnStickerPack.fromJson(resp.data));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return AppScaffold(
      appBar: AppBar(
        title:
            Text(packId == null ? 'createStickerPack' : 'editStickerPack').tr(),
      ),
      body: Column(
        children: [
          Form(
            key: formKey,
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'name'.tr(),
                    border: const UnderlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'fieldCannotBeEmpty'.tr();
                    }
                    return null;
                  },
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'description'.tr(),
                    border: const UnderlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 3,
                  maxLines: null,
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
                TextFormField(
                  controller: prefixController,
                  decoration: InputDecoration(
                    labelText: 'stickerPackPrefix'.tr(),
                    border: const UnderlineInputBorder(),
                    helperText: 'deleteStickerHint'.tr(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'fieldCannotBeEmpty'.tr();
                    }
                    return null;
                  },
                  onTapOutside:
                      (_) => FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ],
            ),
          ),
          const Gap(12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: submitting.value ? null : submit,
              icon: const Icon(Symbols.save),
              label: Text(packId == null ? 'create'.tr() : 'saveChanges'.tr()),
            ),
          ),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );
  }
}
