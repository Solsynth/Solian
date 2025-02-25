import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/widgets/universal_image.dart';

class AccountImage extends StatelessWidget {
  final String? content;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? radius;
  final Widget? fallbackWidget;
  final Widget? badge;

  const AccountImage({
    super.key,
    required this.content,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.fallbackWidget,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();
    final url = sn.getAttachmentUrl(content ?? '');

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Stack(
      children: [
        CircleAvatar(
          key: Key('attachment-${content.hashCode}'),
          radius: radius,
          backgroundColor: backgroundColor,
          backgroundImage: (content?.isNotEmpty ?? false)
              ? ResizeImage(
                  UniversalImage.provider(url),
                  width: ((radius ?? 20) * devicePixelRatio * 2).round(),
                  height: ((radius ?? 20) * devicePixelRatio * 2).round(),
                  policy: ResizeImagePolicy.fit,
                )
              : null,
          child: (content?.isEmpty ?? true)
              ? (fallbackWidget ??
                  Icon(
                    Symbols.account_circle,
                    size: radius != null ? radius! * 1.2 : 24,
                    color: foregroundColor,
                  ))
              : null,
        ),
        if (badge != null)
          Positioned(
            right: -4,
            bottom: -4,
            child: badge!,
          ),
      ],
    );
  }
}
