import 'package:media_kit/media_kit.dart';

/// Initializes media_kit through its normal platform loader.
///
/// On macOS, `media_kit_video` already links `Mpv.framework`. Supplying an
/// absolute path to `MediaKit.ensureInitialized` can make dyld load a second
/// image of that framework, which registers duplicate Objective-C classes and
/// can abort inside libmpv's configuration cache.
bool _initialized = false;

bool ensureMediaKitInitialized() {
  if (_initialized) return true;
  try {
    MediaKit.ensureInitialized();
    _initialized = true;
    return true;
  } catch (_) {
    return false;
  }
}
