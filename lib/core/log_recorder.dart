import 'dart:async';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int kMaxLogs = 5000;

class LogEntry {
  final DateTime timestamp;
  final Level level;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
  });
}

final logsProvider = NotifierProvider<LogsNotifier, List<LogEntry>>(
  LogsNotifier.new,
);

final logViewerActiveProvider =
    NotifierProvider<_LogViewerActiveNotifier, bool>(
      _LogViewerActiveNotifier.new,
    );

class _LogViewerActiveNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setActive(bool value) => state = value;
}

class LogsNotifier extends Notifier<List<LogEntry>> {
  StreamSubscription<LogRecord>? _subscription;
  Timer? _debounceTimer;
  final List<LogEntry> _pendingEntries = [];
  List<LogEntry> _currentLogs = [];

  static const _debounceWhenActive = Duration(milliseconds: 100);
  static const _debounceWhenIdle = Duration(milliseconds: 1000);

  @override
  List<LogEntry> build() {
    ref.onDispose(() {
      _subscription?.cancel();
      _debounceTimer?.cancel();
    });

    _subscription = Logger.root.onRecord.listen((record) {
      final entry = LogEntry(
        timestamp: record.time,
        level: record.level,
        message: record.message,
        error: record.error,
        stackTrace: record.stackTrace,
      );
      _pendingEntries.add(entry);
      _scheduleFlush();
    });

    return [];
  }

  void _scheduleFlush() {
    _debounceTimer?.cancel();

    final isActive = ref.read(logViewerActiveProvider);
    final delay = isActive ? _debounceWhenActive : _debounceWhenIdle;

    _debounceTimer = Timer(delay, () {
      if (_pendingEntries.isEmpty) return;

      _currentLogs = [..._currentLogs, ..._pendingEntries];
      _pendingEntries.clear();

      if (_currentLogs.length > kMaxLogs) {
        _currentLogs = _currentLogs.sublist(_currentLogs.length - kMaxLogs);
      }

      state = _currentLogs;
    });
  }

  void clear() {
    _pendingEntries.clear();
    _currentLogs = [];
    state = [];
  }
}
