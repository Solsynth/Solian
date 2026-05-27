import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/database.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:island/core/network.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'relationship.g.dart';

@riverpod
Future<List<SnRelationship>> friendRequest(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final resp = await client.get('/passport/relationships/requests');
  return resp.data
      .map((e) => SnRelationship.fromJson(e))
      .cast<SnRelationship>()
      .toList();
}

final relationshipListNotifierProvider = AsyncNotifierProvider.autoDispose(
  RelationshipListNotifier.new,
);

class RelationshipListNotifier
    extends AsyncNotifier<PaginationState<SnRelationship>>
    with AsyncPaginationController<SnRelationship> {
  @override
  FutureOr<PaginationState<SnRelationship>> build() async {
    final db = ref.read(databaseProvider);

    // Load from local cache first
    try {
      final localRelationships = await db.getAllRelationships();
      if (localRelationships.isNotEmpty) {
        // Show local data immediately, then sync with API in background
        _syncWithApiInBackground(db);

        return PaginationState(
          items: localRelationships,
          isLoading: false,
          isReloading: false,
          totalCount: localRelationships.length,
          hasMore: true, // Assume more until we know from API
          cursor: localRelationships.length.toString(),
        );
      }
    } catch (_) {
      // If local cache fails, fall through to API
    }

    // Fallback to API if no local data
    final items = await fetch();
    return PaginationState(
      items: items,
      isLoading: false,
      isReloading: false,
      totalCount: totalCount,
      hasMore: hasMore,
      cursor: cursor,
    );
  }

  Future<void> _syncWithApiInBackground(dynamic db) async {
    try {
      final client = ref.read(apiClientProvider);
      final response = await client.get(
        '/passport/relationships',
        queryParameters: {'offset': '0', 'take': '100'},
      );

      final List<SnRelationship> items = (response.data as List)
          .map((e) => SnRelationship.fromJson(e as Map<String, dynamic>))
          .cast<SnRelationship>()
          .toList();

      // Save to local cache
      await db.saveRelationships(items);

      // Update state with fresh data
      final total =
          int.tryParse(response.headers['x-total']?.first ?? '') ?? 0;
      state = AsyncData(
        PaginationState(
          items: items,
          isLoading: false,
          isReloading: false,
          totalCount: total,
          hasMore: items.length < total,
          cursor: items.length.toString(),
        ),
      );
    } catch (_) {
      // Background sync failed, keep showing local data
    }
  }

  @override
  Future<List<SnRelationship>> fetch() async {
    final db = ref.read(databaseProvider);
    final client = ref.read(apiClientProvider);
    final take = 20;

    final response = await client.get(
      '/passport/relationships',
      queryParameters: {'offset': fetchedCount.toString(), 'take': take},
    );

    final List<SnRelationship> items = (response.data as List)
        .map((e) => SnRelationship.fromJson(e as Map<String, dynamic>))
        .cast<SnRelationship>()
        .toList();

    totalCount = int.tryParse(response.headers['x-total']?.first ?? '') ?? 0;

    // Save to local cache
    await db.saveRelationships(items);

    return items;
  }
}

class RelationshipListTile extends StatelessWidget {
  final SnRelationship relationship;
  final bool submitting;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final bool showActions;
  final String? currentUserId;
  final bool showRelatedAccount;
  final Function(SnRelationship, int)? onUpdateStatus;
  final Function(SnRelationship, int, String?, int?)? onBlockWithExpiry;
  final Function(SnRelationship, String?)? onMuteWithExpiry;
  final Function(SnRelationship)? onDelete;
  final Function(SnRelationship)? onToggleCloseFriend;
  final Function(SnRelationship, String?)? onUpdateAlias;

  const RelationshipListTile({
    super.key,
    required this.relationship,
    this.submitting = false,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.showActions = true,
    required this.currentUserId,
    this.showRelatedAccount = false,
    this.onUpdateStatus,
    this.onBlockWithExpiry,
    this.onMuteWithExpiry,
    this.onDelete,
    this.onToggleCloseFriend,
    this.onUpdateAlias,
  });

