import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/board.dart';
import 'package:island/accounts/widgets/account/board_custom_widget_sheet.dart';
import 'package:island/core/network.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/alert.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:styled_widget/styled_widget.dart';

part 'board_edit.g.dart';

enum _EditorItemType { prebuilt, custom }

class _EditorItem {
  final String key;
  final _EditorItemType type;
  final String? prebuiltKey;
  final int? customIndex;

  const _EditorItem.prebuilt(this.prebuiltKey)
    : key = 'p_$prebuiltKey',
      type = _EditorItemType.prebuilt,
      customIndex = null;

  const _EditorItem.custom(this.customIndex)
    : key = 'c_$customIndex',
      type = _EditorItemType.custom,
      prebuiltKey = null;
}

List<_EditorItem> _buildEditorItems(
  Map<String, bool> prebuilt,
  List<AccountBoardItem> custom,
  List<String>? itemOrder,
) {
  if (itemOrder != null) {
    final items = <_EditorItem>[];
    final seenPrebuilt = <String>{};
    final seenCustom = <int>{};

    for (final key in itemOrder) {
      if (key.startsWith('p_')) {
        final prebuiltKey = key.substring(2);
        if (prebuilt.containsKey(prebuiltKey) && seenPrebuilt.add(prebuiltKey)) {
          items.add(_EditorItem.prebuilt(prebuiltKey));
        }
      } else if (key.startsWith('c_')) {
        final customIndex = int.tryParse(key.substring(2));
        if (customIndex != null &&
            customIndex >= 0 &&
            customIndex < custom.length &&
            seenCustom.add(customIndex)) {
          items.add(_EditorItem.custom(customIndex));
        }
      }
    }

    for (final key in prebuilt.keys) {
      if (seenPrebuilt.add(key)) {
        items.add(_EditorItem.prebuilt(key));
      }
    }
    for (var i = 0; i < custom.length; i++) {
      if (seenCustom.add(i)) {
        items.add(_EditorItem.custom(i));
      }
    }

    return items;
  }

  final items = <_EditorItem>[];
  for (final key in prebuilt.keys) {
    items.add(_EditorItem.prebuilt(key));
  }
  for (var i = 0; i < custom.length; i++) {
    items.add(_EditorItem.custom(i));
  }
  return items;
}

List<AccountBoardItem> _buildPreviewItems(
  (Map<String, bool>, List<AccountBoardItem>, List<String>) boardState,
) {
  final items = <AccountBoardItem>[];
  final editorItems = _buildEditorItems(boardState.$1, boardState.$2, boardState.$3);

  for (final editorItem in editorItems) {
    if (editorItem.type == _EditorItemType.prebuilt) {
      final key = editorItem.prebuiltKey!;
      items.add(
        AccountBoardItem(
          order: items.length,
          kind: BoardWidgetKind.prebuilt,
          widgetKey: key,
          isEnabled: boardState.$1[key] ?? false,
        ),
      );
    } else {
      items.add(boardState.$2[editorItem.customIndex!].copyWith(order: items.length));
    }
  }

  return items;
}

@riverpod
class BoardEditorState extends _$BoardEditorState {
  @override
  (Map<String, bool>, List<AccountBoardItem>, List<String>) build() {
    return (
      {
        'activity': true,
        'badges': true,
        'leveling': true,
        'social_credits': true,
        'contacts': true,
        'publishers': true,
        'notable_days': true,
        'verification': true,
        'fortune': true,
      },
      const [],
      const [
        'p_activity',
        'p_badges',
        'p_leveling',
        'p_social_credits',
        'p_contacts',
        'p_publishers',
        'p_notable_days',
        'p_verification',
        'p_fortune',
      ],
    );
  }

  Map<String, bool> get prebuilt => state.$1;
  List<AccountBoardItem> get customItems => state.$2;
  List<String> get itemOrder => state.$3;

  void reorder(int oldIndex, int newIndex) {
    final items = _buildEditorItems(state.$1, state.$2, state.$3);
    if (newIndex > oldIndex) newIndex--;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    final newPrebuilt = <String, bool>{};
    final newCustom = <AccountBoardItem>[];
    final newOrder = <String>[];

    for (final item in items) {
      if (item.type == _EditorItemType.prebuilt) {
        newPrebuilt[item.prebuiltKey!] = state.$1[item.prebuiltKey]!;
        newOrder.add(item.key);
      } else {
        final newCustomIndex = newCustom.length;
        newCustom.add(state.$2[item.customIndex!].copyWith(order: newCustomIndex));
        newOrder.add('c_$newCustomIndex');
      }
    }

    state = (newPrebuilt, newCustom, newOrder);
  }

