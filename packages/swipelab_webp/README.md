# swipelab_webp

High-performance WebP image encoding for Dart using native [libwebp](https://developers.google.com/speed/webp) via FFI.

## Features

- **Lossy encoding** with configurable quality (0-100)
- **Lossless encoding** for perfect quality preservation
- **High performance** native libwebp implementation
- **Isolate-friendly** with `compute()` support
- **Cross-platform** support for Android, iOS, Linux, macOS, and Windows

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  swipelab_webp: ^1.0.0
```

### Build Requirements

This package uses Dart's native assets feature to compile libwebp from source during the build process. The following are required:

- **Git** - to clone the libwebp source code
- **C compiler**:
  - macOS/iOS: Xcode Command Line Tools (Clang)
  - Linux: GCC (`sudo apt install build-essential`)
  - Windows: MSVC (Visual Studio Build Tools)
  - Android: NDK (install via Android Studio SDK Manager)

The libwebp source is automatically cloned from [swipelab/libwebp](https://github.com/swipelab/libwebp) on first build:
- macOS/Linux: `~/.cache/swipelab_webp/libwebp`
- Windows: `%LOCALAPPDATA%\swipelab_webp\libwebp`

## Usage

### Basic Encoding

```dart
import 'dart:typed_data';
import 'package:swipelab_webp/swipelab_webp.dart';

void main() {
  // Create RGBA image data (4 bytes per pixel)
  final width = 100;
  final height = 100;
  final rgba = Uint8List(width * height * 4);

  // Fill with red pixels (R=255, G=0, B=0, A=255)
  for (var i = 0; i < rgba.length; i += 4) {
    rgba[i] = 255;     // R
    rgba[i + 1] = 0;   // G
    rgba[i + 2] = 0;   // B
    rgba[i + 3] = 255; // A
  }

  // Lossy encoding (smaller file, slight quality loss)
  final lossy = WebPEncoder.encodeRgba(
    rgba: rgba,
    width: width,
    height: height,
    quality: 80.0, // 0.0 to 100.0
  );

  // Lossless encoding (perfect quality, larger file)
  final lossless = WebPEncoder.encodeRgbaLossless(
    rgba: rgba,
    width: width,
    height: height,
  );

  print('Lossy: ${lossy?.length} bytes');
  print('Lossless: ${lossless?.length} bytes');
}
```

### Using with Isolates

For encoding large images without blocking the UI, use `compute()`:

```dart
import 'package:flutter/foundation.dart';
import 'package:swipelab_webp/swipelab_webp.dart';

Future<Uint8List?> encodeInBackground(Uint8List rgba, int width, int height) {
  return compute(
    encodeWebP,
    WebPEncodeInput(
      rgba: rgba,
      width: width,
      height: height,
      quality: 85.0,
      lossless: false,
    ),
  );
}
```

### Version Information

```dart
// Get libwebp version
print('libwebp version: ${WebPEncoder.versionString}'); // e.g., "1.4.0"
print('libwebp version (hex): 0x${WebPEncoder.version.toRadixString(16)}');
```

## API Reference

### WebPEncoder

| Method | Description |
|--------|-------------|
| `encodeRgba()` | Encode RGBA data to lossy WebP |
| `encodeRgbaLossless()` | Encode RGBA data to lossless WebP |
| `version` | Get libwebp version as integer |
| `versionString` | Get libwebp version as string |

### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `rgba` | `Uint8List` | Raw RGBA pixel data (4 bytes per pixel) |
| `width` | `int` | Image width in pixels |
| `height` | `int` | Image height in pixels |
| `quality` | `double` | Quality factor 0.0-100.0 (lossy only) |

### Return Value

Both encoding methods return `Uint8List?`:
- Valid WebP data on success
- `null` on encoding error

## Performance Tips

- Use **lossy encoding** with quality 75-85 for photos (best size/quality ratio)
- Use **lossless encoding** for screenshots, diagrams, or images with text
- For large images, use `compute()` to avoid blocking the main isolate
- The native library is cached after first build, subsequent builds are fast

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

This package uses [libwebp](https://chromium.googlesource.com/webm/libwebp) by Google.
