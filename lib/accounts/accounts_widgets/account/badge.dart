import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/accounts/accounts_models/account.dart';
import 'package:island/accounts/accounts_models/badge.dart';

class BadgeList extends StatelessWidget {
  final List<SnAccountBadge> badges;
  const BadgeList({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((badge) => BadgeItem(badge: badge)).toList(),
    );
  }
}

class BadgeItem extends StatelessWidget {
  final SnAccountBadge badge;
  const BadgeItem({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    final template = kBadgeTemplates[badge.type];
    final name = badge.label ?? template?.name.tr() ?? 'unknown'.tr();
    final description = badge.caption ?? template?.description.tr() ?? '';

    return Tooltip(
      message: '$name\n$description',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: (template?.color ?? Colors.blue).withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          template?.icon ?? Icons.stars,
          color: template?.color ?? Colors.blue,
          size: 20,
        ),
      ),
    );
  }
}
