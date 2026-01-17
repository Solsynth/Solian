import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:island/widgets/content/sheet.dart';
import 'package:island/pods/config.dart';

class DashboardCustomizationSheet extends HookConsumerWidget {
  const DashboardCustomizationSheet({super.key});

  static const Map<String, Map<String, dynamic>> _cardMetadata = {
    // Vertical layout cards
    'checkIn': {'name': 'Check In', 'icon': Symbols.check_circle},
    'fortuneGraph': {'name': 'Fortune Graph', 'icon': Symbols.show_chart},
    'fortuneCard': {'name': 'Fortune', 'icon': Symbols.lightbulb},
    'postFeatured': {'name': 'Featured Posts', 'icon': Symbols.article},
    'friendsOverview': {'name': 'Friends', 'icon': Symbols.group},
    'notifications': {'name': 'Notifications', 'icon': Symbols.notifications},
    'chatList': {'name': 'Chats', 'icon': Symbols.chat},
    // Horizontal layout columns
    'activityColumn': {'name': 'Activity Column', 'icon': Symbols.dashboard, 'description': 'Check In, Fortune Graph & Fortune'},
    'postsColumn': {'name': 'Posts Column', 'icon': Symbols.article, 'description': 'Featured Posts'},
    'socialColumn': {'name': 'Social Column', 'icon': Symbols.group, 'description': 'Friends & Notifications'},
    'chatsColumn': {'name': 'Chats Column', 'icon': Symbols.chat, 'description': 'Recent Chats'},
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabController = useTabController(initialLength: 2);
    final appSettings = ref.watch(appSettingsProvider);

    // Local state for editing
    final verticalLayouts = useState<List<String>>(
      (appSettings.dashboardConfig?.verticalLayouts ?? [
        'checkIn',
        'fortuneCard',
        'postFeatured',
        'friendsOverview',
        'notifications',
        'chatList',
        'fortuneGraph',
      ]).where((id) => id != 'accountUnactivated').toList(),
    );

    final horizontalLayouts = useState<List<String>>(
      _migrateHorizontalLayouts(appSettings.dashboardConfig?.horizontalLayouts),
    );

    final showSearchBar = useState<bool>(
      appSettings.dashboardConfig?.showSearchBar ?? true,
    );

    final showClockAndCountdown = useState<bool>(
      appSettings.dashboardConfig?.showClockAndCountdown ?? true,
    );

    void saveConfig() {
      final config = DashboardConfig(
        verticalLayouts: verticalLayouts.value,
        horizontalLayouts: horizontalLayouts.value,
        showSearchBar: showSearchBar.value,
        showClockAndCountdown: showClockAndCountdown.value,
      );

      ref.read(appSettingsProvider.notifier).setDashboardConfig(config);
      Navigator.of(context).pop();
    }

    return SheetScaffold(
      titleText: 'Customize Dashboard',
      actions: [TextButton(onPressed: saveConfig, child: const Text('Save'))],
      child: Column(
        children: [
          TabBar(
            controller: tabController,
            tabs: const [
              Tab(text: 'Vertical'),
              Tab(text: 'Horizontal'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // Vertical layout
                _buildLayoutEditor(context, 'Vertical Layout', verticalLayouts, false),
                // Horizontal layout
                _buildLayoutEditor(
                  context,
                  'Horizontal Layout',
                  horizontalLayouts,
                  true,
                ),
              ],
            ),
          ),
          const Divider(),
          // Settings checkboxes
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Settings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Show Search Bar'),
                  value: showSearchBar.value,
                  onChanged: (value) {
                    if (value != null) {
                      showSearchBar.value = value;
                    }
                  },
                ),
                CheckboxListTile(
                  title: const Text('Show Clock and Countdown'),
                  value: showClockAndCountdown.value,
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
      ),
    );
  }

  List<String> _migrateHorizontalLayouts(List<String>? existingLayouts) {
    if (existingLayouts == null || existingLayouts.isEmpty) {
      // Default horizontal layout using column groups
      return ['activityColumn', 'postsColumn', 'socialColumn', 'chatsColumn'];
    }

    // If it already contains column groups, use as-is
    if (existingLayouts.any((id) => id.contains('Column'))) {
      return existingLayouts.where((id) => id != 'accountUnactivated').toList();
    }

    // Migrate from old individual card format to column groups
    // This is a simple migration - in a real app you might want more sophisticated logic
    return ['activityColumn', 'postsColumn', 'socialColumn', 'chatsColumn'];
  }

  Widget _buildLayoutEditor(
    BuildContext context,
    String title,
    ValueNotifier<List<String>> layouts,
    bool isHorizontal,
  ) {
    // Filter available cards based on layout mode
    final relevantCards = isHorizontal
        ? _cardMetadata.entries.where((entry) => entry.key.contains('Column')).map((e) => e.key).toList()
        : _cardMetadata.entries.where((entry) => !entry.key.contains('Column')).map((e) => e.key).toList();

    final availableCards =
        relevantCards.where((cardId) => !layouts.value.contains(cardId)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        // Reorderable list for cards
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            itemCount: layouts.value.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final item = layouts.value.removeAt(oldIndex);
              layouts.value.insert(newIndex, item);
              // Trigger rebuild
              layouts.value = List.from(layouts.value);
            },
            itemBuilder: (context, index) {
              final cardId = layouts.value[index];
              final metadata =
                  _cardMetadata[cardId] ??
                  {'name': cardId, 'icon': Symbols.help};

              return Card(
                key: ValueKey(cardId),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    metadata['icon'] as IconData,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(metadata['name'] as String),
                  subtitle: isHorizontal && metadata.containsKey('description')
                      ? Text(
                          metadata['description'] as String,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Symbols.drag_handle,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Symbols.close,
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          layouts.value = layouts.value.where((id) => id != cardId).toList();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Available cards to add back
        if (availableCards.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Cards',
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
                        _cardMetadata[cardId] ??
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
      ],
    );
  }
}