import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:surface/types/post.dart';

class FeedUnknownEntry extends StatelessWidget {
  final SnFeedEntry data;
  const FeedUnknownEntry({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Symbols.help, size: 36),
          const Gap(4),
          Text('feedUnknownItem').tr(),
          Text(data.type, style: GoogleFonts.robotoMono()),
        ],
      ).padding(horizontal: 12, vertical: 8),
    );
  }
}
