import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';

class UniversalImage extends HookConsumerWidget {
  final String uri;
  final String? blurHash;
  final BoxFit fit;
  final double? width;
  final double? height;
  final bool noCacheOptimization;
  final bool isSvg;
  final bool useFallbackImage;

  const UniversalImage({
    super.key,
    required this.uri,
    this.blurHash,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.noCacheOptimization = false,
    this.isSvg = false,
    this.useFallbackImage = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = useState(false);
    final isCached = useState<bool?>(null);
    final isSvgImage = isSvg || uri.toLowerCase().endsWith('.svg');

    final serverUrl = ref.watch(serverUrlProvider);
    final token = ref.watch(tokenProvider);

    final Map<String, String>? httpHeaders =
        uri.startsWith(serverUrl) && token != null
        ? {'Authorization': 'AtField ${token.token}'}
        : null;

    useEffect(() {
      DefaultCacheManager().getFileFromCache(uri).then((fileInfo) {
        isCached.value = fileInfo != null;
      });
      return null;
    }, [uri]);

    if (isSvgImage) {
      return SvgPicture.network(
        uri,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder: (BuildContext context) =>
            Center(child: CircularProgressIndicator()),
      );
    }

    int? cacheWidth;
    int? cacheHeight;
    if (width != null && height != null && !noCacheOptimization) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      cacheWidth = width != null ? (width! * devicePixelRatio).round() : null;
      cacheHeight = height != null
          ? (height! * devicePixelRatio).round()
          : null;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (blurHash != null) BlurHash(hash: blurHash!),
          if (isCached.value == null)
            Center(child: CircularProgressIndicator())
          else if (isCached.value!)
            CachedNetworkImage(
              imageUrl: uri,
              httpHeaders: httpHeaders,
              fit: fit,
              width: width,
              height: height,
              memCacheHeight: cacheHeight,
              memCacheWidth: cacheWidth,
              imageBuilder: (context, imageProvider) => Image(
                image: imageProvider,
                fit: fit,
                width: width,
                height: height,
              ),
              errorWidget: (context, url, error) => CachedImageErrorWidget(
                useFallbackImage: useFallbackImage,
                uri: uri,
                blurHash: blurHash,
                error: error,
                debug: true,
              ),
            )
          else
            CachedNetworkImage(
              imageUrl: uri,
              httpHeaders: httpHeaders,
              fit: fit,
              width: width,
              height: height,
              memCacheHeight: cacheHeight,
              memCacheWidth: cacheWidth,
              progressIndicatorBuilder: (context, url, progress) {
                return Center(
                  child: AnimatedCircularProgressIndicator(
                    value: progress.progress,
                    color: Colors.white.withOpacity(0.5),
                  ),
                );
              },
              imageBuilder: (context, imageProvider) {
                Future(() {
                  if (context.mounted) loaded.value = true;
                });
                return AnimatedOpacity(
                  opacity: loaded.value ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Image(
                    image: imageProvider,
                    fit: fit,
                    width: width,
                    height: height,
                  ),
                );
              },
              errorWidget: (context, url, error) => CachedImageErrorWidget(
                useFallbackImage: useFallbackImage,
                uri: uri,
                blurHash: blurHash,
                error: error,
                debug: true,
              ),
            ),
        ],
      ),
    );
  }
}

class CachedImageErrorWidget extends StatelessWidget {
  final bool useFallbackImage;
  final String uri;
  final String? blurHash;
  final dynamic error;
  final bool debug;

  const CachedImageErrorWidget({
    super.key,
    required this.useFallbackImage,
    required this.uri,
    this.blurHash,
    this.error,
    this.debug = false,
  });

  int? _extractStatusCode(dynamic error) {
    if (error == null) return null;
    final errorString = error.toString();
    // Check for HttpException with status code
    final httpExceptionRegex = RegExp(r'Invalid statusCode: (\d+)');
    final match = httpExceptionRegex.firstMatch(errorString);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }
    // Check if error has statusCode property (like DioError)
    if (error.response?.statusCode != null) {
      return error.response.statusCode;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (debug && error != null) {
      debugPrint('Image load error for $uri: $error');
    }

    if (!useFallbackImage) {
      return SizedBox.shrink();
    }

    final statusCode = _extractStatusCode(error);

    return LayoutBuilder(
      builder: (context, constraints) {
        final minDimension = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final iconSize = math.max(
          minDimension * 0.3,
          28,
        ); // 30% of the smaller dimension
        final hasEnoughSpace = minDimension > 40;

        return Stack(
          fit: StackFit.expand,
          children: [
            if (blurHash != null)
              BlurHash(hash: blurHash!)
            else
              Image.asset(
                'assets/images/media-offline.jpg',
                fit: BoxFit.cover,
                key: Key('-$uri'),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getErrorIcon(statusCode),
                    color: Colors.white,
                    size: iconSize * 0.5,
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  if (hasEnoughSpace && statusCode != null) ...[
                    SizedBox(height: iconSize * 0.1),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: iconSize * 0.15,
                        vertical: iconSize * 0.05,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(iconSize * 0.1),
                      ),
                      child: Text(
                        statusCode.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: iconSize * 0.15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getErrorIcon(int? statusCode) {
    switch (statusCode) {
      case 403:
      case 401:
        return Icons.lock_rounded;
      case 404:
        return Icons.broken_image_rounded;
      case 500:
      case 502:
      case 503:
        return Icons.error_rounded;
      default:
        return Icons.broken_image_rounded;
    }
  }
}

class AnimatedCircularProgressIndicator extends HookWidget {
  final double? value;
  final Color? color;
  final double strokeWidth;
  final Duration duration;

  const AnimatedCircularProgressIndicator({
    super.key,
    this.value,
    this.color,
    this.strokeWidth = 4.0,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(duration: duration);
    final animation = useAnimation(
      Tween<double>(begin: 0.0, end: value ?? 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.linear),
      ),
    );

    useEffect(() {
      animationController.animateTo(value ?? 0.0);
      return null;
    }, [value]);

    return CircularProgressIndicator(
      value: animation,
      color: color,
      strokeWidth: strokeWidth,
      backgroundColor: Colors.transparent,
    );
  }
}
