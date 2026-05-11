import 'package:pocketpy/pocketpy.dart' as pkpy;

pkpy.VM? _vm;

Future<void> initPython() async {
  _vm = pkpy.VM();
  // 可选：执行一些初始化脚本
  _vm?.exec('print("pocketpy ready")');
}

Future<void> evalPythonCode(String code) async {
  if (_vm == null) return;
  _vm!.exec(code);
  final out = _vm!.read_output();
  if (out.stdout.isNotEmpty) debugPrint('[Python stdout] ${out.stdout}');
  if (out.stderr.isNotEmpty) debugPrint('[Python stderr] ${out.stderr}');
}
