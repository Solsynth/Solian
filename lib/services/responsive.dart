import 'package:flutter/widgets.dart';

const kWideScreenWidth = 768.0;
const kWiderScreenWidth = 1024.0;
const kWidescreenWidth = 1280.0;

bool isWideScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWideScreenWidth;
}

bool isWiderScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWiderScreenWidth;
}

bool isWidestScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWidescreenWidth;
}

EdgeInsets getTabbedPadding(
  BuildContext context, {
  double? horizontal,
  double? vertical,
  double? left,
  double? right,
  double? top,
  double? bottom,
}) {
  final bottomPadding = bottom ?? MediaQuery.of(context).padding.bottom + 16;
  return EdgeInsets.only(
    left: left ?? horizontal ?? 0,
    right: right ?? horizontal ?? 0,
    top: top ?? vertical ?? 0,
    bottom:
        bottom != null
            ? bottomPadding
            : MediaQuery.of(context).padding.bottom + 16,
  );
}
