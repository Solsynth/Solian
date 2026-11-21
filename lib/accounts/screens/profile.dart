import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/accounts/widgets/account/board.dart';
import 'package:island/accounts/widgets/account/pulsar_profile_tab.dart';
import 'package:island/activity/pulsar_pod.dart';
import 'package:island/accounts/screens/profile_timeline.dart';
import 'package:island/developers/models/developer.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/core/config.dart';
import 'package:island/core/database.dart';
import 'package:island/core/network.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/profile_header_app_bar.dart';
import 'package:island/shared/widgets/sliver_floating_tab_bar.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/extended_refresh_indicator.dart';
import 'package:island/tickets/widgets/ticket_fire.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:island/accounts/screens/punishment_user_sheet.dart';

part 'profile.g.dart';

class _AccountBasicInfo extends HookWidget {
  final SnAccount data;
  final String uname;
  final AsyncValue<SnDeveloper?> accountDeveloper;
  final bool showHeaderImage;

  const _AccountBasicInfo({
    required this.data,
    required this.uname,
    required this.accountDeveloper,
    this.showHeaderImage = true,
  });

  String _getFirstLine(String bio) {
    final lines = bio.split('\n');
    if (lines.isEmpty) return '';
    return lines.first.trim();
  }

  int _getAge(DateTime birthday) {
    final today = DateTime.now();
    var age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    final isBioExpanded = useState(false);
    final theme = Theme.of(context);

    final avatar = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // The ring separates the avatar from the card it overlaps, so it takes
        // the card's own tone rather than the page ground's.
        border: Border.all(
          color: theme.colorScheme.surfaceContainerLow,
          width: 3,
        ),
      ),
      child: ProfilePictureWidget(
        file: data.profile.picture,
        fallbackName: data.nick,
        radius: 32,
      ),
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHeaderImage)
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(SolRadius.card),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: CloudImageWidget(
                    file: data.profile.background,
                    fit: BoxFit.cover,
                    imageOnly: true,
                  ),
                ),
              ),
              Positioned(bottom: -24, left: SolSpace.lg, child: avatar),
            ],
          ),
        Padding(
          padding: const EdgeInsets.all(SolSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeaderImage) const Gap(SolSpace.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  if (!showHeaderImage) avatar,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          spacing: SolSpace.sm,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: AccountName(
                                account: data,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                onVerificationTap:
                                    data.profile.verification == null
                                    ? null
                                    : () => showVerificationMarkSheet(
                                        context,
                                        data.profile.verification!,
                                      ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SolSpace.sm,
                                vertical: SolSpace.xxs,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  SolRadius.chip,
                                ),
                              ),
                              child: Text(
                                '@${data.name}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(SolSpace.xs),
                        AccountStatusWidget(
                          uname: uname,
                          padding: EdgeInsets.zero,
                        ),
                        if (data.profile.location.trim().isNotEmpty)
                          _AccountProfileInfoRow(
                            icon: Symbols.location_on,
                            value: data.profile.location.trim(),
                          ),
                        if (data.profile.birthday != null)
                          _AccountProfileInfoRow(
                            icon: Symbols.cake,
                            value:
                                '${_getAge(data.profile.birthday!.toLocal())} yrs',
                          ),
                        if (data.profile.timeZone.trim().isNotEmpty)
                          _AccountProfileInfoRow(
                            icon: Symbols.schedule,
                            value: data.profile.timeZone.trim(),
                          ),
                        if (accountDeveloper.value != null) ...[
                          const Gap(SolSpace.md),
                          InkWell(
                            borderRadius: BorderRadius.circular(SolRadius.sm),
                            onTap: () {
                              context.router.push(
                                PublisherProfileRoute(
                                  name: accountDeveloper.value!.publisher!.name,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: SolSpace.md,
                                vertical: SolSpace.sm,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondaryContainer
                                    .withOpacity(0.5),
                                borderRadius: BorderRadius.circular(
                                  SolRadius.sm,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                spacing: SolSpace.sm,
                                children: [
                                  Icon(
                                    Symbols.smart_toy,
                                    size: 18,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                  Text(
                                    'botAutomatedBy'.tr(
                                      args: [
                                        accountDeveloper.value!.publisher!.nick,
                                      ],
                                    ),
                                    style: theme.textTheme.bodySmall?.copyWith(
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
                      borderRadius: BorderRadius.circular(SolRadius.sm),
                    ),
                    child: IconButton(
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            uri: Uri.parse('https://solian.app/@${data.name}'),
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
              // Collapsible Bio Section
              if (data.profile.bio.isNotEmpty) ...[
                const Gap(SolSpace.md),
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
                              horizontal: SolSpace.xs,
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
    );

    return ExploreCard(child: content);
  }
}

class _AccountProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _AccountProfileInfoRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: SolSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const Gap(SolSpace.xs + SolSpace.xxs),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
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

    return ExploreCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: SolRadius.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(SolSpace.card),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(SolRadius.sm),
                ),
                child: Icon(
                  Symbols.warning,
                  color: theme.colorScheme.onErrorContainer,
                  size: 20,
                ),
              ),
              const Gap(SolSpace.md),
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
                    const Gap(SolSpace.xxs),
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

    return ExploreCard(
      child: Padding(
        padding: const EdgeInsets.all(SolSpace.card),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: SolSpace.md,
              children: [
                Expanded(
                  child: isFriend
                      ? FilledButton.tonal(
                          onPressed: null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            spacing: SolSpace.xs,
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
                            spacing: SolSpace.xs,
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
                            spacing: SolSpace.xs,
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
                            spacing: SolSpace.xs,
                            children: [
                              const Icon(Symbols.block, size: 18),
                              Text('blockUser').tr(),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const Gap(SolSpace.md),
            Row(
              spacing: SolSpace.md,
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
                  decoration: const BoxDecoration(
                    borderRadius: SolRadius.cardRadius,
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
  final database = ref.watch(databaseProvider);
  final cached = await database.getAccountByUsername(uname);
  if (cached != null) {
    // Keep cached account data useful offline while refreshing it for the
    // next read. The database is the durable source for the next provider
    // build, not a replacement for the API's authority.
    unawaited(() async {
      try {
        final fresh = await ref
            .read(solarNetworkClientProvider)
            .accounts
            .getAccountByUsername(uname);
        await database.saveAccount(fresh, source: '/stargate/accounts/$uname');
      } catch (error, stackTrace) {
        developer.log(
          'Account endpoint returned an invalid profile: /stargate/accounts/$uname',
          name: 'AccountProvider',
          error: error,
          stackTrace: stackTrace,
        );
        Error.throwWithStackTrace(error, stackTrace);
      }
    }());
    return cached;
  }
  final client = ref.watch(solarNetworkClientProvider);
  try {
    final account = await client.accounts.getAccountByUsername(uname);
    await database.saveAccount(account, source: '/stargate/accounts/$uname');
    return account;
  } catch (error, stackTrace) {
    developer.log(
      'Account endpoint returned an invalid profile: /stargate/accounts/$uname',
      name: 'AccountProvider',
      error: error,
      stackTrace: stackTrace,
    );
    Error.throwWithStackTrace(error, stackTrace);
  }
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
      '/stargate/accounts/$uname/punishments/overview',
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
    final isNarrow =
        !isWideScreen(context) || MediaQuery.sizeOf(context).width < 900;

    return AppScaffold(
      isNoBackground: false,
      appBar: isNarrow
          ? null
          : AppBar(
              leading: const AutoLeadingButton(),
              title: Text(account.value?.nick ?? '@$name'),
            ),
      body: AccountProfileContent(name: name),
    );
  }
}

class AccountProfileContent extends HookConsumerWidget {
  final String name;

  const AccountProfileContent({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountProvider(name));
    final accountChat = ref.watch(accountDirectChatProvider(name));
    final accountRelationship = ref.watch(accountRelationshipProvider(name));
    final accountDeveloper = ref.watch(accountBotDeveloperProvider(name));
    final accountPunishment = ref.watch(
      accountPunishmentOverviewProvider(name),
    );
    final collapsed = useState(false);
    final headerTint = useState<Color?>(null);

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
      ref.invalidate(pulsarUserNowPlayingProvider(name));
      ref.invalidate(pulsarUserStatsProvider(name));
      ref.invalidate(pulsarUserHistoryProvider);

      if (account.value != null) {
        ref.invalidate(accountPublishersProvider(account.value!.id));
      }
      if (user.value != null) {
        ref.invalidate(accountDirectChatProvider(name));
        ref.invalidate(accountRelationshipProvider(name));
      }
      if (isCurrentUser) {
        ref.invalidate(myAccountBoardProvider);
        ref.invalidate(pulsarMyWorkCollectionsProvider);
      }

      final futures = <Future<dynamic>>[
        ref.read(accountProvider(name).future),
        ref.read(accountBotDeveloperProvider(name).future),
        ref.read(accountPunishmentOverviewProvider(name).future),
        ref.read(boardWidgetAppsProvider.future),
      ];
      if (account.value != null) {
        futures.add(
          ref.read(accountPublishersProvider(account.value!.id).future),
        );
      }
      if (user.value != null) {
        futures.add(ref.read(accountDirectChatProvider(name).future));
        futures.add(ref.read(accountRelationshipProvider(name).future));
      }
      if (isCurrentUser) {
        futures.add(ref.read(myAccountBoardProvider.future));
        futures.add(ref.read(pulsarMyWorkCollectionsProvider.future));
      }
      await Future.wait(futures);
    }

    return DefaultTabController(
      length: 3,
      child: account.when(
        data: (data) {
          final accountPublishers = ref.watch(
            accountPublishersProvider(data.id),
          );
          final theme = Theme.of(context);
          final serverUrl = ref.watch(serverUrlProvider);
          final savedBoard = isCurrentUser
              ? ref.watch(myAccountBoardProvider).asData?.value
              : ref.watch(accountBoardProvider(name)).asData?.value;
          final accountBoard = savedBoard?.isNotEmpty == true
              ? savedBoard!
              : AccountBoard.defaultBoard();

          final showActions = user.value != null && !isCurrentUser;

          Widget buildBoardContent() {
            return ExtendedRefreshIndicator(
              onRefresh: refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: explorePageGutter(context).copyWith(
                  top: kExploreCardGap,
                  bottom:
                      MediaQuery.paddingOf(context).bottom + kExploreCardGap,
                ),
                child: Column(
                  spacing: kExploreCardGap,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AccountBasicInfo(
                      data: data,
                      uname: name,
                      accountDeveloper: accountDeveloper,
                      showHeaderImage: false,
                    ),
                    if (showActions)
                      _AccountAction(
                        data: data,
                        accountRelationship: accountRelationship,
                        accountChat: accountChat,
                        relationshipAction: relationshipAction,
                        blockAction: blockAction,
                        directMessageAction: directMessageAction,
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
          }

          final boardContentWithoutHeader = buildBoardContent();

          final boardContentNoHeader = ExtendedRefreshIndicator(
            onRefresh: refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: explorePageGutter(context).copyWith(
                top: kExploreCardGap,
                bottom: MediaQuery.paddingOf(context).bottom + kExploreCardGap,
              ),
              child: Column(
                spacing: kExploreCardGap,
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
                const SliverGap(kExploreCardGap),
                SliverPadding(
                  padding: explorePageGutter(context),
                  sliver: AccountTimelineList(uname: name),
                ),
                SliverGap(
                  MediaQuery.paddingOf(context).bottom + kExploreCardGap,
                ),
              ],
            ),
          );

          final pulsarContent = PulsarProfileTab(
            uname: name,
            showWorkStatuses: isCurrentUser,
            onRefresh: refreshProfile,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final useWide =
                  isWideScreen(context) && constraints.maxWidth >= 900;

              final isHeaderCollapsed = !useWide && collapsed.value;
              final headerColors = profileHeaderColors(theme, headerTint.value);

              // Two tabs always split the pane's width evenly. The bar paints
              // nothing itself: the narrow layout pins it on the page ground
              // through its sliver delegate, while the wide layout keeps it in
              // the pane's own scroll view so it leaves and returns with the
              // content.
              final tabBar = Padding(
                padding: const EdgeInsets.only(
                  top: SolSpace.sm,
                  bottom: SolSpace.xs,
                ),
                child: TabBar(
                  padding: const EdgeInsets.symmetric(horizontal: SolSpace.md),
                  indicator: BoxDecoration(
                    color: isHeaderCollapsed
                        ? headerColors.onPrimary.withOpacity(0.22)
                        : theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(SolRadius.lg),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: isHeaderCollapsed
                      ? headerColors.onPrimary
                      : theme.colorScheme.onSecondaryContainer,
                  unselectedLabelColor: isHeaderCollapsed
                      ? headerColors.onPrimary.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant,
                  splashBorderRadius: BorderRadius.circular(SolRadius.lg),
                  labelStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SolSpace.xs,
                        ),
                        child: Text('board'.tr()),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SolSpace.xs,
                        ),
                        child: Text('timeline'.tr()),
                      ),
                    ),
                    Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SolSpace.xs,
                        ),
                        child: Text('pulsar'.tr()),
                      ),
                    ),
                  ],
                ),
              );

              if (!useWide) {
                return ProfileHeaderScrollListener(
                  collapsed: collapsed,
                  threshold: profileHeaderCollapseThreshold(context, 220),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      ProfileHeaderAppBar(
                        title: data.nick,
                        background: CloudImageWidget(
                          file: data.profile.background,
                          fit: BoxFit.cover,
                          imageOnly: true,
                        ),
                        samplingProvider: data.profile.background == null
                            ? null
                            : CloudImageWidget.provider(
                                file: data.profile.background!,
                                serverUrl: serverUrl,
                              ),
                        leading: const AutoLeadingButton(),
                        collapsed: collapsed,
                        tintNotifier: headerTint,
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _ProfileTabBarHeaderDelegate(
                          child: tabBar,
                          backgroundColor: isHeaderCollapsed
                              ? headerColors.primary
                              : theme.colorScheme.surface,
                        ),
                      ),
                    ],
                    body: TabBarView(
                      children: [
                        boardContentWithoutHeader,
                        timelineContent,
                        pulsarContent,
                      ],
                    ),
                  ),
                );
              }

              return Row(
                spacing: SolSpace.sm,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: SolSpace.md,
                        top: kExploreCardGap,
                      ),
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) => [
                          SliverFloatingTabBar(
                            backgroundColor: theme.colorScheme.surface,
                            child: tabBar,
                          ),
                        ],
                        body: TabBarView(
                          children: [
                            boardContentNoHeader,
                            timelineContent,
                            pulsarContent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        vertical: kExploreCardGap,
                        horizontal: SolSpace.md,
                      ),
                      child: Column(
                        spacing: kExploreCardGap,
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
                          if (showActions)
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

class _ProfileTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  /// TabBar (46) plus the bar's own vertical padding: `SolSpace.sm` above,
  /// `SolSpace.xs` below.
  static const double _height = kFloatingTabBarHeight;

  _ProfileTabBarHeaderDelegate({
    required this.child,
    required this.backgroundColor,
  });

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: backgroundColor,
      elevation: 0,
      child: SizedBox(height: _height, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _ProfileTabBarHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
