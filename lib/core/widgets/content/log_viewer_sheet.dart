import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/log_recorder.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';

final _logViewerStateProvider =
    NotifierProvider<_LogViewerStateNotifier, _LogViewerState>(
      _LogViewerStateNotifier.new,
    );

class _LogViewerState {
  final String searchQuery;
  final Set<Level> selectedLevels;

  const _LogViewerState({
    this.searchQuery = '',
    this.selectedLevels = const {},
  });

  _LogViewerState copyWith({String? searchQuery, Set<Level>? selectedLevels}) {
    return _LogViewerState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLevels: selectedLevels ?? this.selectedLevels,
    );
  }
}

class _LogViewerStateNotifier extends Notifier<_LogViewerState> {
  @override
  _LogViewerState build() => const _LogViewerState();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleLevel(Level level) {
    final current = state.selectedLevels;
    final updated = current.contains(level)
        ? (current.length == 1 ? <Level>{} : current.difference({level}))
        : {...current, level};
    state = state.copyWith(selectedLevels: updated);
  }

  void selectLevel(Level level) {
    state = state.copyWith(selectedLevels: {level});
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

final _filteredLogsProvider = Provider<List<LogEntry>>((ref) {
  final logs = ref.watch(logsProvider);
  final viewerState = ref.watch(_logViewerStateProvider);

  final query = viewerState.searchQuery.toLowerCase();
  final selectedLevels = viewerState.selectedLevels;

  return logs.where((entry) {
    if (selectedLevels.isNotEmpty && !selectedLevels.contains(entry.level)) {
      return false;
    }
    if (query.isNotEmpty) {
      final messageMatch = entry.message.toLowerCase().contains(query);
      final errorMatch =
          entry.error?.toString().toLowerCase().contains(query) ?? false;
      if (!messageMatch && !errorMatch) return false;
    }
    return true;
  }).toList();
});

final _allLevels = <Level>[
  Level.ALL,
  Level.FINEST,
  Level.FINER,
  Level.CONFIG,
  Level.INFO,
  Level.WARNING,
  Level.SEVERE,
  Level.SHOUT,
  Level.OFF,
];

final _levelLabels = <Level, String>{
  Level.ALL: 'All',
  Level.FINEST: 'Finest',
  Level.FINER: 'Finer',
  Level.CONFIG: 'Config',
  Level.INFO: 'Info',
  Level.WARNING: 'Warning',
  Level.SEVERE: 'Severe',
  Level.SHOUT: 'Shout',
  Level.OFF: 'Off',
};

Color _levelColor(Level level) {
  switch (level) {
    case Level.FINEST:
    case Level.FINER:
    case Level.CONFIG:
    case Level.INFO:
      return Colors.blue;
    case Level.WARNING:
      return Colors.orange;
    case Level.SEVERE:
    case Level.SHOUT:
      return Colors.red;
    case Level.ALL:
    case Level.OFF:
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

class LogViewerSheet extends ConsumerWidget {
  const LogViewerSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredLogs = ref.watch(_filteredLogsProvider);
    final viewerState = ref.watch(_logViewerStateProvider);
    final notifier = ref.read(_logViewerStateProvider.notifier);

    return SheetScaffold(
      heightFactor: 0.9,
      titleText: 'Log Viewer',
      actions: [
        IconButton(
          icon: Icon(Symbols.delete_sweep),
          tooltip: 'Clear logs',
          onPressed: () {
            ref.read(logsProvider.notifier).clear();
          },
          style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
        ),
      ],
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search logs...',
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                prefixIcon: Icon(Symbols.search, size: 20),
                suffixIcon: viewerState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Symbols.close, size: 18),
                        onPressed: () => notifier.clearSearch(),
                      )
                    : null,
              ),
              onChanged: (value) => notifier.setSearch(value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _allLevels.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final level = _allLevels[index];
                final label = _levelLabels[level]!;
                final isSelected = viewerState.selectedLevels.isEmpty
                    ? level == Level.INFO
                    : viewerState.selectedLevels.contains(level);
                return FilterChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => notifier.toggleLevel(level),
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  selectedColor: _levelColor(level).withOpacity(0.3),
                  side: BorderSide(
                    color: isSelected ? _levelColor(level) : Colors.transparent,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
            child: Row(
              children: [
                Text(
                  '${filteredLogs.length} entries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filteredLogs.isEmpty
                ? Center(
                    child: Text(
                      'No logs found',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      return _LogEntryTile(entry: filteredLogs[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LogEntryTile extends HookConsumerWidget {
  final LogEntry entry;

  const _LogEntryTile({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = useState(false);

    final hasDetails = entry.error != null || entry.stackTrace != null;

    return InkWell(
      onTap: hasDetails ? () => expanded.value = !expanded.value : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _levelColor(entry.level).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: _levelColor(entry.level).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.level.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _levelColor(entry.level),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                ),
                if (hasDetails)
                  Icon(
                    expanded.value ? Symbols.expand_less : Symbols.expand_more,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 52, top: 2),
              child: Text(
                _formatTime(entry.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (expanded.value) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.error != null) ...[
                        Text(
                          'Error:',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: Colors.red.shade300,
                              ),
                        ),
                      ],
                      if (entry.stackTrace != null) ...[
                        if (entry.error != null) const SizedBox(height: 8),
                        Text(
                          'Stack Trace:',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.stackTrace.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                fontSize: 10,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$hour:$min:$sec.$ms';
  }
}
