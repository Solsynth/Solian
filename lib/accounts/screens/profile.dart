import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/accounts/widgets/account/board.dart';
import 'package:island/accounts/screens/profile_timeline.dart';
import 'package:island/developers/models/developer.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/accounts/screens/punishment_user_sheet.dart';

part 'profile.g.dart';

Future<void> showAccountProfileAttentionModal(String name) async {
  showAttentionModal(
    id: 'account-profile:$name',
    replaceIfExists: true,
    barrierDismissible: true,
    builder: (context, dismiss) =>
        AccountProfileAttentionModal(name: name, onDismiss: dismiss),
  );
}

class AccountProfileAttentionModal extends StatelessWidget {
  final String name;
  final VoidCallback onDismiss;

  const AccountProfileAttentionModal({
    super.key,
    required this.name,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AttentionModalScaffold(
      titleText: '@$name',
      onDismiss: onDismiss,
      actions: [
        IconButton(
          onPressed: () {
            onDismiss();
            context.router.push(AccountProfileRoute(name: name));
          },
          icon: const Icon(Symbols.open_in_new),
          tooltip: 'open'.tr(),
        ),
      ],
      child: AccountProfileContent(name: name, isEmbedded: true),
    );
  }
}

class _AccountBasicInfo extends HookWidget {
  final SnAccount data;
  final String uname;
  final AsyncValue<SnDeveloper?> accountDeveloper;

  const _AccountBasicInfo({
    required this.data,
    required this.uname,
    required this.accountDeveloper,
  });

  String _getFirstLine(String bio) {
    final lines = bio.split('\n');
    if (lines.isEmpty) return '';
    return lines.first.trim();
  }

