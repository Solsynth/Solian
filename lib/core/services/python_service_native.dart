// lib/core/services/python_service_native.dart
import 'dart:io';
import 'dart:developer';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';

pkpy.VM? _vm;
bool _isInitialized = false;

/// 是否已成功初始化并执行了所有脚本
bool isPythonAvailable() => _isInitialized;

/// 初始化 Python，设置 sys.path，并执行 SolianApp 下所有 .py 文件
Future<void> initPython() async {
  if (_isInitialized) return;

  try {
    final appDocDir = await getApplicationDocumentsDirectory();
    final solianAppDir = Directory('${appDocDir.path}/SolianApp');

    // 打印当前系统加载插件的文件夹（即 SolianApp 路径）
    if (await solianAppDir.exists()) {
      log('[python_service] Python scripts folder: ${solianAppDir.path}');
    } else {
      // 无则打印其父路径（即文档目录）
      log('[python_service] SolianApp not found, parent folder: ${appDocDir.path}');
      return;
    }

    _vm = pkpy.VM();

    // 将 SolianApp 目录添加到 sys.path
    _vm!.exec('''
import sys
sys.path.insert(0, r"${solianAppDir.path}")
''');

    await _executeAllScripts(solianAppDir);

    _isInitialized = true;
    log('[python_service] Initialized and executed all scripts in ${solianAppDir.path}');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
  }
}

Future<void> _executeAllScripts(Directory dir) async {
  final entities = await dir.list().toList();
  final files = <File>[];
  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.py')) {
      files.add(entity);
    }
  }
  files.sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    await _executeSingleScript(file);
  }
}

Future<void> _executeSingleScript(File script) async {
  if (_vm == null) return;

  try {
    final content = await script.readAsString();
    _vm!.exec(content);
    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) {
      debugPrint('[Python stdout][${script.path.split('/').last}] ${out.stdout}');
    }
    if (out.stderr.isNotEmpty) {
      debugPrint('[Python stderr][${script.path.split('/').last}] ${out.stderr}');
    }
  } catch (e) {
    log('[python_service] Failed to execute ${script.path}: $e');
  }
}

/// 可选：执行额外的 Python 代码字符串
Future<void> evalPythonCode(String code) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) debugPrint('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) debugPrint('[Python stderr] ${out.stderr}');
}
