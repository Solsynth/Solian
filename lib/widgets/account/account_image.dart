import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/sn_network.dart';
import 'package:surface/widgets/universal_image.dart';

class AccountImage extends StatelessWidget {
  final String? content;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? radius;
  final double? borderRadius;
  final Widget? fallbackWidget;
  final Widget? badge;
  final Offset? badgeOffset;
  final FilterQuality? filterQuality;

  const AccountImage({
    super.key,
    required this.content,
    this.backgroundColor,
    this.foregroundColor,
    this.radius,
    this.borderRadius,
    this.fallbackWidget,
    this.badge,
    this.badgeOffset,
    this.filterQuality,
  });

  @override
  Widget build(BuildContext context) {
    final sn = context.read<SnNetworkProvider>();
    final url = sn.getAttachmentUrl(content ?? '');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: (radius != null ? radius! : 20) * 2,
          height: (radius != null ? radius! : 20) * 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius ?? radius ?? 20),
            child: (content?.isEmpty ?? true)
                ? Container(
                    color: backgroundColor ??
                        Theme.of(context).colorScheme.primaryContainer,
                    child: (fallbackWidget ??
                            Icon(
                              Symbols.account_circle,
                              size: radius != null ? radius! * 1.2 : 24,
                              color: foregroundColor,
                            ))
                        .center(),
                  )
                : UniversalImage(
                    sn.getAttachmentUrl(url),
                    filterQuality: filterQuality,
                    key: Key('attachment-${content.hashCode}'),
                    fit: BoxFit.cover,
                    width: (radius != null ? radius! : 20) * 2,
                    height: (radius != null ? radius! : 20) * 2,
                    cacheWidth: (radius != null ? radius! : 20) * 2,
                    cacheHeight: (radius != null ? radius! : 20) * 2,
                  ),
          ),
        ),
        if (badge != null)
          Positioned(
            right: badgeOffset?.dx ?? -4,
            bottom: badgeOffset?.dy ?? -2,
            child: badge!,
          ),
      ],
    );
  }
}
