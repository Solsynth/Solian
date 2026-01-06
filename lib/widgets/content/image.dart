import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UniversalImage extends HookWidget {
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
  Widget build(BuildContext context) {
    final loaded = useState(false);
    final isSvgImage = isSvg || uri.toLowerCase().endsWith('.svg');

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
          CachedNetworkImage(
            imageUrl: uri,
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
                if (context.mounted) return loaded.value = true;
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
            errorWidget: (context, url, error) => useFallbackImage
                ? Image.asset(
                    'assets/images/media-offline.jpg',
                    fit: BoxFit.cover,
                    key: Key('image-broke-$uri'),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
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
