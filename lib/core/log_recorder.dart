import 'dart:async';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:island/core/config.dart';
import 'package:logging/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/log_file.dart';

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

  String toFileLine() {
    final buf = StringBuffer();
    buf.write('[${_formatTime(timestamp)}] [${level.name}] $message');
    if (error != null) {
      buf.write(' | error: $error');
    }
    if (stackTrace != null) {
      buf.write('\n$stackTrace');
    }
    return buf.toString();
  }

  String _formatTime(DateTime dt) {
    final y = dt.year.toString();
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final ms = dt.millisecond.toString().padLeft(3, '0');
    return '$y-$mo-${d}T$h:$mi:$s.$ms';
  }
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
  LogFileWriter? _fileWriter;

  static const _debounceWhenActive = Duration(milliseconds: 100);
  static const _debounceWhenIdle = Duration(milliseconds: 1000);

  @override
  List<LogEntry> build() {
    final isDeveloperMode = ref.watch(developerModeProvider);
    if (!isDeveloperMode) {
      _subscription?.cancel();
      _subscription = null;
      _debounceTimer?.cancel();
      _debounceTimer = null;
      _pendingEntries.clear();
      _currentLogs = [];
      return const [];
    }

    _subscription?.cancel();
    _subscription = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingEntries.clear();
    _currentLogs = [];

    _fileWriter = createLogFileWriter();

    ref.onDispose(() {
      _subscription?.cancel();
      _debounceTimer?.cancel();
      _fileWriter?.close();
    });

    _subscription = Logger.root.onRecord.listen((record) {
      final entry = LogEntry(
        timestamp: record.time,
        level: record.level,
        message: record.message,
        error: record.error,
        stackTrace: record.stackTrace,
      );
      _fileWriter?.write(entry.toFileLine());
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

final class ProviderLogger extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Logger.root.severe(
      '[Riverpod] ${context.provider.name} failed...',
      error,
      stackTrace,
    );
    super.providerDidFail(context, error, stackTrace);
  }

  @override
  void mutationError(
    ProviderObserverContext context,
    Mutation<Object?> mutation,
    Object error,
    StackTrace stackTrace,
  ) {
    Logger.root.severe(
      '[Riverpod] ${context.provider.name} mutation failed...',
      error,
      stackTrace,
    );
    super.mutationError(context, mutation, error, stackTrace);
  }
}
