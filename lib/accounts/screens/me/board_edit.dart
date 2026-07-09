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
) {
  final items = <_EditorItem>[];
  for (final key in prebuilt.keys) {
    items.add(_EditorItem.prebuilt(key));
  }
  for (var i = 0; i < custom.length; i++) {
    items.add(_EditorItem.custom(i));
  }
  return items;
}

@riverpod
class BoardEditorState extends _$BoardEditorState {
  @override
  (Map<String, bool>, List<AccountBoardItem>) build() {
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
    );
  }

  Map<String, bool> get prebuilt => state.$1;
  List<AccountBoardItem> get customItems => state.$2;

  void reorder(int oldIndex, int newIndex) {
    final items = _buildEditorItems(state.$1, state.$2);
    if (newIndex > oldIndex) newIndex--;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);

    final newPrebuilt = <String, bool>{};
    final newCustom = <AccountBoardItem>[];
    var customOrder = 0;

    for (final item in items) {
      if (item.type == _EditorItemType.prebuilt) {
        newPrebuilt[item.prebuiltKey!] = state.$1[item.prebuiltKey]!;
      } else {
        newCustom.add(
          state.$2[item.customIndex!].copyWith(order: customOrder++),
        );
      }
    }

    state = (newPrebuilt, newCustom);
  }

  void toggle(String key) {
    final newPrebuilt = Map<String, bool>.from(state.$1)
      ..[key] = !state.$1[key]!;
    state = (newPrebuilt, state.$2);
  }

  void addCustom(AccountBoardItem item) {
    final newOrder = state.$2.length;
    state = (state.$1, [...state.$2, item.copyWith(order: newOrder)]);
  }

  void removeCustom(int index) {
    final items = [...state.$2];
    items.removeAt(index);
    for (var i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(order: i);
    }
    state = (state.$1, items);
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
    );
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

    final enabledKeys = boardState.$1.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    final prebuiltItems = enabledKeys.asMap().entries.map((e) {
      return AccountBoardItem(
        order: e.key,
        kind: BoardWidgetKind.prebuilt,
        widgetKey: e.value,
      );
    }).toList();
    final customItems = boardState.$2;
    final items = [
      ...prebuiltItems,
      ...customItems.asMap().entries.map(
        (e) => e.value.copyWith(order: prebuiltItems.length + e.key),
      ),
    ];

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
    final editorItems = _buildEditorItems(boardState.$1, customItems);

    final items = <Map<String, dynamic>>[];
    var order = 0;

    for (final item in editorItems) {
      if (item.type == _EditorItemType.prebuilt) {
        final key = item.prebuiltKey!;
        final isEnabled = boardState.$1[key]!;
        items.add({
          'order': order++,
          'kind': 'prebuilt',
          'widget_key': key,
          'is_enabled': isEnabled,
          'payload': <String, dynamic>{},
        });
      } else {
        final customItem = customItems[item.customIndex!];
        items.add(customItem.copyWith(order: order++).toJson());
      }
    }

    try {
      showLoadingModal(context);
      final dio = ref.read(apiClientProvider);
      await dio.put('/passport/accounts/me/board', data: items);
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
    final items = _buildEditorItems(boardState.$1, customItems);

    return Column(
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
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
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
            Switch(
              value: isEnabled,
              onChanged: (_) => notifier.toggle(key),
            ),
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
                    item.customAppWidgetKey ?? 'boardCustomWidget'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'boardWidgetNotConfigured'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
