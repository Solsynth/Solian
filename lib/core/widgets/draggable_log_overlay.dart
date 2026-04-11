import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/log_recorder.dart'
    show logsProvider, logViewerActiveProvider, LogEntry;
import 'package:island/main.dart';
import 'package:logging/logging.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

OverlayEntry? _logOverlayEntry;

final _logOverlayStateProvider =
    NotifierProvider<_LogOverlayStateNotifier, _LogOverlayState>(
      _LogOverlayStateNotifier.new,
    );

class _LogOverlayState {
  final Offset position;
  final bool minimized;

  const _LogOverlayState({
    this.position = const Offset(16, 80),
    this.minimized = false,
  });

  _LogOverlayState copyWith({Offset? position, bool? minimized}) {
    return _LogOverlayState(
      position: position ?? this.position,
      minimized: minimized ?? this.minimized,
    );
  }
}

class _LogOverlayStateNotifier extends Notifier<_LogOverlayState> {
  @override
  _LogOverlayState build() => const _LogOverlayState();

  void updatePosition(Offset delta) {
    state = state.copyWith(
      position: Offset(
        state.position.dx + delta.dx,
        state.position.dy + delta.dy,
      ),
    );
  }

  void setMinimized(bool value) {
    state = state.copyWith(minimized: value);
  }
}

void showLogOverlay() {
  if (_logOverlayEntry != null) return;

  _container.read(logViewerActiveProvider.notifier).setActive(true);

  final state = _container.read(_logOverlayStateProvider);
  _logOverlayEntry = OverlayEntry(
    builder: (context) => _DraggableLogPanel(
      initialPosition: state.position,
      initialMinimized: state.minimized,
    ),
  );
  globalOverlay.currentState?.insert(_logOverlayEntry!);
}

void hideLogOverlay() {
  _container.read(logViewerActiveProvider.notifier).setActive(false);
  _logOverlayEntry?.remove();
  _logOverlayEntry = null;
}

void toggleLogOverlay() {
  if (_logOverlayEntry != null) {
    hideLogOverlay();
  } else {
    showLogOverlay();
  }
}

final ProviderContainer _container = ProviderContainer();

final _logViewerStateProvider =
    NotifierProvider<_LogViewerStateNotifier, _LogViewerState>(
      _LogViewerStateNotifier.new,
    );

class _LogViewerState {
  final String searchQuery;
  final Set<Level> selectedLevels;

  _LogViewerState({this.searchQuery = '', Set<Level>? selectedLevels})
    : selectedLevels = selectedLevels ?? {Level.ALL};

  _LogViewerState copyWith({String? searchQuery, Set<Level>? selectedLevels}) {
    return _LogViewerState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedLevels: selectedLevels ?? this.selectedLevels,
    );
  }
}

