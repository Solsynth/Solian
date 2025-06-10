import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:island/models/user.dart';
import 'package:material_symbols_icons/symbols.dart';

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
