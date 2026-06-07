import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Web stub: always uses SvgPicture.network.
/// The [filePath] parameter is ignored on web.
Widget buildSvgFromFile(
  String filePath, {
  required double width,
  required double height,
  required ColorFilter? colorFilter,
  required IconData fallbackIcon,
  required Color fallbackColor,
}) {
  // On web, always use network (filePath is actually the URL)
  return SvgPicture.network(
    filePath,
    width: width,
    height: height,
    colorFilter: colorFilter,
    placeholderBuilder: (_) =>
        Icon(fallbackIcon, size: width, color: fallbackColor),
  );
}
