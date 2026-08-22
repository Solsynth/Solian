import 'dart:typed_data';
import 'package:swipelab_webp/swipelab_webp.dart';

void main() {
  print('Testing swipelab_webp...');
  print('WebP encoder version: ${WebPEncoder.versionString}');

  // Create a simple 100x100 red image (RGBA)
  final width = 100;
  final height = 100;
  final rgba = Uint8List(width * height * 4);

  // Fill with red pixels (R=255, G=0, B=0, A=255)
  for (var i = 0; i < width * height; i++) {
    rgba[i * 4 + 0] = 255; // R
    rgba[i * 4 + 1] = 0; // G
    rgba[i * 4 + 2] = 0; // B
    rgba[i * 4 + 3] = 255; // A
  }

  print('Input image: ${width}x${height}, ${rgba.length} bytes');

  // Test lossy encoding
  final webpLossy = WebPEncoder.encodeRgba(
    rgba: rgba,
    width: width,
    height: height,
    quality: 80.0,
  );

  if (webpLossy == null) {
    throw Exception('Lossy encoding failed');
  }

  print(
    'Lossy WebP: ${webpLossy.length} bytes '
    '(compression ratio: ${(rgba.length / webpLossy.length).toStringAsFixed(2)}x)',
  );

  // Verify WebP signature (RIFF....WEBP)
  final validSignature = webpLossy.length >= 12 &&
      webpLossy[0] == 0x52 && // 'R'
      webpLossy[1] == 0x49 && // 'I'
      webpLossy[2] == 0x46 && // 'F'
      webpLossy[3] == 0x46 && // 'F'
      webpLossy[8] == 0x57 && // 'W'
      webpLossy[9] == 0x45 && // 'E'
      webpLossy[10] == 0x42 && // 'B'
      webpLossy[11] == 0x50; // 'P'

  if (!validSignature) {
    throw Exception('Invalid WebP signature');
  }
  print('Valid WebP signature');

  // Test lossless encoding
  final webpLossless = WebPEncoder.encodeRgbaLossless(
    rgba: rgba,
    width: width,
    height: height,
  );

  if (webpLossless == null) {
    throw Exception('Lossless encoding failed');
  }

  print(
    'Lossless WebP: ${webpLossless.length} bytes '
    '(compression ratio: ${(rgba.length / webpLossless.length).toStringAsFixed(2)}x)',
  );

  // Test with compute() helper function
  final input = WebPEncodeInput(
    rgba: rgba,
    width: width,
    height: height,
    quality: 90.0,
  );

  final webpCompute = encodeWebP(input);
  if (webpCompute == null) {
    throw Exception('encodeWebP function failed');
  }

  print('encodeWebP (for compute): ${webpCompute.length} bytes');

  print('\nAll tests passed!');
}
