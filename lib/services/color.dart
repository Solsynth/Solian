import 'package:flutter/widgets.dart';

extension ColorInversion on Color {
  Color get invert {
    return Color.fromARGB(alpha, 255 - red, 255 - green, 255 - blue);
  }
}
