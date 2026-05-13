// lib/core/services/python_service_native.dart
import 'dart:io';
import 'dart:developer';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:path_provider/path_provider.dart';

bool _isInitialized = false;
String? _solianAppPath;

bool isPythonAvailable() => _isInitialized;

/// 初始化 Python 并并行执行 SolianApp 下所有 .py 文件
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

    final files = <File>[];
    await for (final entity in solianAppDir.list()) {
      if (entity is File && entity.path.endsWith('.py')) {
        files.add(entity);
      }
    }
    files.sort((a, b) => a.path.compareTo(b.path));

    // 并行执行所有脚本，每个脚本使用独立的 ComputeThread
    final futures = <Future<void>>[];
    for (int i = 0; i < files.length; i++) {
      // vm_index 范围 1-15，循环使用
      final vmIndex = (i % 15) + 1;
      futures.add(_executeScriptInThread(files[i], vmIndex));
    }

    await Future.wait(futures);
    _isInitialized = true;
    log('[python_service] All scripts executed successfully');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _solianAppPath = null;
  }
}

/// 在独立线程中执行单个脚本
Future<void> _executeScriptInThread(File script, int vmIndex) async {
  final thread = pkpy.ComputeThread(vmIndex);
  try {
    // 设置模块搜索路径
    thread.exec('''
import sys
sys.path.insert(0, r"$_solianAppPath")
''');
    final content = await script.readAsString();
    thread.exec(content);
    thread.wait_for_done();

    final out = thread.read_output();
    if (out.stdout.isNotEmpty) {
      log('[Python stdout][${script.path.split('/').last}] ${out.stdout}');
    }
    if (out.stderr.isNotEmpty) {
      log('[Python stderr][${script.path.split('/').last}] ${out.stderr}');
    }
  } catch (e) {
    log('[python_service] Failed to execute ${script.path}: $e');
  } finally {
    thread.close();
  }
}

/// 执行单条 Python 代码（简单封装，仍使用主线程）
Future<void> evalPythonCode(String code) async {
  if (!_isInitialized) {
    log('[python_service] Python not available');
    return;
  }
  // 为了演示，创建一个临时线程执行（或复用主 VM，这里简单处理）
  final thread = pkpy.ComputeThread(1);
  try {
    if (_solianAppPath != null) {
      thread.exec('''
import sys
sys.path.insert(0, r"$_solianAppPath")
''');
    }
    thread.exec(code);
    thread.wait_for_done();
    final out = thread.read_output();
    if (out.stdout.isNotEmpty) log('[Python stdout] ${out.stdout}');
    if (out.stderr.isNotEmpty) log('[Python stderr] ${out.stderr}');
  } catch (e) {
    log('[python_service] evalPythonCode error: $e');
  } finally {
    thread.close();
  }
}
