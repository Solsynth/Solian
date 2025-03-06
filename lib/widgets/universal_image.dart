import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:surface/providers/config.dart';
// Keep this import to make the web image render work
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';

class UniversalImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit? fit;
  final bool noProgressIndicator;
  final bool noErrorWidget;
  final double? cacheWidth, cacheHeight;
  final FilterQuality? filterQuality;

  const UniversalImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.noProgressIndicator = false,
    this.noErrorWidget = false,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double? resizeHeight =
        cacheHeight != null ? (cacheHeight! * devicePixelRatio) : null;
    final double? resizeWidth =
        cacheWidth != null ? (cacheWidth! * devicePixelRatio) : null;

    return Image(
      filterQuality:
          filterQuality ?? context.read<ConfigProvider>().imageQuality,
      image: kIsWeb
          ? UniversalImage.provider(url)
          : ResizeImage(
              UniversalImage.provider(url),
              width: resizeWidth?.round(),
              height: resizeHeight?.round(),
              policy: ResizeImagePolicy.fit,
            ),
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: noProgressIndicator
          ? null
          : (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                constraints: BoxConstraints(maxHeight: 80),
                child: Center(
                  child: TweenAnimationBuilder(
                    tween: Tween(
                      begin: 0,
                      end: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : 0,
                    ),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? value.toDouble()
                          : null,
                    ),
                  ),
                ),
              );
            },
      errorBuilder: noErrorWidget
          ? null
          : (context, error, stackTrace) {
              return Material(
                color: Theme.of(context).colorScheme.surface,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimateWidgetExtensions(Icon(Symbols.close, size: 24))
                          .animate(onPlay: (e) => e.repeat(reverse: true))
                          .fade(duration: 500.ms),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ).center(),
                ),
              );
            },
    );
  }

  static ImageProvider provider(String url) {
    // This place used to use network image or cached network image depending on the platform.
    // But now the cached network image is working on every platform.
    // So we just use it now.
    return CachedNetworkImageProvider(
      url,
      imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
    );
  }
}

class AutoResizeUniversalImage extends StatelessWidget {
  final String url;
  final double? width, height;
  final BoxFit? fit;
  final bool noProgressIndicator;
  final bool noErrorWidget;
  final FilterQuality? filterQuality;

  const AutoResizeUniversalImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.noProgressIndicator = false,
    this.noErrorWidget = false,
    this.filterQuality,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return UniversalImage(
        url,
        fit: fit,
        width: width,
        height: height,
        noProgressIndicator: noProgressIndicator,
        noErrorWidget: noErrorWidget,
        cacheHeight: constraints.maxHeight,
        cacheWidth: constraints.maxWidth,
        filterQuality: filterQuality,
      );
    });
  }
}
