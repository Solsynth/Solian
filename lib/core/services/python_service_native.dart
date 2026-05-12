import 'dart:io';
import 'dart:developer';
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
    // 1. 获取文档目录下的 SolianApp
    final appDocDir = await getApplicationDocumentsDirectory();
    final solianAppDir = Directory('${appDocDir.path}/SolianApp');

    if (!await solianAppDir.exists()) {
      log('[python_service] SolianApp folder not found at ${solianAppDir.path}');
      return;
    }

    // 2. 创建 VM
    _vm = pkpy.VM();

    // 3. 将 SolianApp 目录添加到 sys.path（全局共享，用于 import）
    _vm!.exec('''
import sys
sys.path.insert(0, r"${solianAppDir.path}")
''');

    // 4. 执行所有 Python 脚本
    await _executeAllScripts(solianAppDir);

    _isInitialized = true;
    log('[python_service] Initialized and executed all scripts in ${solianAppDir.path}');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
  }
}

/// 执行 SolianApp 文件夹下的所有 .py 文件（不递归子目录，按文件名排序）
Future<void> _executeAllScripts(Directory dir) async {
  final files = await dir
      .list()
      .where((entity) => entity is File && entity.path.endsWith('.py'))
      .toList();

  // 按文件名排序，保证执行顺序可预测
  files.sort((a, b) => a.path.compareTo(b.path));

  for (final file in files) {
    await _executeSingleScript(file);
  }
}

/// 执行单个 Python 脚本，使用独立的全局字典
Future<void> _executeSingleScript(File script) async {
  if (_vm == null) return;

  try {
    final content = await script.readAsString();
    final globals = <String, dynamic>{};  // 独立环境
    _vm!.exec(content, globals);
    
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

/// 可选：执行额外的 Python 代码字符串，可以指定是否复用某个全局字典
Future<void> evalPythonCode(String code, [Map<String, dynamic>? globals]) async {
  if (!_isInitialized || _vm == null) return;
  _vm!.exec(code, globals);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) debugPrint('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) debugPrint('[Python stderr] ${out.stderr}');
}
