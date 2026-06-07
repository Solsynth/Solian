/// Cross-platform File abstraction.
///
/// On native platforms (dart:io available), re-exports dart:io's File.
/// On web, provides a minimal File stub.
export 'platform_file_stub.dart'
    if (dart.library.io) 'dart:io' show File;