  void toggle(String key) {
    final newPrebuilt = Map<String, bool>.from(state.$1)
      ..[key] = !state.$1[key]!;
    state = (newPrebuilt, state.$2, state.$3);
  }

  void addCustom(AccountBoardItem item) {
    final newOrder = state.$2.length;
    state = (
      state.$1,
      [...state.$2, item.copyWith(order: newOrder)],
      [...state.$3, 'c_$newOrder'],
    );
  }

  void removeCustom(int index) {
    final items = [...state.$2];
    items.removeAt(index);
    for (var i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(order: i);
    }
    final newOrder = <String>[];
    for (final key in state.$3) {
      if (!key.startsWith('c_')) {
        newOrder.add(key);
        continue;
      }
      final customIndex = int.tryParse(key.substring(2));
      if (customIndex == null || customIndex == index) continue;
      newOrder.add('c_${customIndex > index ? customIndex - 1 : customIndex}');
    }
    state = (state.$1, items, newOrder);
  }

  void reset() {
    state = (
      {
        'activity': true,
        'badges': true,
        'leveling': true,
        'social_credits': true,
        'contacts': true,
        'publishers': true,
        'notable_days': true,
        'verification': true,
        'fortune': true,
      },
      const [],
      const [
        'p_activity',
        'p_badges',
        'p_leveling',
        'p_social_credits',
        'p_contacts',
        'p_publishers',
        'p_notable_days',
        'p_verification',
        'p_fortune',
      ],
    );
  }

  Future<void> loadFromServer() async {
    try {
      final dio = ref.read(apiClientProvider);
      final response = await dio.get('/passport/accounts/me/board');
      final defaultPrebuilt = <String, bool>{
        'activity': false,
        'badges': false,
        'leveling': false,
        'social_credits': false,
        'contacts': false,
        'publishers': false,
        'notable_days': false,
        'verification': false,
        'fortune': false,
      };
      final list = response.data as List<dynamic>;
      final parsedItems = parseAccountBoardItems(list);
      final custom = <AccountBoardItem>[];

      for (final item in parsedItems) {
        if (item.kind == BoardWidgetKind.prebuilt) {
          final key = item.widgetKey;
          if (key != null && defaultPrebuilt.containsKey(key)) {
            defaultPrebuilt[key] = item.isEnabled;
          }
        } else if (item.kind == BoardWidgetKind.customApp) {
          custom.add(item);
        }
      }

      final orderedPrebuilt = <String, bool>{};
      final mixedOrder = <String>[];
      var customOrderIndex = 0;
      for (final json in list) {
        final map = json as Map<String, dynamic>;
        final kind = map['kind'] as int;
        if (kind == 0) {
          final key = map['widget_key'] as String;
          if (!orderedPrebuilt.containsKey(key) &&
              defaultPrebuilt.containsKey(key)) {
            orderedPrebuilt[key] = defaultPrebuilt[key]!;
          }
          mixedOrder.add('p_$key');
        } else if (kind == 1) {
          mixedOrder.add('c_${customOrderIndex++}');
        }
      }
      for (final key in defaultPrebuilt.keys) {
        if (!orderedPrebuilt.containsKey(key)) {
          orderedPrebuilt[key] = defaultPrebuilt[key]!;
        }
      }

      custom.sort((a, b) => a.order.compareTo(b.order));
      for (var i = 0; i < custom.length; i++) {
        custom[i] = custom[i].copyWith(order: i);
      }

      final normalizedOrder = <String>[];
      customOrderIndex = 0;
      for (final key in mixedOrder) {
        if (key.startsWith('p_')) {
          normalizedOrder.add(key);
        } else if (key.startsWith('c_') && customOrderIndex < custom.length) {
          normalizedOrder.add('c_${customOrderIndex++}');
        }
      }
      for (final key in orderedPrebuilt.keys) {
        if (!normalizedOrder.contains('p_$key')) {
          normalizedOrder.add('p_$key');
        }
      }

      state = (orderedPrebuilt, custom, normalizedOrder);
    } catch (_) {}
  }
}

