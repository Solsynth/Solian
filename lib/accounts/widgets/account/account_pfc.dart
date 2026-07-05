import 'package:flutter/material.dart';
import 'package:island/accounts/screens/profile.dart';

class AccountPfcRegion extends StatelessWidget {
  final String? uname;
  final Widget child;

  const AccountPfcRegion({super.key, required this.uname, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (uname != null) {
          showAccountProfileCard(context, uname!);
        }
      },
      child: child,
    );
  }
}

Future<void> showAccountProfileCard(
  BuildContext context,
  String uname, {
  Offset? offset,
}) {
  return showAccountProfileAttentionModal(uname);
}
