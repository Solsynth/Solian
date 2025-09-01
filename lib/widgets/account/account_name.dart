import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:island/models/account.dart';
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
    var nameStyle = (style ?? TextStyle());
    if (account.perkSubscription != null) {
      nameStyle = nameStyle.copyWith(
        color: (switch (account.perkSubscription!.identifier) {
          'solian.stellar.primary' => Colors.blueAccent,
          'solian.stellar.nova' => Color.fromRGBO(57, 197, 187, 1),
          'solian.stellar.supernova' => Colors.amberAccent,
          _ => null,
        }),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Flexible(child: Text(account.nick, style: nameStyle)),
        if (account.perkSubscription != null)
          StellarMembershipMark(membership: account.perkSubscription!),
        if (account.profile.verification != null)
          VerificationMark(mark: account.profile.verification!),
        if (account.automatedId != null)
          Tooltip(
            message: 'accountAutomated'.tr(),
            child: Icon(
              Symbols.smart_toy,
              size: 16,
              color: nameStyle.color,
              fill: 1,
            ),
          ),
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
        return Colors.blue;
      case 'solian.stellar.nova':
        return Color.fromRGBO(57, 197, 187, 1);
      case 'solian.stellar.supernova':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!membership.isActive) return const SizedBox.shrink();

    final tierName = _getMembershipTierName(membership.identifier);
    final tierColor = _getMembershipTierColor(membership.identifier);
    final tierIcon = Symbols.kid_star;

    return Tooltip(
      richMessage: TextSpan(
        text: 'stellarMembership'.tr(),
        children: [
          TextSpan(text: '\n'),
          TextSpan(
            text: 'currentMembershipMember'.tr(args: [tierName]),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        ).alignment(Alignment.centerLeft),
        const Gap(8),
        Text(mark.title ?? 'No title').bold(),
        Text(mark.description ?? 'descriptionNone'.tr()),
        const Gap(6),
        Text(
          'Verified by\n${mark.verifiedBy ?? 'No one verified it'}',
        ).fontSize(11).opacity(0.8),
      ],
    ).padding(horizontal: 24, vertical: 16);
  }
}
