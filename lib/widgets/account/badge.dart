import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:surface/screens/account/profile_page.dart' show kBadgesMeta;
import 'package:surface/types/account.dart';

class AccountBadge extends StatelessWidget {
  final SnAccountBadge badge;
  final double radius;
  final EdgeInsets? padding;
  const AccountBadge({
    super.key,
    required this.badge,
    this.radius = 20,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: TextSpan(
        children: [
          TextSpan(text: kBadgesMeta[badge.type]?.$1.tr() ?? 'unknown'.tr()),
          if (badge.metadata['title'] != null)
            TextSpan(
              text: '\n${badge.metadata['title']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          TextSpan(text: '\n'),
          TextSpan(
            text: DateFormat.yMEd().format(badge.createdAt),
          ),
        ],
      ),
      child: Container(
        padding: padding ?? EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: kBadgesMeta[badge.type]?.$3,
        ),
        child: Icon(
          kBadgesMeta[badge.type]?.$2 ?? Symbols.question_mark,
          color: Colors.white,
          fill: 1,
          size: radius - 4,
        ),
      ),
    );
  }
}
