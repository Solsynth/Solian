import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

pkpy.VM? _vm;
bool _isInitialized = false;

bool isPythonAvailable() => _isInitialized;

Future<void> initPython() async {
  if (_isInitialized) return;

  try {
    Directory baseDir;
    if (kIsWeb) {
      Logger.root.info('[python_service] Web platform, skipping');
      return;
    } else if (Platform.isAndroid || Platform.isIOS) {
      baseDir = await getApplicationSupportDirectory();
    } else {
      final exeDir = path.dirname(Platform.resolvedExecutable);
      baseDir = Directory(exeDir);
    }

    final pluginsDir = Directory(path.join(baseDir.path, 'plugins'));
    if (!await pluginsDir.exists()) {
      await pluginsDir.create(recursive: true);
      Logger.root.info('[python_service] Created plugins directory: ${pluginsDir.path}');
    }

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final scriptPaths = manifest.listAssets().where((asset) => asset.startsWith('assets/scripts/') && asset.endsWith('.py')).toList();

    for (final assetPath in scriptPaths) {
      final fileName = path.basename(assetPath);
      final destFile = File(path.join(baseDir.path, fileName));
      final content = await rootBundle.loadString(assetPath);
      await destFile.writeAsString(content);
      Logger.root.info('[python_service] Wrote $fileName to ${destFile.path}');
    }

    _vm = pkpy.VM();

    _vm!.exec('import sys');
    final cleanPath = baseDir.path.replaceAll('\\', '/');
    _vm!.exec('sys.path.insert(0, r"$cleanPath")');

    _vm!.exec('import loader');
    _vm!.exec('loader.load_plugins()');

    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) {
      Logger.root.info('[Python stdout] ${out.stdout}');
    }
    if (out.stderr.isNotEmpty) {
      Logger.root.warning('[Python stderr] ${out.stderr}');
    }

    _isInitialized = true;
    Logger.root.info('[python_service] Initialized, base dir: ${baseDir.path}');
  } catch (e) {
    Logger.root.severe('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
  }
}

Future<void> evalPythonCode(String code) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) {
    Logger.root.info('[Python stdout] ${out.stdout}');
  }
  if (out.stderr.isNotEmpty) {
    Logger.root.warning('[Python stderr] ${out.stderr}');
  }
}
