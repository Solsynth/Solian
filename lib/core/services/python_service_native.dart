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

    _vm = pkpy.VM();

    // 加载并执行 assets/scripts/ 中的所有初始化脚本
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final allAssets = manifest.listAssets();
    final initScripts = allAssets.where((asset) => asset.startsWith('assets/scripts/') && asset.endsWith('.py')).toList();
    initScripts.sort();
    for (final assetPath in initScripts) {
      final content = await rootBundle.loadString(assetPath);
      _vm!.exec(content);
      Logger.root.info('[python_service] Executed init script: $assetPath');
    }

    // 执行 plugins/ 目录下的所有插件脚本
    final pluginFiles = <File>[];
    await for (final entity in pluginsDir.list()) {
      if (entity is File && entity.path.endsWith('.py')) {
        pluginFiles.add(entity);
      }
    }
    pluginFiles.sort((a, b) => a.path.compareTo(b.path));
    for (final file in pluginFiles) {
      final content = await file.readAsString();
      _vm!.exec(content);
      Logger.root.info('[python_service] Executed plugin: ${path.basename(file.path)}');
    }

    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) {
      Logger.root.info('[Python stdout] ${out.stdout}');
    }
    if (out.stderr.isNotEmpty) {
      Logger.root.warning('[Python stderr] ${out.stderr}');
    }

    _isInitialized = true;
    Logger.root.info('[python_service] Initialized with ${initScripts.length} init scripts and ${pluginFiles.length} plugins');
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
