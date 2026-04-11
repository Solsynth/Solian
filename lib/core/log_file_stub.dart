import 'package:island/core/log_recorder.dart';

abstract class LogFileWriter {
  void write(String line);
  Future<void> close();
}

LogFileWriter createLogFileWriter() => _StubLogFileWriter();

class _StubLogFileWriter implements LogFileWriter {
  @override
  void write(String line) {}

  @override
  Future<void> close() async {}
}

class LogFileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime modified;

  const LogFileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  String get formattedSize => '';
  String get formattedDate => '';
}

Future<List<LogFileInfo>> getLogFiles() async => [];

Future<List<LogEntry>> readLogFile(String path) async => [];