  @override
  Widget build(BuildContext context) {
    final account = showRelatedAccount
        ? relationship.related!
        : relationship.account!;
    final isPending =
        relationship.status == 0 && relationship.relatedId == currentUserId;
    final isWaiting =
        relationship.status == 0 && relationship.accountId == currentUserId;
    final isEstablished = relationship.status != 0;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 12),
      leading: AccountPfcRegion(
        uname: account.name,
        child: ProfilePictureWidget(file: account.profile.picture),
      ),
      title: Row(
        spacing: 6,
        children: [
          Flexible(child: Text(account.nick)),
          if (relationship.status >= 200) // Close Friend
            Badge(
              label: Text('relationshipStatusCloseFriend').tr(),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              textColor: Theme.of(context).colorScheme.onTertiary,
            )
          else if (relationship.status >= 100) // Friend
            Badge(
              label: Text('relationshipStatusFriend').tr(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
            )
          else if (relationship.status == -50) // Muted
            Badge(
              label: Text('relationshipStatusMuted').tr(),
              backgroundColor: Theme.of(context).colorScheme.outline,
              textColor: Theme.of(context).colorScheme.surface,
            )
          else if (relationship.status <= -100) // Blocked
            Badge(
              label: Text('relationshipStatusBlocked').tr(),
              backgroundColor: Theme.of(context).colorScheme.error,
              textColor: Theme.of(context).colorScheme.onError,
            ),
          if (isPending) // Pending
            Badge(
              label: Text('pendingRequest').tr(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
            )
          else if (isWaiting) // Waiting
            Badge(
              label: Text('pendingRequest').tr(),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              textColor: Theme.of(context).colorScheme.onSecondary,
            ),
          if (relationship.expiredAt != null)
            Badge(
              label: Text(
                'requestExpiredIn'.tr(
                  args: [RelativeTime(context).format(relationship.expiredAt!)],
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiary,
              textColor: Theme.of(context).colorScheme.onTertiary,
            ),
        ],
      ),
      subtitle: Text(
        relationship.alias != null && relationship.alias!.isNotEmpty
            ? '${relationship.alias!} (@${account.name})'
            : '@${account.name}',
      ),
      trailing: showActions
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isPending && onAccept != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: submitting ? null : onAccept,
                    icon: const Icon(Symbols.check),
                  ),
                if (isPending && onDecline != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: submitting ? null : onDecline,
                    icon: const Icon(Symbols.close),
                  ),
                if (isWaiting && onCancel != null)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: submitting ? null : onCancel,
                    icon: const Icon(Symbols.close),
                  ),
                if (isEstablished && (onUpdateStatus != null || onBlockWithExpiry != null || onMuteWithExpiry != null || onDelete != null || onToggleCloseFriend != null))
                  PopupMenuButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Symbols.more_vert),
                    itemBuilder: (context) => [
                      if (relationship.status >= 100 && onToggleCloseFriend != null)
                        PopupMenuItem(
                          onTap: () => onToggleCloseFriend?.call(relationship),
                          child: Row(
                            children: [
                              Icon(
                                relationship.status >= 200
                                    ? Symbols.star
                                    : Symbols.star_outline,
                              ),
                              const Gap(12),
                              Text(
                                relationship.status >= 200
                                    ? 'removeCloseFriend'.tr()
                                    : 'addCloseFriend'.tr(),
                              ),
                            ],
                          ),
                        ),
                      if (relationship.status >= 100 && onBlockWithExpiry != null)
                        PopupMenuItem(
                          onTap: () => _showBlockExpirySheet(context, relationship),
                          child: Row(
                            children: [
                              const Icon(Symbols.block),
                              const Gap(12),
                              Text('blockUser').tr(),
                            ],
                          ),
                        )
                      else if (relationship.status == -50 && onBlockWithExpiry != null)
                        PopupMenuItem(
                          onTap: () => _showBlockExpirySheet(context, relationship),
                          child: Row(
                            children: [
                              const Icon(Symbols.block),
                              const Gap(12),
                              Text('blockUser').tr(),
                            ],
                          ),
                        )
                      else if (relationship.status <= -100 && onUpdateStatus != null)
                        PopupMenuItem(
                          onTap: () => onUpdateStatus?.call(relationship, 100),
                          child: Row(
                            children: [
                              const Icon(Symbols.person_add),
                              const Gap(12),
                              Text('unblockUser').tr(),
                            ],
                          ),
                        ),
                      if (relationship.status >= 100 && onMuteWithExpiry != null)
                        PopupMenuItem(
                          onTap: () => _showMuteExpirySheet(context, relationship),
                          child: Row(
                            children: [
                              const Icon(Symbols.volume_off),
                              const Gap(12),
                              Text('muteUser').tr(),
                            ],
                          ),
                        )
                      else if (relationship.status == -50 && onMuteWithExpiry != null)
                        PopupMenuItem(
                          onTap: () => onMuteWithExpiry?.call(relationship, null),
                          child: Row(
                            children: [
                              const Icon(Symbols.volume_up),
                              const Gap(12),
                              Text('unmuteUser').tr(),
                            ],
                          ),
                        ),
                      if (onUpdateAlias != null)
                        PopupMenuItem(
                          onTap: () => _showAliasEditor(context, relationship),
                          child: Row(
                            children: [
                              const Icon(Symbols.edit),
                              const Gap(12),
                              Text('setAlias').tr(),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        PopupMenuItem(
                          onTap: () => onDelete?.call(relationship),
                          child: Row(
                            children: [
                              const Icon(Symbols.delete),
                              const Gap(12),
                              Text('forgotRelationship').tr(),
                            ],
                          ),
                        ),
                    ],
                  ),
              ],
            )
          : null,
    );
  }

  void _showBlockExpirySheet(
    BuildContext context,
    SnRelationship relationship,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ExpiryDurationSheet(
        title: 'blockUser'.tr(),
        onDurationSelected: (expiresIn, degradeTo) {
          onBlockWithExpiry?.call(relationship, -100, expiresIn, degradeTo);
        },
      ),
    );
  }

  void _showMuteExpirySheet(
    BuildContext context,
    SnRelationship relationship,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ExpiryDurationSheet(
        title: 'muteUser'.tr(),
        showDegradeOption: false,
        onDurationSelected: (expiresIn, degradeTo) {
          onMuteWithExpiry?.call(relationship, expiresIn);
        },
      ),
    );
  }

  void _showAliasEditor(
    BuildContext context,
    SnRelationship relationship,
  ) {
    final controller = TextEditingController(text: relationship.alias ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('setAlias'.tr()),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'aliasHint'.tr(),
            labelText: 'alias'.tr(),
          ),
          maxLength: 128,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          if (relationship.alias != null && relationship.alias!.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onUpdateAlias?.call(relationship, null);
              },
              child: Text('clearAlias'.tr()),
            ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              final alias = controller.text.trim();
              onUpdateAlias?.call(relationship, alias.isEmpty ? null : alias);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ExpiryDurationSheet extends StatelessWidget {
  final String title;
  final bool showDegradeOption;
  final Function(String? expiresIn, int? degradeTo) onDurationSelected;

  const _ExpiryDurationSheet({
    required this.title,
    this.showDegradeOption = true,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Symbols.schedule),
            title: Text('30 minutes'),
            onTap: () {
              Navigator.pop(context);
              onDurationSelected('30m', showDegradeOption ? -50 : null);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.schedule),
            title: Text('1 hour'),
            onTap: () {
              Navigator.pop(context);
              onDurationSelected('1h', showDegradeOption ? -50 : null);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.schedule),
            title: Text('24 hours'),
            onTap: () {
              Navigator.pop(context);
              onDurationSelected('24h', showDegradeOption ? -50 : null);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.schedule),
            title: Text('7 days'),
            onTap: () {
              Navigator.pop(context);
              onDurationSelected('7d', showDegradeOption ? -50 : null);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.schedule),
            title: Text('30 days'),
            onTap: () {
              Navigator.pop(context);
              onDurationSelected('30d', showDegradeOption ? -50 : null);
            },
          ),
          ListTile(
            leading: const Icon(Symbols.all_inclusive),
            title: Text('permanent'.tr()),
            onTap: () {
              Navigator.pop(context);
              onDurationSelected(null, null);
            },
          ),
          const Gap(8),
        ],
      ),
    );
  }
}

