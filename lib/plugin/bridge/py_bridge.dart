import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:pocketpy/pocketpy.dart';
import 'package:pocketpy/pocketpy_bindings_generated.dart';

final _log = Logger('PyBridge');

/// High-level Dart wrapper around pocketpy's raw FFI bindings.
///
/// Provides safe, ergonomic APIs for executing Python code,
/// creating modules, binding functions, and converting values.
class PyBridge {
  PyBridge._();
  static final PyBridge instance = PyBridge._();

  bool _initialized = false;

  /// Initialize the pocketpy runtime. Safe to call multiple times.
  void initialize() {
    if (_initialized) return;
    // pocketpy auto-initializes on first access of the `pocket` global.
    // Just touch it to trigger initialization.
    pocket.py_initialize();
    _initialized = true;
    _log.info('Pocketpy runtime initialized');
  }

  // ---------------------------------------------------------------------------
  // Execution
  // ---------------------------------------------------------------------------

  /// Execute Python source code (statements). Returns true on success.
  bool exec(String source, {String filename = '<string>', Pointer<py_TValue>? module}) {
    final srcPtr = source.toNativeUtf8().cast<Char>();
    final filePtr = filename.toNativeUtf8().cast<Char>();
    final modPtr = module ?? nullptr;
    try {
      final ok = pocket.py_exec(srcPtr, filePtr, py_CompileMode.EXEC_MODE, modPtr);
      if (!ok) {
        _logException();
      }
      return ok;
    } finally {
      calloc.free(srcPtr);
      calloc.free(filePtr);
    }
  }

  /// Evaluate a Python expression and return the result as a Dart object.
  /// Returns null on failure.
  Object? eval(String expression, {Pointer<py_TValue>? module}) {
    final srcPtr = expression.toNativeUtf8().cast<Char>();
    final modPtr = module ?? nullptr;
    try {
      final ok = pocket.py_eval(srcPtr, modPtr);
      if (!ok) {
        _logException();
        return null;
      }
      return toDart(pocket.py_retval());
    } finally {
      calloc.free(srcPtr);
    }
  }

  /// Execute Python code and return stdout/stderr output.
  PyExecutionResult execWithOutput(String source, {String filename = '<string>'}) {
    final ok = exec(source, filename: filename);
    String? error;
    if (!ok) {
      error = formatException();
    }
    return PyExecutionResult(success: ok, error: error);
  }

  // ---------------------------------------------------------------------------
  // Module creation
  // ---------------------------------------------------------------------------

  /// Create or get a Python module by name.
  Pointer<py_TValue> newModule(String name) {
    final namePtr = name.toNativeUtf8().cast<Char>();
    try {
      return pocket.py_newmodule(namePtr);
    } finally {
      calloc.free(namePtr);
    }
  }

  /// Get an existing module by name. Returns null if not found.
  Pointer<py_TValue>? getModule(String name) {
    final namePtr = name.toNativeUtf8().cast<Char>();
    try {
      final ref = pocket.py_getmodule(namePtr);
      return ref == nullptr ? null : ref;
    } finally {
      calloc.free(namePtr);
    }
  }

  // ---------------------------------------------------------------------------
  // Function binding
  // ---------------------------------------------------------------------------

  /// Bind a native Dart function to a Python object (module or type).
  ///
  /// The [signature] uses pocketpy's C-style syntax, e.g. `'add(x, y)'`.
  /// The [func] must follow the `py_CFunction` signature:
  /// `bool Function(int argc, Pointer<py_TValue> argv)`.
  void bind(
    Pointer<py_TValue> obj,
    String signature,
    Pointer<NativeFunction<Bool Function(Int argc, py_StackRef argv)>> func,
  ) {
    final sigPtr = signature.toNativeUtf8().cast<Char>();
    try {
      pocket.py_bind(obj, sigPtr, func);
    } finally {
      calloc.free(sigPtr);
    }
  }

  /// Bind a function by name only (no signature parsing).
  void bindFunc(
    Pointer<py_TValue> obj,
    String name,
    Pointer<NativeFunction<Bool Function(Int argc, py_StackRef argv)>> func,
  ) {
    final namePtr = name.toNativeUtf8().cast<Char>();
    try {
      pocket.py_bindfunc(obj, namePtr, func);
    } finally {
      calloc.free(namePtr);
    }
  }

