import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/chat/widgets/chat_member_list_tile.dart';
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

/// Bottom sheet listing members who can be invited to the current call.
///
/// Mirrors the member-list sheet in [chat_detail_screen] (SearchBar + plain
/// list without dividers); the trailing call button pops the sheet with the
/// selected member.
class CallInviteSheet extends HookConsumerWidget {
  final List<SnChatMember> candidates;

  const CallInviteSheet({super.key, required this.candidates});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useListenable(searchController).text.trim().toLowerCase();

    final filtered = query.isEmpty
        ? candidates
        : candidates
              .where(
                (m) =>
                    m.account.nick.toLowerCase().contains(query) ||
                    m.account.name.toLowerCase().contains(query),
              )
              .toList();

    return SheetScaffold(
      titleText: 'inviteToCall'.tr(),
      heightFactor: 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SearchBar(
              controller: searchController,
              hintText: 'Search member account',
              leading: const Icon(Symbols.search),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              trailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () => searchController.clear(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('noResultsFound'.tr()))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final m = filtered[i];
                      return ChatMemberListTile(
                        member: m,
                        enableProfileCard: false,
                        trailing: IconButton(
                          icon: const Icon(Symbols.call),
                          tooltip: 'inviteToCall'.tr(),
                          onPressed: () => Navigator.pop(context, m),
                        ),
                        onTap: () => Navigator.pop(context, m),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
