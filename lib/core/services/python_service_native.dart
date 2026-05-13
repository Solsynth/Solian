// lib/core/services/python_service_native.dart
import 'dart:io';
import 'dart:developer';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';

pkpy.VM? _vm;
bool _isInitialized = false;
String? _solianAppPath;

bool isPythonAvailable() => _isInitialized;

/// 初始化 Python 环境，设置 sys.path，然后顺序执行所有 .py 文件
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

    // 创建主 VM
    _vm = pkpy.VM();

    // 将 SolianApp 目录添加到 sys.path（全局有效）
    _vm!.exec('''
import sys
sys.path.insert(0, r"${_solianAppPath}")
''');

    // 收集所有 .py 文件
    final files = <File>[];
    await for (final entity in solianAppDir.list()) {
      if (entity is File && entity.path.endsWith('.py')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.compareTo(b.path));

    // 顺序执行每个脚本，每个脚本使用独立的全局字典
    for (final file in files) {
      await _executeScriptWithIsolatedGlobals(file);
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

/// 使用独立的全局字典执行单个脚本（环境隔离，但模块导入共享）
Future<void> _executeScriptWithIsolatedGlobals(File script) async {
  if (_vm == null) return;

  try {
    final content = await script.readAsString();
    // 创建一个新的空字典作为该脚本的全局命名空间
    final isolatedGlobals = <String, dynamic>{};
    _vm!.eval(content, isolatedGlobals);  // 执行后，脚本中定义的变量存入 isolatedGlobals
    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) {
      log('[Python stdout][${script.path.split('/').last}] ${out.stdout}');
    }
    if (out.stderr.isNotEmpty) {
      log('[Python stderr][${script.path.split('/').last}] ${out.stderr}');
    }
  } catch (e) {
    log('[python_service] Failed to execute ${script.path}: $e');
  }
}

/// 执行单条 Python 代码（使用主 VM，可指定全局字典）
Future<void> evalPythonCode(String code, [Map<String, dynamic>? globals]) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.eval(code, globals);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');
}
