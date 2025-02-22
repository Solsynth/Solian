import 'package:drift/wasm.dart';

// Use `dart compile js -O4 ./drift_worker.dart` to compile this file.
// And place it in the web/ directory.

// When compiled with dart2js, this file defines a dedicated or shared web
// worker used by drift.
void main() => WasmDatabase.workerMainForOpen();