/// Tray integration facade.
///
/// `package:tray_manager` requires `dart:ffi` (via `package:nativeapi`) and
/// cannot be compiled into web builds, so the desktop implementation lives in
/// `tray_manager_native.dart` and web resolves to the no-op stub.
library;

export 'tray_manager_stub.dart' if (dart.library.io) 'tray_manager_native.dart';
