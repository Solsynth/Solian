import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Build an SVG widget. On web, uses network URL. On native, uses cached file.
Widget buildSvgIcon({
  required String pathOrUrl,
  required bool isFilePath,
  required double width,
  required double height,
  required Color color,
  required ColorFilter? colorFilter,
  required IconData fallbackIcon,
}) {
  if (isFilePath) {
    // On web, this branch should never execute.
    // On native, this uses dart:io File via SvgPicture.file.
    return SvgPicture.network(
      pathOrUrl,
      width: width,
      height: height,
      colorFilter: colorFilter,
      placeholderBuilder: (_) =>
          Icon(fallbackIcon, size: width, color: color),
    );
  }
  return SvgPicture.network(
    pathOrUrl,
    width: width,
    height: height,
    colorFilter: colorFilter,
    placeholderBuilder: (_) =>
        Icon(fallbackIcon, size: width, color: color),
  );
}
