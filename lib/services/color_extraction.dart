import 'package:flutter/widgets.dart';
import 'package:image/image.dart' as img;
import 'package:island/talker.dart';
import 'package:material_color_utilities/material_color_utilities.dart' as mcu;

class ColorExtractionService {
  /// Extracts dominant colors from an image provider.
  /// Returns a list of colors suitable for UI theming.
  static Future<List<Color>> getColorsFromImage(ImageProvider provider) async {
    try {
      if (provider is FileImage) {
        final bytes = await provider.file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) return [];
        final Map<int, int> colorToCount = {};
        for (int y = 0; y < image.height; y++) {
          for (int x = 0; x < image.width; x++) {
            final pixel = image.getPixel(x, y);
            final r = pixel.r.toInt();
            final g = pixel.g.toInt();
            final b = pixel.b.toInt();
            final a = pixel.a.toInt();
            if (a == 0) continue;
            final argb = (a << 24) | (r << 16) | (g << 8) | b;
            colorToCount[argb] = (colorToCount[argb] ?? 0) + 1;
          }
        }
        final List<int> filteredResults = mcu.Score.score(
          colorToCount,
          desired: 1,
          filter: true,
        );
        final List<int> scoredResults = mcu.Score.score(
          colorToCount,
          desired: 4,
          filter: false,
        );
        return <dynamic>{
          ...filteredResults,
          ...scoredResults,
        }.toList().map((argb) => Color(argb)).toList();
      } else {
        return [];
      }
    } catch (e, stackTrace) {
      talker.error('Error getting colors from image...', e, stackTrace);
      return [];
    }
  }
}
