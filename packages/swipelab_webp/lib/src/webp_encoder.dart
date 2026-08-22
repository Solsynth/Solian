import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

// FFI bindings for swipelab_webp native library

final class WebPEncodeResult extends Struct {
  external Pointer<Uint8> data;

  @Size()
  external int size;

  @Int32()
  external int error;
}

typedef _EncodeRgbaNative = WebPEncodeResult Function(
  Pointer<Uint8> rgba,
  Int32 width,
  Int32 height,
  Int32 stride,
  Float quality,
);

typedef _EncodeRgbaLosslessNative = WebPEncodeResult Function(
  Pointer<Uint8> rgba,
  Int32 width,
  Int32 height,
  Int32 stride,
);

typedef _FreeNative = Void Function(Pointer<Uint8> data);

typedef _VersionNative = Int32 Function();

@Native<_EncodeRgbaNative>(symbol: 'swipelab_webp_encode_rgba', assetId: 'package:swipelab_webp/swipelab_webp.dart')
external WebPEncodeResult _encodeRgba(
  Pointer<Uint8> rgba,
  int width,
  int height,
  int stride,
  double quality,
);

@Native<_EncodeRgbaLosslessNative>(symbol: 'swipelab_webp_encode_rgba_lossless', assetId: 'package:swipelab_webp/swipelab_webp.dart')
external WebPEncodeResult _encodeRgbaLossless(
  Pointer<Uint8> rgba,
  int width,
  int height,
  int stride,
);

@Native<_FreeNative>(symbol: 'swipelab_webp_free', assetId: 'package:swipelab_webp/swipelab_webp.dart')
external void _free(Pointer<Uint8> data);

@Native<_VersionNative>(symbol: 'swipelab_webp_version', assetId: 'package:swipelab_webp/swipelab_webp.dart')
external int _version();

/// Input data for WebP encoding (can be passed to compute)
class WebPEncodeInput {
  const WebPEncodeInput({
    required this.rgba,
    required this.width,
    required this.height,
    this.quality = 80.0,
    this.lossless = false,
  });

  final Uint8List rgba;
  final int width;
  final int height;
  final double quality;
  final bool lossless;
}

/// Top-level function for use with compute()
Uint8List? encodeWebP(WebPEncodeInput input) {
  if (input.lossless) {
    return WebPEncoder.encodeRgbaLossless(
      rgba: input.rgba,
      width: input.width,
      height: input.height,
    );
  }
  return WebPEncoder.encodeRgba(
    rgba: input.rgba,
    width: input.width,
    height: input.height,
    quality: input.quality,
  );
}

class WebPEncoder {
  WebPEncoder._();

  /// Encode RGBA image data to WebP format (lossy)
  ///
  /// [rgba] - Raw RGBA pixel data (4 bytes per pixel)
  /// [width] - Image width in pixels
  /// [height] - Image height in pixels
  /// [quality] - Quality factor (0.0 to 100.0, higher is better quality)
  ///
  /// Returns encoded WebP data as Uint8List, or null on error
  static Uint8List? encodeRgba({
    required Uint8List rgba,
    required int width,
    required int height,
    double quality = 80.0,
  }) {
    final stride = width * 4;
    final inputPtr = malloc<Uint8>(rgba.length);
    inputPtr.asTypedList(rgba.length).setAll(0, rgba);

    try {
      final result = _encodeRgba(inputPtr, width, height, stride, quality);

      if (result.error != 0 || result.data == nullptr) {
        return null;
      }

      final output = Uint8List.fromList(
        result.data.asTypedList(result.size),
      );

      _free(result.data);
      return output;
    } finally {
      malloc.free(inputPtr);
    }
  }

  /// Encode RGBA image data to WebP format (lossless)
  ///
  /// [rgba] - Raw RGBA pixel data (4 bytes per pixel)
  /// [width] - Image width in pixels
  /// [height] - Image height in pixels
  ///
  /// Returns encoded WebP data as Uint8List, or null on error
  static Uint8List? encodeRgbaLossless({
    required Uint8List rgba,
    required int width,
    required int height,
  }) {
    final stride = width * 4;
    final inputPtr = malloc<Uint8>(rgba.length);
    inputPtr.asTypedList(rgba.length).setAll(0, rgba);

    try {
      final result = _encodeRgbaLossless(inputPtr, width, height, stride);

      if (result.error != 0 || result.data == nullptr) {
        return null;
      }

      final output = Uint8List.fromList(
        result.data.asTypedList(result.size),
      );

      _free(result.data);
      return output;
    } finally {
      malloc.free(inputPtr);
    }
  }

  /// Get the libwebp encoder version
  /// Returns version as hex: 0xMMmmrr (Major, minor, revision)
  static int get version => _version();

  /// Get version as string (e.g., "1.4.0")
  static String get versionString {
    final v = version;
    final major = (v >> 16) & 0xff;
    final minor = (v >> 8) & 0xff;
    final revision = v & 0xff;
    return '$major.$minor.$revision';
  }
}