class _PrebuiltWidgetMeta {
  const _PrebuiltWidgetMeta();

  static const _widgets = <String, _WidgetInfo>{
    'activity': _WidgetInfo(
      Symbols.podcasts,
      'activityPresence',
      'activityBoardDescription',
    ),
    'badges': _WidgetInfo(Symbols.stars, 'badges', 'badgesBoardDescription'),
    'leveling': _WidgetInfo(
      Symbols.trending_up,
      'leveling',
      'levelingBoardDescription',
    ),
    'social_credits': _WidgetInfo(
      Symbols.attribution,
      'socialCredits',
      'socialCreditsBoardDescription',
    ),
    'contacts': _WidgetInfo(
      Symbols.contact_phone,
      'contactMethod',
      'contactsBoardDescription',
    ),
    'publishers': _WidgetInfo(
      Symbols.smart_toy,
      'publishers',
      'publishersBoardDescription',
    ),
    'notable_days': _WidgetInfo(
      Symbols.calendar_today,
      'notableDay',
      'notableDaysBoardDescription',
    ),
    'verification': _WidgetInfo(
      Symbols.verified,
      'verification',
      'verificationBoardDescription',
    ),
    'fortune': _WidgetInfo(
      Symbols.auto_awesome,
      'fortuneGraph',
      'fortuneBoardDescription',
    ),
  };

  String name(String key) => _widgets[key]?.name ?? key;
  IconData icon(String key) => _widgets[key]?.icon ?? Symbols.question_mark;
  String description(String key) => _widgets[key]?.description ?? '';
}

class _WidgetInfo {
  final IconData icon;
  final String name;
  final String description;
  const _WidgetInfo(this.icon, this.name, this.description);
}

@RoutePage()
class AccountBoardEditScreen extends HookConsumerWidget {
  const AccountBoardEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardState = ref.watch(boardEditorStateProvider);
    final userInfo = ref.watch(userInfoProvider);

    final theme = Theme.of(context);
    final showPreview = useState(false);

    useEffect(() {
      ref.read(boardEditorStateProvider.notifier).loadFromServer();
      return null;
    }, []);

    final items = _buildPreviewItems(boardState);

    return AppScaffold(
      appBar: AppBar(
        title: Text('editBoard').tr(),
        leading: const AutoLeadingButton(),
        actions: [
          IconButton(
            onPressed: () => showPreview.value = !showPreview.value,
            icon: Icon(
              showPreview.value ? Symbols.visibility : Symbols.visibility_off,
            ),
            tooltip: 'preview'.tr(),
          ),
          IconButton(
            onPressed: () {
              ref.read(boardEditorStateProvider.notifier).reset();
            },
            icon: const Icon(Symbols.restart_alt),
            tooltip: 'dashboardResetToDefaults'.tr(),
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: showPreview.value
          ? null
          : FloatingActionButton(
              onPressed: () => _saveBoard(context, ref),
              child: const Icon(Symbols.check),
            ),
      body: userInfo.when(
        data: (data) => data == null
            ? Center(child: Text('loginToAccessDashboard'.tr()))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        'boardEditTitle'.tr(),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ).center(),
                    ),
                  ),
                  Expanded(
                    child: showPreview.value
                        ? _buildPreview(context, data, items)
                        : _buildEditor(context, ref, theme),
                  ),
                ],
              ),
        error: (error, _) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _saveBoard(BuildContext context, WidgetRef ref) async {
    final boardState = ref.read(boardEditorStateProvider);
    final customItems = boardState.$2;
    final editorItems = _buildEditorItems(boardState.$1, customItems, boardState.$3);

    final items = <Map<String, dynamic>>[];
    var order = 0;

    for (final item in editorItems) {
      if (item.type == _EditorItemType.prebuilt) {
        final key = item.prebuiltKey!;
        final isEnabled = boardState.$1[key]!;
        items.add({
          'order': order++,
          'kind': 0,
          'widget_key': key,
          'is_enabled': isEnabled,
          'payload': <String, dynamic>{},
        });
      } else {
        final customItem = customItems[item.customIndex!];
        items.add({...customItem.toJson(), 'order': order++, 'kind': 1});
      }
    }

    try {
      showLoadingModal(context);
      final dio = ref.read(apiClientProvider);
      await dio.put('/passport/accounts/me/board', data: items);
      ref.invalidate(myAccountBoardProvider);
      if (context.mounted) {
        hideLoadingModal(context);
        showSnackBar('settingsSaved'.tr());
      }
    } catch (err) {
      if (context.mounted) {
        hideLoadingModal(context);
        showErrorAlert(err);
      }
    }
  }