@RoutePage()
class RelationshipScreen extends HookConsumerWidget {
  const RelationshipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relationshipNotifier = ref.watch(
      relationshipListNotifierProvider.notifier,
    );

    Future<void> addFriend() async {
      final result = await showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        builder: (context) => AccountPickerSheet(),
      );
      if (result == null) return;

      final client = ref.read(apiClientProvider);
      await client.post('/passport/relationships/${result.id}/friends');
      ref.invalidate(friendRequestProvider);
    }

    final submitting = useState(false);

    Future<void> updateRelationship(
      SnRelationship relationship,
      int newStatus,
    ) async {
      final client = ref.read(apiClientProvider);
      await client.patch(
        '/passport/relationships/${relationship.accountId}',
        data: {'status': newStatus},
      );
      relationshipNotifier.refresh();
    }

    Future<void> deleteRelationship(SnRelationship relationship) async {
      final confirmed = await showConfirmAlert(
        'forgotRelationshipConfirm'.tr(
          args: ['@${relationship.related!.name}'],
        ),
        'forgotRelationship'.tr(),
        isDanger: true,
      );
      if (!confirmed) return;

      if (!context.mounted) return;
      showLoadingModal(context);
      try {
        final client = ref.read(apiClientProvider);
        await client.delete(
          '/passport/relationships/${relationship.relatedId}',
        );
        relationshipNotifier.refresh();
        showSnackBar('relationshipDeleted'.tr());
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> blockWithExpiry(
      SnRelationship relationship,
      int status,
      String? expiresIn,
      int? degradeTo,
    ) async {
      try {
        final client = ref.read(apiClientProvider);
        final data = <String, dynamic>{};
        if (expiresIn != null) data['expires_in'] = expiresIn;
        if (degradeTo != null) data['degrade_to'] = degradeTo;
        await client.post(
          '/passport/relationships/${relationship.relatedId}/block',
          data: data.isNotEmpty ? data : null,
        );
        relationshipNotifier.refresh();
        showSnackBar('userBlocked'.tr());
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> muteWithExpiry(
      SnRelationship relationship,
      String? expiresIn,
    ) async {
      try {
        final client = ref.read(apiClientProvider);
        final data = <String, dynamic>{};
        if (expiresIn != null) data['expires_in'] = expiresIn;
        await client.post(
          '/passport/relationships/${relationship.relatedId}/mute',
          data: data.isNotEmpty ? data : null,
        );
        relationshipNotifier.refresh();
        showSnackBar('userMuted'.tr());
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> toggleCloseFriend(SnRelationship relationship) async {
      try {
        final client = ref.read(apiClientProvider);
        if (relationship.status >= 200) {
          await client.delete(
            '/passport/relationships/${relationship.relatedId}/close-friend',
          );
          showSnackBar('closeFriendRemoved'.tr());
        } else {
          await client.post(
            '/passport/relationships/${relationship.relatedId}/close-friend',
          );
          showSnackBar('closeFriendAdded'.tr());
        }
        relationshipNotifier.refresh();
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Future<void> updateAlias(
      SnRelationship relationship,
      String? alias,
    ) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.patch(
          '/passport/relationships/${relationship.relatedId}/alias',
          data: {'alias': alias},
        );
        relationshipNotifier.refresh();
        showSnackBar(
          alias != null ? 'aliasUpdated'.tr() : 'aliasCleared'.tr(),
        );
      } catch (err) {
        showErrorAlert(err);
      }
    }

    final user = ref.watch(userInfoProvider);
    final requests = ref.watch(friendRequestProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text('relationships').tr(),
        leading: const AutoLeadingButton(),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Symbols.add),
            title: Text('addFriend').tr(),
            subtitle: Text('addFriendHint').tr(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            onTap: addFriend,
          ),
          if (requests.hasValue && requests.value!.isNotEmpty)
            ListTile(
              leading: const Icon(Symbols.send),
              title: Text('friendRequests').tr(),
              subtitle: Text(
                'friendRequestsHint'.plural(requests.value!.length),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              onTap: () {
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => const _SentFriendRequestsSheet(),
                );
              },
            ),
          const Divider(height: 1),
          Expanded(
            child: PaginationList(
              padding: EdgeInsets.zero,
              provider: relationshipListNotifierProvider,
              notifier: relationshipListNotifierProvider.notifier,
              itemBuilder: (context, index, relationship) {
                return RelationshipListTile(
                  relationship: relationship,
                  submitting: submitting.value,
                  currentUserId: user.value?.id,
                  showRelatedAccount: true,
                  onUpdateStatus: updateRelationship,
                  onBlockWithExpiry: blockWithExpiry,
                  onMuteWithExpiry: muteWithExpiry,
                  onDelete: deleteRelationship,
                  onToggleCloseFriend: toggleCloseFriend,
                  onUpdateAlias: updateAlias,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SentFriendRequestsSheet extends HookConsumerWidget {
  const _SentFriendRequestsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(friendRequestProvider);
    final user = ref.watch(userInfoProvider);

    Future<void> cancelRequest(SnRelationship request) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.delete(
          '/passport/relationships/${request.relatedId}/friends',
        );
        ref.invalidate(friendRequestProvider);
      } catch (err) {
        showErrorAlert(err);
      }
    }

    final submitting = useState(false);

    Future<void> handleFriendRequest(
      SnRelationship relationship,
      bool isAccept,
    ) async {
      try {
        submitting.value = true;
        final client = ref.read(apiClientProvider);
        await client.post(
          '/passport/relationships/${relationship.accountId}/friends/${isAccept ? 'accept' : 'decline'}',
        );
        ref.invalidate(friendRequestProvider);
        if (!context.mounted) return;
        if (isAccept) {
          showSnackBar(
            'friendRequestAccepted'.tr(
              args: ['@${relationship.account!.name}'],
            ),
          );
        } else {
          showSnackBar(
            'friendRequestDeclined'.tr(
              args: ['@${relationship.account!.name}'],
            ),
          );
        }
        HapticFeedback.lightImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 16,
              left: 20,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                Text(
                  'friendRequests'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.refresh),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                  onPressed: () {
                    ref.invalidate(friendRequestProvider);
                  },
                ),
                IconButton(
                  icon: const Icon(Symbols.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: requests.when(
              data: (items) => items.isEmpty
                  ? Center(
                      child: Text(
                        'friendRequestsEmpty'.tr(),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final request = items[index];
                        return RelationshipListTile(
                          relationship: request,
                          onCancel: () => cancelRequest(request),
                          onAccept: () => handleFriendRequest(request, true),
                          onDecline: () => handleFriendRequest(request, false),
                          currentUserId: user.value?.id,
                          showRelatedAccount: false,
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
