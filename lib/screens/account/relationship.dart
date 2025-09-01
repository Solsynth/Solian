import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/pods/userinfo.dart';
import 'package:island/widgets/account/account_pfc.dart';
import 'package:island/widgets/account/account_picker.dart';
import 'package:island/widgets/alert.dart';
import 'package:island/widgets/app_scaffold.dart';
import 'package:island/widgets/content/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:relative_time/relative_time.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod_paging_utils/riverpod_paging_utils.dart';
import 'package:island/models/relationship.dart';
import 'package:island/pods/network.dart';

part 'relationship.g.dart';

@riverpod
Future<List<SnRelationship>> sentFriendRequest(Ref ref) async {
  final client = ref.read(apiClientProvider);
  final resp = await client.get('/id/relationships/requests');
  return resp.data
      .map((e) => SnRelationship.fromJson(e))
      .cast<SnRelationship>()
      .toList();
}

@riverpod
class RelationshipListNotifier extends _$RelationshipListNotifier
    with CursorPagingNotifierMixin<SnRelationship> {
  @override
  Future<CursorPagingData<SnRelationship>> build() => fetch(cursor: null);

  @override
  Future<CursorPagingData<SnRelationship>> fetch({
    required String? cursor,
  }) async {
    final client = ref.read(apiClientProvider);
    final offset = cursor == null ? 0 : int.parse(cursor);
    final take = 20;

    final response = await client.get(
      '/id/relationships',
      queryParameters: {'offset': offset, 'take': take},
    );

    final List<SnRelationship> items =
        (response.data as List)
            .map((e) => SnRelationship.fromJson(e as Map<String, dynamic>))
            .toList();

    final total = int.tryParse(response.headers['x-total']?.first ?? '') ?? 0;
    final hasMore = offset + items.length < total;
    final nextCursor = hasMore ? (offset + items.length).toString() : null;

    return CursorPagingData(
      items: items,
      hasMore: hasMore,
      nextCursor: nextCursor,
    );
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
  });

  @override
  Widget build(BuildContext context) {
    final account =
        showRelatedAccount ? relationship.related : relationship.account;
    final isPending =
        relationship.status == 0 && relationship.relatedId == currentUserId;
    final isWaiting =
        relationship.status == 0 && relationship.accountId == currentUserId;
    final isEstablished = relationship.status == 1 || relationship.status == 2;

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 16, right: 12),
      leading: AccountPfcGestureDetector(
        uname: account.name,
        child: ProfilePictureWidget(fileId: account.profile.picture?.id),
      ),
      title: Row(
        spacing: 6,
        children: [
          Flexible(child: Text(account.nick)),
          if (relationship.status >= 100) // Friend
            Badge(
              label: Text('relationshipStatusFriend').tr(),
              backgroundColor: Theme.of(context).colorScheme.primary,
              textColor: Theme.of(context).colorScheme.onPrimary,
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
      subtitle: Text('@${account.name}'),
      trailing:
          showActions
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
                  if (isEstablished && onUpdateStatus != null)
                    PopupMenuButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Symbols.more_vert),
                      itemBuilder:
                          (context) => [
                            if (relationship.status >= 100) // If friend
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Symbols.block),
                                  title: Text('blockUser').tr(),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap:
                                    () => onUpdateStatus?.call(
                                      relationship,
                                      -100,
                                    ),
                              )
                            else if (relationship.status <= -100) // If blocked
                              PopupMenuItem(
                                child: ListTile(
                                  leading: const Icon(Symbols.person_add),
                                  title: Text('unblockUser').tr(),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap:
                                    () =>
                                        onUpdateStatus?.call(relationship, 100),
                              ),
                          ],
                    ),
                ],
              )
              : null,
    );
  }
}

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
      await client.post('/id/relationships/${result.id}/friends');
      ref.invalidate(sentFriendRequestProvider);
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
          '/id/relationships/${relationship.accountId}/friends/${isAccept ? 'accept' : 'decline'}',
        );
        relationshipNotifier.forceRefresh();
        if (!context.mounted) return;
        if (isAccept) {
          showSnackBar(
            'friendRequestAccepted'.tr(args: ['@${relationship.account.name}']),
          );
        } else {
          showSnackBar(
            'friendRequestDeclined'.tr(args: ['@${relationship.account.name}']),
          );
        }
        HapticFeedback.lightImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        submitting.value = false;
      }
    }

    Future<void> updateRelationship(
      SnRelationship relationship,
      int newStatus,
    ) async {
      final client = ref.read(apiClientProvider);
      await client.patch(
        '/id/relationships/${relationship.accountId}',
        data: {'status': newStatus},
      );
      relationshipNotifier.forceRefresh();
    }

    final user = ref.watch(userInfoProvider);
    final requests = ref.watch(sentFriendRequestProvider);

    return AppScaffold(
      appBar: AppBar(title: Text('relationships').tr()),
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
              title: Text('friendSentRequest').tr(),
              subtitle: Text(
                'friendSentRequestHint'.plural(requests.value!.length),
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
            child: PagingHelperView(
              provider: relationshipListNotifierProvider,
              futureRefreshable: relationshipListNotifierProvider.future,
              notifierRefreshable: relationshipListNotifierProvider.notifier,
              contentBuilder:
                  (data, widgetCount, endItemView) => ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widgetCount,
                    itemBuilder: (context, index) {
                      if (index == widgetCount - 1) {
                        return endItemView;
                      }

                      final relationship = data.items[index];
                      return RelationshipListTile(
                        relationship: relationship,
                        submitting: submitting.value,
                        onAccept: () => handleFriendRequest(relationship, true),
                        onDecline:
                            () => handleFriendRequest(relationship, false),
                        currentUserId: user.value?.id,
                        showRelatedAccount: false,
                        onUpdateStatus: updateRelationship,
                      );
                    },
                  ),
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
    final requests = ref.watch(sentFriendRequestProvider);
    final user = ref.watch(userInfoProvider);

    Future<void> cancelRequest(SnRelationship request) async {
      try {
        final client = ref.read(apiClientProvider);
        await client.delete('/id/relationships/${request.relatedId}/friends');
        ref.invalidate(sentFriendRequestProvider);
      } catch (err) {
        showErrorAlert(err);
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
                  'friendSentRequest'.tr(),
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
                    ref.invalidate(sentFriendRequestProvider);
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
              data:
                  (items) =>
                      items.isEmpty
                          ? Center(
                            child: Text(
                              'friendSentRequestEmpty'.tr(),
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
                                currentUserId: user.value?.id,
                                showRelatedAccount: true,
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