  Widget _buildEditor(BuildContext context, WidgetRef ref, ThemeData theme) {
    final boardState = ref.watch(boardEditorStateProvider);
    final notifier = ref.read(boardEditorStateProvider.notifier);

    final allPrebuiltKeys = boardState.$1.keys.toList();
    final enabledKeys = boardState.$1.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final customItems = boardState.$2;
    final items = _buildEditorItems(boardState.$1, customItems, boardState.$3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            itemCount: items.length,
            onReorder: notifier.reorder,
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surfaceContainerHighest,
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final item = items[index];
              if (item.type == _EditorItemType.custom) {
                return _buildCustomItem(
                  context,
                  theme,
                  customItems[item.customIndex!],
                  item.customIndex!,
                  notifier,
                  index,
                );
              }
              return _buildPrebuiltItem(
                context,
                theme,
                item.prebuiltKey!,
                boardState.$1,
                allPrebuiltKeys,
                enabledKeys,
                notifier,
                index,
              );
            },
          ),
        ),
        Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: FilledButton.icon(
              onPressed: () async {
                final myId = ref.read(userInfoProvider).value?.id;
                if (myId == null) return;
                final result = await showModalBottomSheet<AccountBoardItem?>(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => AddCustomWidgetSheet(accountId: myId),
                );
                if (result != null) {
                  notifier.addCustom(result);
                }
              },
              icon: const Icon(Symbols.add, size: 18),
              label: Text('boardAddCustomWidget'.tr()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrebuiltItem(
    BuildContext context,
    ThemeData theme,
    String key,
    Map<String, bool> prebuiltState,
    List<String> allPrebuiltKeys,
    List<String> enabledKeys,
    BoardEditorState notifier,
    int index,
  ) {
    final isEnabled = prebuiltState[key] ?? false;
    final orderIndex = isEnabled ? enabledKeys.indexOf(key) : null;

    return Card(
      key: ValueKey('p_$key'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Symbols.drag_handle, size: 20),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isEnabled
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _PrebuiltWidgetMeta._widgets[key]?.icon ??
                    Symbols.question_mark,
                size: 18,
                color: isEnabled
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _PrebuiltWidgetMeta._widgets[key]?.name.tr() ?? key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isEnabled
                              ? null
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (orderIndex != null) ...[
                        const Gap(6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${orderIndex + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _PrebuiltWidgetMeta._widgets[key]?.description.tr() ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: isEnabled, onChanged: (_) => notifier.toggle(key)),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomItem(
    BuildContext context,
    ThemeData theme,
    AccountBoardItem item,
    int customIndex,
    BoardEditorState notifier,
    int index,
  ) {
    return Card(
      key: ValueKey('c_$customIndex'),
      margin: const EdgeInsets.only(bottom: 8),
      child: Consumer(
        builder: (context, ref, _) {
          final definitionAsync = ref.watch(
            boardWidgetDefinitionProvider((
              appId: item.customAppId ?? '',
              widgetKey: item.customAppWidgetKey ?? '',
            )),
          );
          final definition = definitionAsync.asData?.value?.definition;
          final title =
              definition?.name ??
              item.customAppWidgetKey ??
              'boardCustomWidget'.tr();
          final subtitle =
              definition?.description?.trim().isNotEmpty == true
              ? definition!.description!
              : item.payload.isEmpty
              ? 'boardWidgetNotConfigured'.tr()
              : 'boardCustomAppWidgetDescription'.tr();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Symbols.drag_handle, size: 20),
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Symbols.extension,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Symbols.delete, size: 18),
                  color: theme.colorScheme.error,
                  onPressed: () => notifier.removeCustom(customIndex),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    SnAccount account,
    List<AccountBoardItem> items,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: AccountBoard(
        account: account,
        items: items,
        uname: account.name,
        publishers: const [],
      ),
    );
  }
}
