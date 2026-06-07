/// Cross-platform File abstraction.
///
/// On web, dart:io is not available, so we provide a minimal stub.
/// On native platforms, we re-export dart:io's File.
library;

// This file is used as a conditional import target.
// On native: dart:io is available and File works normally.
// On web: this stub provides a no-op File class.

class File {
  final String path;
  File(this.path);
}
