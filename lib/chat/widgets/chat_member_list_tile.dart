import 'package:flutter/material.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

class ChatMemberListTile extends StatelessWidget {
  final SnChatMember member;
  final bool isE2eeReady;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;

  const ChatMemberListTile({
    super.key,
    required this.member,
    this.isE2eeReady = false,
    this.trailing,
    this.onTap,
    this.contentPadding = const EdgeInsets.only(left: 16, right: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: contentPadding,
      leading: AccountPfcRegion(
        uname: member.account.name,
        child: ProfilePictureWidget(file: member.account.profile.picture),
      ),
      title: Row(
        spacing: 6,
        children: [
          Flexible(child: Text(member.account.nick)),
          if (member.status != null)
            Flexible(
              child: AccountStatusLabel(
                status: member.status!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (member.realmLabel != null)
            RealmLabelWidget(label: member.realmLabel!, fontSize: 10),
          if (member.joinedAt == null)
            const Icon(Symbols.pending_actions, size: 20),
          if (member.joinedAt != null)
            Tooltip(
              message: isE2eeReady ? 'E2EE Ready' : 'E2EE Not Available',
              child: Icon(
                isE2eeReady ? Symbols.lock : Symbols.lock_open,
                size: 16,
                color: isE2eeReady
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ),
      subtitle: Text('@${member.account.name}'),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
