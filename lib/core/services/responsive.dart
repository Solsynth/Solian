import 'package:flutter/widgets.dart';

const kWideScreenWidth = 768.0;
const kWiderScreenWidth = 1024.0;
const kWidescreenWidth = 1280.0;
const kUltraWideScreenWidth = 1600.0;

enum ResponsiveTier { compact, medium, wide, ultraWide }

bool isWideScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWideScreenWidth;
}

bool isWiderScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWiderScreenWidth;
}

bool isWidestScreen(BuildContext context) {
  return MediaQuery.of(context).size.width > kWidescreenWidth;
}

ResponsiveTier responsiveTierOf(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width > kUltraWideScreenWidth) return ResponsiveTier.ultraWide;
  if (width > kWidescreenWidth) return ResponsiveTier.wide;
  if (width > kWideScreenWidth) return ResponsiveTier.medium;
  return ResponsiveTier.compact;
}

extension ResponsiveLayoutContext on BuildContext {
  ResponsiveTier get responsiveTier => responsiveTierOf(this);

  bool get isCompactScreen => responsiveTier == ResponsiveTier.compact;

  bool get isMediumScreen => responsiveTier == ResponsiveTier.medium;

  bool get isTwoPaneScreen => responsiveTier != ResponsiveTier.compact;

  bool get isDesktopScreen =>
      responsiveTier == ResponsiveTier.wide ||
      responsiveTier == ResponsiveTier.ultraWide;

  double get responsivePagePadding {
    switch (responsiveTier) {
      case ResponsiveTier.compact:
        return 16;
      case ResponsiveTier.medium:
        return 24;
      case ResponsiveTier.wide:
        return 32;
      case ResponsiveTier.ultraWide:
        return 40;
    }
  }

  double get responsiveSectionGap {
    switch (responsiveTier) {
      case ResponsiveTier.compact:
        return 16;
      case ResponsiveTier.medium:
        return 20;
      case ResponsiveTier.wide:
        return 24;
      case ResponsiveTier.ultraWide:
        return 32;
    }
  }
}
