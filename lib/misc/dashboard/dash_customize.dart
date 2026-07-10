import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/core/config.dart';
import 'package:island/misc/dashboard/dashboard_layout.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/plugins/apis/dashboard_api.dart';
import 'package:island/plugins/icons/plugin_icon_font_registry.dart';
import 'package:island_plugin_foundation/island_plugin_foundation.dart';
import 'package:styled_widget/styled_widget.dart';

class DashboardCustomizationSheet extends HookConsumerWidget {
  const DashboardCustomizationSheet({super.key});

  static Map<String, Map<String, dynamic>> _getCardMetadata(
    BuildContext context,
  ) {
    final metadata = <String, Map<String, dynamic>>{
      'checkIn': {
        'name': 'dashboardCardCheckIn'.tr(),
        'icon': Symbols.check_circle,
      },
      'fortuneGraph': {
        'name': 'dashboardCardFortuneGraph'.tr(),
        'icon': Symbols.show_chart,
      },
      'fortuneCard': {
        'name': 'dashboardCardFortune'.tr(),
        'icon': Symbols.lightbulb,
      },
      'postFeatured': {
        'name': 'dashboardCardFeaturedPosts'.tr(),
        'icon': Symbols.article,
      },
      'friendsOverview': {
        'name': 'dashboardCardFriends'.tr(),
        'icon': Symbols.group,
      },
      'notifications': {
        'name': 'dashboardCardNotifications'.tr(),
        'icon': Symbols.notifications,
      },
      'chatList': {'name': 'dashboardCardChats'.tr(), 'icon': Symbols.chat},
    };
    for (final item
        in PluginManager().getApi<DashboardApi>()?.items ??
            const <PluginDashboardItem>[]) {
      metadata[item.layoutId] = {
        'name': item.title,
        'icon': PluginIconFontRegistry.resolve(
          name: item.icon,
          pluginId: item.pluginId,
          orElse: Symbols.extension,
        ),
        'description': item.pluginId,
      };
    }
    return metadata;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final appSettings = ref.watch(appSettingsProvider);

    // Mobile (narrow): single-column card stack
    final mobileLayouts = useState<List<String>>(
      DashboardLayout.resolveCardLayouts(
        appSettings.dashboardConfig?.verticalLayouts,
      ),
    );

    // Desktop (wide): waterfall / masonry of the same section cards
    final desktopLayouts = useState<List<String>>(
      DashboardLayout.resolveCardLayouts(
        appSettings.dashboardConfig?.horizontalLayouts,
      ),
    );

    final showSearchBar = useState<bool>(
      appSettings.dashboardConfig?.showSearchBar ?? true,
    );

    final showClockAndCountdown = useState<bool>(
      appSettings.dashboardConfig?.showClockAndCountdown ?? true,
    );

    void saveConfig() {
      final config = DashboardConfig(
        // Stored field names kept for prefs compatibility:
        // verticalLayouts = mobile, horizontalLayouts = desktop.
        verticalLayouts: mobileLayouts.value,
        horizontalLayouts: desktopLayouts.value,
        showSearchBar: showSearchBar.value,
        showClockAndCountdown: showClockAndCountdown.value,
      );

      ref.read(appSettingsProvider.notifier).setDashboardConfig(config);
      Navigator.of(context).pop();
    }

    return SheetScaffold(
      titleText: 'dashboardCustomizeTitle'.tr(),
      actions: [IconButton(onPressed: saveConfig, icon: Icon(Symbols.save))],
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              controller: tabController,
              tabs: [
                Tab(text: 'dashboardTabMobile'.tr()),
                Tab(text: 'dashboardTabDesktop'.tr()),
              ],
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _buildSliverLayoutEditor(
                          context,
                          ref,
                          'dashboardLayoutMobile'.tr(),
                          mobileLayouts,
                          showSearchBar,
                          showClockAndCountdown,
                        ),
                        _buildSliverLayoutEditor(
                          context,
                          ref,
                          'dashboardLayoutDesktop'.tr(),
                          desktopLayouts,
                          showSearchBar,
                          showClockAndCountdown,
                        ),
                      ],
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

  Widget _buildSliverLayoutEditor(
    BuildContext context,
    WidgetRef ref,
    String title,
    ValueNotifier<List<String>> layouts,
    ValueNotifier<bool> showSearchBar,
    ValueNotifier<bool> showClockAndCountdown,
  ) {
    final cardMetadata = _getCardMetadata(context);
    // Same section cards for mobile and desktop (no column groups).
    final relevantCards = cardMetadata.keys.toList();

    final availableCards = relevantCards
        .where((cardId) => !layouts.value.contains(cardId))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ).padding(horizontal: 24, top: 16, bottom: 8),
        ),
        // Reorderable list for cards
        SliverReorderableList(
          itemCount: layouts.value.length,
          itemBuilder: (context, index) {
            final cardId = layouts.value[index];
            final metadata =
                cardMetadata[cardId] ?? {'name': cardId, 'icon': Symbols.help};

            return ReorderableDragStartListener(
              key: ValueKey(cardId),
              index: index,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    metadata['icon'] as IconData,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  title: Text(metadata['name'] as String),
                  subtitle: metadata.containsKey('description')
                      ? Text(
                          metadata['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Symbols.drag_handle,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      IconButton(
                        icon: Icon(
                          Symbols.close,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          layouts.value = layouts.value
                              .where((id) => id != cardId)
                              .toList();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = layouts.value.removeAt(oldIndex);
            layouts.value.insert(newIndex, item);
            layouts.value = List.from(layouts.value);
          },
        ),
        // Available cards to add back
        if (availableCards.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'dashboardAvailableCards'.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableCards.map((cardId) {
                      final metadata =
                          cardMetadata[cardId] ??
                          {'name': cardId, 'icon': Symbols.help};
                      return ActionChip(
                        avatar: Icon(
                          metadata['icon'] as IconData,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        label: Text(metadata['name'] as String),
                        onPressed: () {
                          layouts.value = [...layouts.value, cardId];
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: Divider()),
        SliverToBoxAdapter(
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            leading: Icon(
              Symbols.restore,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text('dashboardResetToDefaults'.tr()),
            subtitle: Text('dashboardResetToDefaultsSubtitle'.tr()),
            trailing: Icon(
              Symbols.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: () async {
              final confirmed = await showConfirmAlert(
                'dashboardResetConfirmMessage'.tr(),
                'dashboardResetConfirmTitle'.tr(),
                isDanger: true,
              );

              if (confirmed) {
                ref.read(appSettingsProvider.notifier).resetDashboardConfig();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ),
        const SliverToBoxAdapter(child: Divider()),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboardDisplaySettings'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ).padding(horizontal: 24, top: 12, bottom: 8),
              CheckboxListTile(
                dense: true,
                title: Text('dashboardShowSearchBar'.tr()),
                value: showSearchBar.value,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onChanged: (value) {
                  if (value != null) {
                    showSearchBar.value = value;
                  }
                },
              ),
              CheckboxListTile(
                dense: true,
                title: Text('dashboardShowClockAndCountdown'.tr()),
                value: showClockAndCountdown.value,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onChanged: (value) {
                  if (value != null) {
                    showClockAndCountdown.value = value;
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
