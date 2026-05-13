import 'dart:io';
import 'dart:developer';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';

pkpy.VM? _vm;
bool _isInitialized = false;
String? _solianAppPath;

bool isPythonAvailable() => _isInitialized;

Future<void> initPython() async {
  if (_isInitialized) return;

  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final solianAppDir = Directory('${appDocDir.path}/SolianApp');

    if (await solianAppDir.exists()) {
      log('[python_service] Python scripts folder: ${solianAppDir.path}');
      _solianAppPath = solianAppDir.path;
    } else {
      log('[python_service] SolianApp not found, parent folder: ${appDocDir.path}');
      return;
    }

    _vm = pkpy.VM();

    _vm!.exec('''
import sys
sys.path.insert(0, r"${_solianAppPath}")
''');

    final files = <File>[];
    await for (final entity in solianAppDir.list()) {
      if (entity is File && entity.path.endsWith('.py')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final content = await file.readAsString();
      _vm!.exec(content);
      final out = _vm!.read_output();
      if (out.stdout.isNotEmpty) {
        log('[Python stdout][${file.path.split('/').last}] ${out.stdout}');
      }
      if (out.stderr.isNotEmpty) {
        log('[Python stderr][${file.path.split('/').last}] ${out.stderr}');
      }
    }

    _isInitialized = true;
    log('[python_service] All scripts executed successfully');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
    _solianAppPath = null;
  }
}

Future<void> evalPythonCode(String code) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');
}
