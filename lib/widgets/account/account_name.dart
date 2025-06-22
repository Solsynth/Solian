import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/user.dart';
import 'package:island/models/wallet.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';

const kVerificationMarkColors = [
  Colors.teal,
  Colors.blue,
  Colors.amber,
  Colors.blueGrey,
  Colors.lightBlue,
];

class AccountName extends StatelessWidget {
  final SnAccount account;
  final TextStyle? style;
  const AccountName({super.key, required this.account, this.style});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Flexible(child: Text(account.nick, style: style)),
        if (account.profile.stellarMembership != null)
          StellarMembershipMark(membership: account.profile.stellarMembership!),
        if (account.profile.verification != null)
          VerificationMark(mark: account.profile.verification!),
      ],
    );
  }
}

class VerificationMark extends StatelessWidget {
  final SnVerificationMark mark;
  const VerificationMark({super.key, required this.mark});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      richMessage: TextSpan(
        text: mark.title ?? 'No title',
        children: [
          TextSpan(text: '\n'),
          TextSpan(
            text: mark.description ?? 'descriptionNone'.tr(),
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Icon(
        mark.type == 4
            ? Symbols.play_circle
            : mark.type == 0
            ? Symbols.build_circle
            : Symbols.verified,
        size: 16,
        color: kVerificationMarkColors[mark.type],
        fill: 1,
      ),
    );
  }
}

class StellarMembershipMark extends StatelessWidget {
  final SnWalletSubscriptionRef membership;
  const StellarMembershipMark({super.key, required this.membership});

  String _getMembershipTierName(String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return 'membershipTierStellar'.tr();
      case 'solian.stellar.nova':
        return 'membershipTierNova'.tr();
      case 'solian.stellar.supernova':
        return 'membershipTierSupernova'.tr();
      default:
        return 'membershipTierUnknown'.tr();
    }
  }

  Color _getMembershipTierColor(String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return Colors.amber;
      case 'solian.stellar.nova':
        return Colors.blue;
      case 'solian.stellar.supernova':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getMembershipTierIcon(String identifier) {
    switch (identifier) {
      case 'solian.stellar.primary':
        return Symbols.star;
      case 'solian.stellar.nova':
        return Symbols.auto_awesome;
      case 'solian.stellar.supernova':
        return Symbols.diamond;
      default:
        return Symbols.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!membership.isActive) return const SizedBox.shrink();

    final tierName = _getMembershipTierName(membership.identifier);
    final tierColor = _getMembershipTierColor(membership.identifier);
    final tierIcon = _getMembershipTierIcon(membership.identifier);

    return Tooltip(
      richMessage: TextSpan(
        text: 'stellarMembership'.tr(),
        children: [
          TextSpan(text: '\n'),
          TextSpan(
            text: 'currentMembership'.tr(args: [tierName]),
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
        ],
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      child: Icon(tierIcon, size: 16, color: tierColor, fill: 1),
    );
  }
}

class VerificationStatusCard extends StatelessWidget {
  final SnVerificationMark mark;
  const VerificationStatusCard({super.key, required this.mark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            mark.type == 4
                ? Symbols.play_circle
                : mark.type == 0
                ? Symbols.build_circle
                : Symbols.verified,
            size: 32,
            color: kVerificationMarkColors[mark.type],
            fill: 1,
          ),
          const Gap(8),
          Text(mark.title ?? 'No title').bold(),
          Text(mark.description ?? 'descriptionNone'.tr()),
          const Gap(6),
          Text(
            'Verified by\n${mark.verifiedBy ?? 'No one verified it'}',
          ).fontSize(11).opacity(0.8),
        ],
      ).padding(horizontal: 24, vertical: 16),
    );
  }
}
