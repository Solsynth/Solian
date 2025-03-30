import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/providers/link_preview.dart';
import 'package:surface/types/link.dart';
import 'package:surface/widgets/universal_image.dart';
import 'package:url_launcher/url_launcher_string.dart';

class LinkPreviewWidget extends StatefulWidget {
  final String text;

  const LinkPreviewWidget({super.key, required this.text});

  @override
  State<LinkPreviewWidget> createState() => _LinkPreviewWidgetState();
}

class _LinkPreviewWidgetState extends State<LinkPreviewWidget> {
  final List<SnLinkMeta> _links = List.empty(growable: true);

  Future<void> _getLinkMeta() async {
    final linkRegex = RegExp(r'https?:\/\/[^\s/$.?#].[^\s]*');
    final links =
        linkRegex.allMatches(widget.text).map((e) => e.group(0)).toSet();

    final lp = context.read<SnLinkPreviewProvider>();

    final List<Future<SnLinkMeta?>> futures =
        links.where((e) => e != null).map((e) => lp.getLinkMeta(e!)).toList();
    final results = await Future.wait(futures);

    _links.addAll(results.where((e) => e != null).map((e) => e!).toList());
    if (_links.isNotEmpty && mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getLinkMeta();
  }

  @override
  Widget build(BuildContext context) {
    if (_links.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _links.map((e) => _LinkPreviewEntry(meta: e)).toList(),
    );
  }
}

class _LinkPreviewEntry extends StatelessWidget {
  final SnLinkMeta meta;

  const _LinkPreviewEntry({
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveBreakpoints.of(context).smallerOrEqualTo(MOBILE)
            ? double.infinity
            : 480,
      ),
      child: GestureDetector(
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (meta.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        child: AutoResizeUniversalImage(
                          meta.image!.startsWith('//')
                              ? 'https:${meta.image}'
                              : meta.image!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(
                height: 48,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (meta.icon?.isNotEmpty ?? false)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: meta.icon!.endsWith('.svg')
                            ? SvgPicture.network(meta.icon!,
                                width: 36, height: 36)
                            : UniversalImage(
                                meta.icon!,
                                noErrorWidget: true,
                                width: 36,
                                height: 36,
                                cacheHeight: 36,
                                cacheWidth: 36,
                              ),
                      ).padding(all: 4, right: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 24,
                            child: ((meta.title?.length ?? 0) > 32)
                                ? Marquee(
                                    text: meta.title ?? 'unknown'.tr(),
                                    style: TextStyle(fontSize: 17),
                                    scrollAxis: Axis.horizontal,
                                    showFadingOnlyWhenScrolling: true,
                                    pauseAfterRound: const Duration(seconds: 3),
                                  )
                                : Text(
                                    meta.title ?? 'unknown'.tr(),
                                    style: TextStyle(fontSize: 17),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                          if (meta.siteName != null)
                            Text(
                              meta.siteName!,
                              style: TextStyle(fontSize: 13, height: 0.9),
                            ).fontSize(11),
                        ],
                      ),
                    ),
                    const Gap(6),
                  ],
                ).padding(horizontal: 16),
              ),
              if (meta.description != null)
                Text(
                  meta.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ).padding(horizontal: 16, bottom: 8),
              Text(
                meta.url,
                style: GoogleFonts.roboto(fontSize: 11, height: 0.9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).opacity(0.75).padding(horizontal: 16),
              const Gap(4),
              Text(
                'poweredBy'.tr(args: ['HyperNet.Reader']),
                style: GoogleFonts.roboto(fontSize: 11, height: 0.9),
              ).opacity(0.75).padding(horizontal: 16),
              const Gap(16),
            ],
          ),
        ),
        onTap: () {
          launchUrlString(meta.url, mode: LaunchMode.externalApplication);
        },
      ),
    );
  }
}
