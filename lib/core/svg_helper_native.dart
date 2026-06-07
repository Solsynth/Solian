import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Native implementation: uses SvgPicture.file for cached files.
Widget buildSvgFromFile(
  String filePath, {
  required double width,
  required double height,
  required ColorFilter? colorFilter,
  required IconData fallbackIcon,
  required Color fallbackColor,
}) {
  return SvgPicture.file(
    File(filePath),
    width: width,
    height: height,
    colorFilter: colorFilter,
    placeholderBuilder: (_) =>
        Icon(fallbackIcon, size: width, color: fallbackColor),
  );
}
