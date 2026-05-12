import 'dart:developer';
import 'package:pocketpy/pocketpy.dart' as pkpy;
import 'package:riverpod/riverpod.dart';
import 'package:island/core/network.dart';  // 绝对路径

pkpy.VM? _vm;
String? _cachedToken;
bool _isInitialized = false;

/// 是否已成功初始化（有 token 且 VM 已创建）
bool isPythonAvailable() => _isInitialized;

/// 获取缓存的 token（仅当初始化成功时才有值）
String? getCachedToken() => _cachedToken;

/// 初始化 PocketPy，只有拿到有效 token 时才初始化
Future<void> initPython(ProviderContainer container) async {
  if (_isInitialized) return;

  try {
    // 获取有效 token（自动处理刷新）
    final token = await getValidAuthToken(container);
    if (token == null || token.isEmpty) {
      log('[python_service] No valid token, skip init.');
      return;
    }

    _cachedToken = token;
    _vm = pkpy.VM();

    // 将 token 注入 Python 全局变量
    _vm!.exec('ACCESS_TOKEN = "$token"');
    // 可选：同时注入其他信息，比如 serverUrl
    // 从 container 中读取 serverUrlProvider 可能需要额外的 provider，暂略
    _vm!.exec('print("PocketPy ready, ACCESS_TOKEN injected")');

    final out = _vm!.read_output();
    if (out.stdout.isNotEmpty) debugPrint('[Python stdout] ${out.stdout}');

    _isInitialized = true;
    log('[python_service] Initialized');
  } catch (e) {
    log('[python_service] Init failed: $e');
    _isInitialized = false;
    _vm = null;
    _cachedToken = null;
  }
}

/// 执行 Python 代码（仅在初始化成功时执行）
Future<void> evalPythonCode(String code) async {
  if (!_isInitialized || _vm == null) {
    log('[python_service] Python not available');
    return;
  }
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) debugPrint('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) debugPrint('[Python stderr] ${out.stderr}');
}