  @override
  Widget build(BuildContext context) {
    final isBioExpanded = useState(false);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: CloudImageWidget(
                    file: data.profile.background,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -24,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3,
                    ),
                  ),
                  child: ProfilePictureWidget(
                    file: data.profile.picture,
                    radius: 32,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Gap(12),
                              Row(
                                spacing: 8,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: AccountName(
                                      account: data,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '@${data.name}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(4),
                              AccountStatusWidget(
                                uname: uname,
                                padding: EdgeInsets.zero,
                              ),
                              if (accountDeveloper.value != null) ...[
                                const Gap(12),
                                InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    context.router.push(
                                      PublisherProfileRoute(
                                        name: accountDeveloper
                                            .value!
                                            .publisher!
                                            .name,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .secondaryContainer
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      spacing: 8,
                                      children: [
                                        Icon(
                                          Symbols.smart_toy,
                                          size: 18,
                                          color: theme
                                              .colorScheme
                                              .onSecondaryContainer,
                                        ),
                                        Text(
                                          'botAutomatedBy'.tr(
                                            args: [
                                              accountDeveloper
                                                  .value!
                                                  .publisher!
                                                  .nick,
                                            ],
                                          ),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSecondaryContainer,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            onPressed: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  uri: Uri.parse(
                                    'https://solian.app/@${data.name}',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Symbols.share,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Collapsible Bio Section
                if (data.profile.bio.isNotEmpty) ...[
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: isBioExpanded.value
                                  ? MarkdownTextContent(
                                      key: const ValueKey('expanded'),
                                      content: data.profile.bio,
                                      linesMargin: EdgeInsets.zero,
                                    )
                                  : Text(
                                      _getFirstLine(data.profile.bio),
                                      key: const ValueKey('collapsed'),
                                    ),
                            ).alignment(Alignment.centerLeft),
                          ),
                          InkWell(
                            onTap: () {
                              isBioExpanded.value = !isBioExpanded.value;
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                isBioExpanded.value
                                    ? 'collapse'.tr()
                                    : 'expand'.tr(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ).tr(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountPunishment extends StatelessWidget {
  final SnAccountPunishment punishment;
  final VoidCallback onTap;

  const _AccountPunishment({required this.punishment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Symbols.warning,
                  color: theme.colorScheme.onErrorContainer,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'accountRestrictions'.tr(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'tapToViewDetails'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Symbols.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  final SnAccount data;
  final AsyncValue<SnRelationship?> accountRelationship;
  final AsyncValue<SnChatRoom?> accountChat;
  final VoidCallback relationshipAction;
  final VoidCallback blockAction;
  final VoidCallback directMessageAction;

  const _AccountAction({
    required this.data,
    required this.accountRelationship,
    required this.accountChat,
    required this.relationshipAction,
    required this.blockAction,
    required this.directMessageAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlocked =
        accountRelationship.value != null &&
        accountRelationship.value!.status <= -100;
    final isFriend =
        accountRelationship.value != null &&
        accountRelationship.value!.status > -100;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: isFriend
                      ? FilledButton.tonal(
                          onPressed: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.person_check, size: 18),
                              Text('added').tr(),
                            ],
                          ),
                        )
                      : FilledButton.tonal(
                          onPressed: relationshipAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.person_add, size: 18),
                              Text('addFriendShort').tr(),
                            ],
                          ),
                        ),
                ),
                Expanded(
                  child: isBlocked
                      ? FilledButton.tonal(
                          onPressed: blockAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.person_cancel, size: 18),
                              Text('unblockUser').tr(),
                            ],
                          ),
                        )
                      : OutlinedButton(
                          onPressed: blockAction,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: 6,
                            children: [
                              const Icon(Symbols.block, size: 18),
                              Text('blockUser').tr(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const Gap(12),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: directMessageAction,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 6,
                      children: [
                        const Icon(Symbols.chat, size: 18),
                        Text(
                          accountChat.value == null
                              ? 'createDirectMessage'
                              : 'gotoDirectMessage',
                          maxLines: 1,
                        ).tr(),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton.filled(
                    onPressed: () {
                      showAbuseReportSheet(
                        context,
                        resourceIdentifier: 'account/${data.id}',
                      );
                    },
                    icon: const Icon(Symbols.flag, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

@riverpod
Future<SnAccount> account(Ref ref, String uname) async {
  if (uname == 'me') {
    final userInfo = ref.watch(userInfoProvider);
    if (userInfo.hasValue && userInfo.value != null) {
      return userInfo.value!;
    }
  }
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getAccountByUsername(uname);
}

@riverpod
Future<List<SnAccountBadge>> accountBadges(Ref ref, String uname) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.accounts.getAccountBadges(uname);
}

@riverpod
Future<SnChatRoom?> accountDirectChat(Ref ref, String uname) async {
  final userInfo = ref.watch(userInfoProvider);
  if (userInfo.value == null) return null;
  final account = await ref.watch(accountProvider(uname).future);
  final client = ref.watch(solarNetworkClientProvider);
  return await client.chat.getDirectChat(account.id);
}

@riverpod
Future<SnRelationship?> accountRelationship(Ref ref, String uname) async {
  final userInfo = ref.watch(userInfoProvider);
  if (userInfo.value == null) return null;
  final account = await ref.watch(accountProvider(uname).future);
  final client = ref.watch(solarNetworkClientProvider);
  try {
    return await client.accounts.getRelationship(account.id);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<SnDeveloper?> accountBotDeveloper(Ref ref, String uname) async {
  final account = await ref.watch(accountProvider(uname).future);
  if (account.automatedId == null) return null;
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get(
      "/develop/bots/${account.automatedId}/developer",
    );
    return SnDeveloper.fromJson(resp.data);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<List<SnPublisher>> accountPublishers(Ref ref, String id) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    return await client.sphere.getAccountPublishers(id);
  } catch (err) {
    return [];
  }
}

@riverpod
Future<SnAccountPunishment?> accountPunishmentOverview(
  Ref ref,
  String uname,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    final response = await client.dio.get(
      '/padlock/accounts/$uname/punishments/overview',
    );
    if (response.data == null) return null;
    return SnAccountPunishment.fromJson(response.data);
  } catch (err) {
    return null;
  }
}

final accountTimelineProvider = AsyncNotifierProvider.autoDispose
    .family<
      AccountTimelineNotifier,
      PaginationState<SnAccountTimelineItem>,
      String
    >(AccountTimelineNotifier.new);

class AccountTimelineNotifier
    extends AsyncNotifier<PaginationState<SnAccountTimelineItem>>
    with AsyncPaginationController<SnAccountTimelineItem> {
  static const int pageSize = 20;

  final String arg;

  AccountTimelineNotifier(this.arg);

  @override
  FutureOr<PaginationState<SnAccountTimelineItem>> build() async {
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

  @override
  Future<List<SnAccountTimelineItem>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final result = await client.accounts.getAccountTimeline(
      username: arg,
      offset: fetchedCount,
      take: pageSize,
    );

    totalCount = result.totalCount;
    return result.items;
  }
}

@RoutePage()
class AccountProfileScreen extends HookConsumerWidget {
  final String name;

  const AccountProfileScreen({
    super.key,
    @PathParam("name") required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(name));

    return AppScaffold(
      isNoBackground: false,
      appBar: isWideScreen(context)
          ? AppBar(
              leading: const AutoLeadingButton(),
              title: Text(account.value?.nick ?? '@$name'),
            )
          : null,
      body: AccountProfileContent(name: name),
    );
  }
}

class AccountProfileContent extends HookConsumerWidget {
  final String name;
  final bool isEmbedded;

  const AccountProfileContent({
    super.key,
    required this.name,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(name));
    final accountChat = ref.watch(accountDirectChatProvider(name));
    final accountRelationship = ref.watch(accountRelationshipProvider(name));
    final accountDeveloper = ref.watch(accountBotDeveloperProvider(name));
    final accountPunishment = ref.watch(
      accountPunishmentOverviewProvider(name),
    );

    void showPunishmentSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        builder: (context) => UserPunishmentsSheet(
          username: name,
          initialOverview: accountPunishment.value,
        ),
      );
    }

    Future<void> relationshipAction() async {
      if (accountRelationship.value != null) return;
      showLoadingModal(context);
      try {
        final client = ref.watch(solarNetworkClientProvider);
        await client.accounts.addAccountAsFriend(account.value!.id);
        ref.invalidate(accountRelationshipProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> blockAction() async {
      showLoadingModal(context);
      try {
        final client = ref.watch(solarNetworkClientProvider);
        if (accountRelationship.value == null) {
          await client.accounts.blockAccount(account.value!.id);
        } else {
          await client.accounts.unblockAccount(account.value!.id);
        }
        ref.invalidate(accountRelationshipProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    Future<void> directMessageAction() async {
      if (!account.hasValue) return;
      if (accountChat.value != null) {
        context.router.navigate(ChatRoomRoute(id: accountChat.value!.id));
        return;
      }
      showLoadingModal(context);
      try {
        final client = ref.watch(solarNetworkClientProvider);
        final chat = await client.chat.createDirectChat(account.value!.id);
        if (context.mounted) {
          context.router.push(ChatRoomRoute(id: chat.id));
        }
        ref.invalidate(accountDirectChatProvider(name));
      } catch (err) {
        showErrorAlert(err);
      } finally {
        if (context.mounted) hideLoadingModal(context);
      }
    }

    final user = ref.watch(userInfoProvider);
    final isCurrentUser = useMemoized(
      () => user.value?.id == account.value?.id,
      [user, account],
    );

    Future<void> refreshProfile() async {
      ref.invalidate(accountProvider(name));
      ref.invalidate(accountBotDeveloperProvider(name));
      ref.invalidate(accountPunishmentOverviewProvider(name));
      ref.invalidate(accountTimelineProvider(name));
      ref.invalidate(boardWidgetAppsProvider);

      if (account.value != null) {
        ref.invalidate(accountPublishersProvider(account.value!.id));
      }
      if (user.value != null) {
        ref.invalidate(accountDirectChatProvider(name));
        ref.invalidate(accountRelationshipProvider(name));
      }
      if (isCurrentUser) {
        ref.invalidate(myAccountBoardProvider);
      }

      final futures = <Future<dynamic>>[
        ref.read(accountProvider(name).future),
        ref.read(accountBotDeveloperProvider(name).future),
        ref.read(accountPunishmentOverviewProvider(name).future),
        ref.read(boardWidgetAppsProvider.future),
      ];
      if (account.value != null) {
        futures.add(ref.read(accountPublishersProvider(account.value!.id).future));
      }
      if (user.value != null) {
        futures.add(ref.read(accountDirectChatProvider(name).future));
        futures.add(ref.read(accountRelationshipProvider(name).future));
      }
      if (isCurrentUser) {
        futures.add(ref.read(myAccountBoardProvider.future));
      }
      await Future.wait(futures);
    }

    return DefaultTabController(
      length: 2,
      child: account.when(
        data: (data) {
          final accountPublishers = ref.watch(
            accountPublishersProvider(data.id),
          );
          final theme = Theme.of(context);
          final accountBoard = isCurrentUser
              ? ref.watch(myAccountBoardProvider).asData?.value ??
                    AccountBoard.defaultBoard()
              : AccountBoard.defaultBoard();

          final boardContent = ExtendedRefreshIndicator(
            onRefresh: refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isEmbedded ? 0 : 12,
                vertical: 8,
              ),
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isEmbedded) ...[
                    const Gap(8),
                    Text(
                      data.nick,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  _AccountBasicInfo(
                    data: data,
                    uname: name,
                    accountDeveloper: accountDeveloper,
                  ),
                  AccountBoard(
                    account: data,
                    items: accountBoard,
                    uname: name,
                    publishers: accountPublishers.value ?? [],
                  ),
                  ?accountPunishment.whenOrNull(
                    data: (punishmentData) => punishmentData != null
                        ? _AccountPunishment(
                            punishment: punishmentData,
                            onTap: showPunishmentSheet,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          );

          final boardContentNoHeader = ExtendedRefreshIndicator(
            onRefresh: refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AccountBoard(
                    account: data,
                    items: accountBoard,
                    uname: name,
                    publishers: accountPublishers.value ?? [],
                  ),
                ],
              ),
            ),
          );

          final timelineContent = ExtendedRefreshIndicator(
            onRefresh: refreshProfile,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: isEmbedded ? 0 : 12),
                  sliver: AccountTimelineList(uname: name),
                ),
                SliverGap(MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final useWide =
                  isWideScreen(context) && constraints.maxWidth >= 900;

              final tabBar = Material(
                color: theme.colorScheme.surface,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: TabBar(
                    indicator: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerHeight: 0,
                    labelColor: theme.colorScheme.onSecondaryContainer,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    splashBorderRadius: BorderRadius.circular(20),
                    labelStyle: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('board'.tr()),
                        ),
                      ),
                      Tab(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('timeline'.tr()),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (!useWide) {
                return Column(
                  children: [
                    tabBar,
                    if (user.value != null && !isCurrentUser)
                      Material(
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: _AccountAction(
                            data: data,
                            accountRelationship: accountRelationship,
                            accountChat: accountChat,
                            relationshipAction: relationshipAction,
                            blockAction: blockAction,
                            directMessageAction: directMessageAction,
                          ),
                        ),
                      ),
                    Expanded(
                      child: TabBarView(
                        children: [boardContent, timelineContent],
                      ),
                    ),
                  ],
                );
              }

              return Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Column(
                        children: [
                          tabBar,
                          Expanded(
                            child: TabBarView(
                              children: [boardContentNoHeader, timelineContent],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      child: Column(
                        spacing: 12,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AccountBasicInfo(
                            data: data,
                            uname: name,
                            accountDeveloper: accountDeveloper,
                          ),
                          ?accountPunishment.whenOrNull(
                            data: (punishmentData) => punishmentData != null
                                ? _AccountPunishment(
                                    punishment: punishmentData,
                                    onTap: showPunishmentSheet,
                                  )
                                : null,
                          ),
                          if (user.value != null && !isCurrentUser)
                            _AccountAction(
                              data: data,
                              accountRelationship: accountRelationship,
                              accountChat: accountChat,
                              relationshipAction: relationshipAction,
                              blockAction: blockAction,
                              directMessageAction: directMessageAction,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        error: (error, stackTrace) => Center(child: Text(error.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