class _LogViewerStateNotifier extends Notifier<_LogViewerState> {
  @override
  _LogViewerState build() => _LogViewerState();

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleLevel(Level level) {
    final current = state.selectedLevels;

    if (level == Level.ALL) {
      if (current.contains(Level.ALL)) {
        state = state.copyWith(selectedLevels: {});
      } else {
        state = state.copyWith(selectedLevels: {Level.ALL});
      }
      return;
    }

    final withoutAll = current.difference({Level.ALL});
    if (withoutAll.contains(level)) {
      final updated = withoutAll.length == 1
          ? <Level>{}
          : withoutAll.difference({level});
      state = state.copyWith(selectedLevels: updated);
    } else {
      state = state.copyWith(selectedLevels: {...withoutAll, level});
    }
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
    if (selectedLevels.isNotEmpty &&
        !selectedLevels.contains(Level.ALL) &&
        !selectedLevels.contains(entry.level)) {
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

class _DraggableLogPanel extends ConsumerStatefulWidget {
  final Offset initialPosition;
  final bool initialMinimized;

  const _DraggableLogPanel({
    required this.initialPosition,
    required this.initialMinimized,
  });

  @override
  ConsumerState<_DraggableLogPanel> createState() => _DraggableLogPanelState();
}

class _DraggableLogPanelState extends ConsumerState<_DraggableLogPanel>
    with SingleTickerProviderStateMixin {
  late Offset _position;
  late bool _minimized;
  late AnimationController _animController;
  late Animation<double> _heightAnim;
  late ScrollController _scrollController;
  bool _isAtBottom = true;
  int _lastLogCount = 0;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _minimized = widget.initialMinimized;
    _animController = AnimationController(
      duration: const Duration(milliseconds: 280),
      vsync: this,
      value: _minimized ? 0.0 : 1.0,
    );
    _heightAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    final atBottom = (max - current).abs() < 1.0 || max <= 0;
    if (atBottom != _isAtBottom) {
      setState(() => _isAtBottom = atBottom);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.maxScrollExtent > 0) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  void _autoScrollIfNeeded(int logCount) {
    if (_isAtBottom &&
        logCount > _lastLogCount &&
        _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
    _lastLogCount = logCount;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleMinimized() {
    setState(() => _minimized = !_minimized);
    ref.read(_logOverlayStateProvider.notifier).setMinimized(_minimized);
    if (_minimized) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _position = Offset(
                _position.dx + details.delta.dx,
                _position.dy + details.delta.dy,
              );
            });
            ref
                .read(_logOverlayStateProvider.notifier)
                .updatePosition(details.delta);
          },
          child: AnimatedBuilder(
            animation: _heightAnim,
            builder: (context, child) {
              const expandedH = 480.0;
              const headerH = 49.0;
              final currentH =
                  headerH + (expandedH - headerH) * _heightAnim.value;
              return Container(
                width: 360,
                height: currentH + 2,
                clipBehavior: Clip.none,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: currentH,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: theme.colorScheme.shadow.withOpacity(0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Column(
                            children: [
                              _buildHeader(context),
                              FadeTransition(
                                opacity: _heightAnim,
                                child: Container(
                                  height: 1,
                                  color: theme.dividerColor,
                                ),
                              ),
                              Expanded(
                                child: FadeTransition(
                                  opacity: _heightAnim,
                                  child: _buildContent(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
            theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.6),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(Symbols.terminal, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Log Viewer',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _HeaderButton(
            icon: _minimized ? Symbols.open_in_full : Symbols.minimize,
            tooltip: _minimized ? 'Expand' : 'Minimize',
            onTap: _toggleMinimized,
          ),
          const SizedBox(width: 2),
          _HeaderButton(
            icon: Symbols.delete_sweep,
            tooltip: 'Clear logs',
            onTap: () {
              ref.read(logsProvider.notifier).clear();
            },
          ),
          const SizedBox(width: 2),
          _HeaderButton(
            icon: Symbols.close,
            tooltip: 'Close',
            onTap: () {
              hideLogOverlay();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final filteredLogs = ref.watch(_filteredLogsProvider);
    _autoScrollIfNeeded(filteredLogs.length);
    final viewerState = ref.watch(_logViewerStateProvider);
    final notifier = ref.read(_logViewerStateProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search logs...',
              hintStyle: const TextStyle(fontSize: 13),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              prefixIcon: Icon(Symbols.search, size: 16),
              suffixIcon: viewerState.searchQuery.isNotEmpty
                  ? GestureDetector(
                      onTap: () => notifier.clearSearch(),
                      child: Icon(Symbols.close, size: 14),
                    )
                  : null,
              isDense: true,
            ),
            onChanged: (value) => notifier.setSearch(value),
          ),
        ),
        SizedBox(
          height: 36,
          child: SuperListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _allLevels.length,
            separatorBuilder: (context, item) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final level = _allLevels[index];
              final label = _levelLabels[level]!;
              final isSelected = viewerState.selectedLevels.contains(level);
              return FilterChip(
                label: Text(label),
                labelStyle: TextStyle(fontSize: 11),
                selected: isSelected,
                onSelected: (_) => notifier.toggleLevel(level),
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: isSelected ? _levelColor(level) : Colors.transparent,
                  width: 1,
                ),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                selectedColor: _levelColor(level).withOpacity(0.25),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Row(
            children: [
              Text(
                '${filteredLogs.length} entries',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: filteredLogs.isEmpty
              ? Center(
                  child: Text(
                    'No logs found',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) {
                    return _LogEntryTile(entry: filteredLogs[index]);
                  },
                ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final dynamic icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: _levelColor(entry.level).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: _levelColor(entry.level).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.level.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _levelColor(entry.level),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SelectableText(
                    entry.message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      fontSize: 10,
                    ),
                    maxLines: expanded.value ? 100 : 2,
                    minLines: 1,
                  ),
                ),
                if (hasDetails)
                  Icon(
                    expanded.value ? Symbols.expand_less : Symbols.expand_more,
                    size: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 1),
              child: Text(
                _formatTime(entry.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (expanded.value) ...[
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(6),
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
                                fontSize: 9,
                              ),
                        ),
                        const SizedBox(height: 1),
                        SelectableText(
                          entry.error.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                fontSize: 9,
                                color: Colors.red.shade300,
                              ),
                        ),
                      ],
                      if (entry.stackTrace != null) ...[
                        if (entry.error != null) const SizedBox(height: 4),
                        Text(
                          'Stack Trace:',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 9,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 1),
                        SelectableText(
                          entry.stackTrace.toString(),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontFamily: 'monospace',
                                fontSize: 9,
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