  // ---------------------------------------------------------------------------
  // Name helpers
  // ---------------------------------------------------------------------------

  /// Convert a Dart string to a pocketpy name (interned identifier).
  Pointer<py_OpaqueName> name(String s) {
    final sPtr = s.toNativeUtf8().cast<Char>();
    try {
      return pocket.py_name(sPtr);
    } finally {
      calloc.free(sPtr);
    }
  }

  // ---------------------------------------------------------------------------
  // Value creation (Dart → Python)
  // ---------------------------------------------------------------------------

  /// Create a Python int value in the given output slot.
  void newInt(Pointer<py_TValue> out, int value) => pocket.py_newint(out, value);

  /// Create a Python float value in the given output slot.
  void newFloat(Pointer<py_TValue> out, double value) => pocket.py_newfloat(out, value);

  /// Create a Python bool value in the given output slot.
  void newBool(Pointer<py_TValue> out, bool value) => pocket.py_newbool(out, value);

  /// Create a Python str value in the given output slot.
  void newStr(Pointer<py_TValue> out, String value) {
    final sPtr = value.toNativeUtf8().cast<Char>();
    try {
      pocket.py_newstr(out, sPtr);
    } finally {
      calloc.free(sPtr);
    }
  }

  /// Create a Python None in the given output slot.
  void newNone(Pointer<py_TValue> out) => pocket.py_newnone(out);

  /// Create a Python list in the given output slot.
  void newList(Pointer<py_TValue> out) => pocket.py_newlist(out);

  /// Create a Python dict in the given output slot.
  void newDict(Pointer<py_TValue> out) => pocket.py_newdict(out);

  /// Append an item to a Python list.
  void listAppend(Pointer<py_TValue> list, Pointer<py_TValue> item) =>
      pocket.py_list_append(list, item);

  /// Set a string-keyed item in a Python dict.
  bool dictSetItemByStr(Pointer<py_TValue> dict, String key, Pointer<py_TValue> value) {
    final keyPtr = key.toNativeUtf8().cast<Char>();
    try {
      return pocket.py_dict_setitem_by_str(dict, keyPtr, value);
    } finally {
      calloc.free(keyPtr);
    }
  }

  /// Create a Python value from a Dart object (int, double, bool, String, null,
  /// List, Map). Writes into [out].
  void fromDart(Pointer<py_TValue> out, Object? value) {
    if (value == null) {
      newNone(out);
    } else if (value is int) {
      newInt(out, value);
    } else if (value is double) {
      newFloat(out, value);
    } else if (value is bool) {
      newBool(out, value);
    } else if (value is String) {
      newStr(out, value);
    } else if (value is List) {
      newList(out);
      final tmp = pocket.py_pushtmp();
      for (final item in value) {
        fromDart(tmp, item);
        listAppend(out, tmp);
      }
      pocket.py_pop();
    } else if (value is Map) {
      newDict(out);
      final tmp = pocket.py_pushtmp();
      for (final entry in value.entries) {
        fromDart(tmp, entry.value);
        dictSetItemByStr(out, entry.key.toString(), tmp);
      }
      pocket.py_pop();
    } else {
      // Fallback: convert to string
      newStr(out, value.toString());
    }
  }

  // ---------------------------------------------------------------------------
  // Value conversion (Python → Dart)
  // ---------------------------------------------------------------------------

