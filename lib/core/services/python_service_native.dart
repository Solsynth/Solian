import 'dart:io';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';

pkpy.VM? _vm;
bool _isInitialized = false;

bool isPythonAvailable() => _isInitialized;

Future<void> initPython() async {
  if (_isInitialized) return;

  try {
    final appSupportDir = await getApplicationSupportDirectory();
    final pluginsDir = Directory('${appSupportDir.path}/plugins');
    final eventFile = File('${appSupportDir.path}/event.py');

    if (!await pluginsDir.exists()) {
      await pluginsDir.create(recursive: true);
      log('[python_service] Created plugins directory: ${pluginsDir.path}');
    }

    final eventScript = await rootBundle.loadString('assets/scripts/event.py');
    await eventFile.writeAsString(eventScript);

    _vm = pkpy.VM();

    _vm!.exec('''
import sys
sys.path.insert(0, r"${appSupportDir.path}")
''');

    _vm!.exec('import event');

    final loadPluginsCode = '''
import os
import sys
plugins_dir = os.path.join(sys.path[0], 'plugins')
if os.path.exists(plugins_dir):
    for filename in os.listdir(plugins_dir):
        if filename.endswith('.py'):
            module_name = filename[:-3]
            try:
                __import__(module_name)
                print(f"Imported plugin: {module_name}")
            except Exception as e:
                print(f"Failed to import plugin {module_name}: {e}")
''';
    _vm!.exec(loadPluginsCode);

    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
    if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');

    _isInitialized = true;
    log('[python_service] Initialized');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
  }
}

Future<void> callEvent(String eventName, List<dynamic> args) async {
  if (!_isInitialized || _vm == null) return;
  final argsStr = args.map((a) {
    if (a is String) return '"${a.replaceAll('"', '\\"')}"';
    if (a is bool) return a ? 'True' : 'False';
    if (a == null) return 'None';
    return a.toString();
  }).join(', ');
  await evalPythonCode('event.call("$eventName", $argsStr)');
}

Future<void> evalPythonCode(String code) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');
}
