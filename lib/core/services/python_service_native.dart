import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

pkpy.VM? _vm;
bool _isInitialized = false;

bool isPythonAvailable() => _isInitialized;

Future<void> initPython() async {
  if (_isInitialized) return;

  try {
    Directory baseDir;
    if (kIsWeb) {
      log('[python_service] Web platform, skipping');
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
      log('[python_service] Created plugins directory: ${pluginsDir.path}');
    }

    // 动态获取 assets/scripts/ 下的所有 .py 文件
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    final scriptPaths = assets.where((asset) => asset.startsWith('assets/scripts/') && asset.endsWith('.py')).toList();

    for (final assetPath in scriptPaths) {
      final fileName = path.basename(assetPath);
      final destFile = File(path.join(baseDir.path, fileName));
      final content = await rootBundle.loadString(assetPath);
      await destFile.writeAsString(content);
      log('[python_service] Wrote $fileName to ${destFile.path}');
    }

    _vm = pkpy.VM();

    _vm!.exec('''
import sys
sys.path.insert(0, r"${baseDir.path}")
''');

    // 确保 loader.py 存在（它应该在 scriptPaths 中）
    _vm!.exec('import loader');
    _vm!.exec('loader.load_plugins()');

    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
    if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');

    _isInitialized = true;
    log('[python_service] Initialized, base dir: ${baseDir.path}');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
  }
}

Future<void> evalPythonCode(String code) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');
}