  /// Convert a Python value to a Dart object.
  Object? toDart(Pointer<py_TValue> ref) {
    if (ref == nullptr) return null;

    final type = pocket.py_typeof(ref);

    if (type == py_PredefinedType.tp_int) {
      return pocket.py_toint(ref);
    } else if (type == py_PredefinedType.tp_float) {
      return pocket.py_tofloat(ref);
    } else if (type == py_PredefinedType.tp_bool) {
      return pocket.py_tobool(ref);
    } else if (type == py_PredefinedType.tp_str) {
      final ptr = pocket.py_tostr(ref);
      return ptr.cast<Utf8>().toDartString();
    } else if (type == py_PredefinedType.tp_NoneType) {
      return null;
    } else if (type == py_PredefinedType.tp_list) {
      final len = pocket.py_list_len(ref);
      final result = <Object?>[];
      for (int i = 0; i < len; i++) {
        final item = pocket.py_list_getitem(ref, i);
        result.add(toDart(item));
      }
      return result;
    } else if (type == py_PredefinedType.tp_tuple) {
      final len = pocket.py_tuple_len(ref);
      final result = <Object?>[];
      for (int i = 0; i < len; i++) {
        final item = pocket.py_tuple_getitem(ref, i);
        result.add(toDart(item));
      }
      return result;
    } else if (type == py_PredefinedType.tp_dict) {
      // Dict → use repr for now
      if (!pocket.py_repr(ref)) return '<dict>';
      final ptr = pocket.py_tostr(pocket.py_retval());
      return ptr.cast<Utf8>().toDartString();
    } else if (type == py_PredefinedType.tp_bytes) {
      final sizePtr = calloc<Int>();
      final data = pocket.py_tobytes(ref, sizePtr);
      final size = sizePtr.value;
      calloc.free(sizePtr);
      final bytes = data.cast<Uint8>().asTypedList(size);
      return Uint8List.fromList(bytes);
    } else {
      // Unknown type → convert to string representation
      if (pocket.py_str(ref)) {
        final ptr = pocket.py_tostr(pocket.py_retval());
        return ptr.cast<Utf8>().toDartString();
      }
      return '<object>';
    }
  }

  /// Convert a Python value to a JSON-serializable Dart object.
  Object? toJsonCompatible(Pointer<py_TValue> ref) {
    final dart = toDart(ref);
    // Ensure the result is JSON-serializable
    if (dart == null || dart is num || dart is bool || dart is String) {
      return dart;
    }
    if (dart is List) {
      return dart.map((e) => e is Map || e is List ? e : e?.toString()).toList();
    }
    if (dart is Map) {
      return dart.map((k, v) => MapEntry(k.toString(), v?.toString()));
    }
    return dart.toString();
  }

  // ---------------------------------------------------------------------------
  // Registers (global scratch slots _0 .. _9)
  // ---------------------------------------------------------------------------

  /// Get a register slot (0-9). Accessible in Python as `_0` .. `_9`.
  Pointer<py_TValue> reg(int index) => pocket.py_getreg(index);

  /// Push a temporary slot onto the stack. Must call [pop] when done.
  Pointer<py_TValue> pushTmp() => pocket.py_pushtmp();

  /// Pop the top value from the stack.
  void pop() => pocket.py_pop();

  // ---------------------------------------------------------------------------
  // Exception handling
  // ---------------------------------------------------------------------------

  /// Check if an exception is currently active.
  bool hasException() => pocket.py_checkexc();

  /// Print the current exception to stdout.
  void printException() => pocket.py_printexc();

  /// Format the current exception as a Dart string. Returns null if no exception.
  String? formatException() {
    if (!pocket.py_checkexc()) return null;
    final ptr = pocket.py_formatexc();
    if (ptr == nullptr) return null;
    try {
      return ptr.cast<Utf8>().toDartString();
    } catch (_) {
      return '<exception: unable to format>';
    }
  }

  void _logException() {
    final msg = formatException();
    if (msg != null) {
      _log.warning('Python exception: $msg');
    }
  }

  // ---------------------------------------------------------------------------
  // Global/builtin access
  // ---------------------------------------------------------------------------

  /// Set a global variable in `__main__`.
  void setGlobal(String name, Pointer<py_TValue> value) {
    final nameId = this.name(name);
    pocket.py_setglobal(nameId, value);
  }

  /// Get a global variable from `__main__`. Returns null if not found.
  Pointer<py_TValue>? getGlobal(String name) {
    final nameId = this.name(name);
    final ref = pocket.py_getglobal(nameId);
    return ref == nullptr ? null : ref;
  }

  // ---------------------------------------------------------------------------
  // Watchdog (timeout protection)
  // ---------------------------------------------------------------------------

  /// Begin a watchdog timer. Raises TimeoutError in Python if [timeoutMs] elapses.
  void watchdogBegin(int timeoutMs) => pocket.py_watchdog_begin(timeoutMs);

  /// End the watchdog timer. Must be called after [watchdogBegin].
  void watchdogEnd() => pocket.py_watchdog_end();

  // ---------------------------------------------------------------------------
  // Garbage collection
  // ---------------------------------------------------------------------------

  /// Run the Python garbage collector. Returns number of objects collected.
  int gcCollect() => pocket.py_gc_collect();
}

/// Result of executing Python code.
class PyExecutionResult {
  final bool success;
  final String? error;

  const PyExecutionResult({required this.success, this.error});
}
