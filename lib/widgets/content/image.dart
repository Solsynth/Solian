import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UniversalImage extends StatelessWidget {
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
    final isSvgImage = isSvg || uri.toLowerCase().endsWith('.svg');

    if (isSvgImage) {
      return SvgPicture.network(
        uri,
        fit: fit,
        width: width,
        height: height,
        placeholderBuilder:
            (BuildContext context) =>
                Center(child: CircularProgressIndicator()),
      );
    }

    int? cacheWidth;
    int? cacheHeight;
    if (width != null && height != null && !noCacheOptimization) {
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      cacheWidth = width != null ? (width! * devicePixelRatio).round() : null;
      cacheHeight =
          height != null ? (height! * devicePixelRatio).round() : null;
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
                child: CircularProgressIndicator(value: progress.progress),
              );
            },
            errorWidget:
                (context, url, error) =>
                    useFallbackImage
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
