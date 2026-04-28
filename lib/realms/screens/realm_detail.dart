import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:island/accounts/account_pod.dart';
import 'package:island/accounts/widgets/account/account_pfc.dart';
import 'package:island/accounts/widgets/account/account_picker.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/chat/widgets/chat_room_list_tile.dart';
import 'package:island/core/utils/text.dart';
import 'package:island/payments/payment_overlay.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:island/realms/models/realm_overview.dart';
import 'package:island/realms/widgets/realm_form_content.dart';
import 'package:island/realms/widgets/realm_label.dart';
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:island/core/services/responsive.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/realms/screens/realms.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/layouts/sheet_scaffold.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:styled_widget/styled_widget.dart';

const _realmBoostThresholds = [0, 10, 25, 50];

class _RealmExperienceCard extends StatelessWidget {
  const _RealmExperienceCard({required this.identity});

  final SnRealmMember identity;

  @override
  Widget build(BuildContext context) {
    final progress = identity.levelingProgress.clamp(0.0, 1.0);
    final progressPercent = (progress * 100).toStringAsFixed(1);
    final accent = Theme.of(context).colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.14),
            Theme.of(context).colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Lv ${identity.level}',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$progressPercent%',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Gap(10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            minHeight: 4,
            stopIndicatorColor: accent,
            color: accent,
          ).padding(horizontal: 2),
        ],
      ),
    );
  }
}

class _RealmPinnedPostsPageView extends HookConsumerWidget {
  final String realmSlug;

  const _RealmPinnedPostsPageView({required this.realmSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: 'realm-$realmSlug-pinned',
        initialFilter: PostListQuery(realm: realmSlug, pinned: true),
      ),
    );
    final pinnedPosts = ref.watch(provider);
    final pageController = usePageController();
    final currentPage = useState(0);

    useEffect(() {
      void listener() {
        currentPage.value = pageController.page?.round() ?? 0;
      }

      pageController.addListener(listener);
      return () => pageController.removeListener(listener);
    }, [pageController]);

    return pinnedPosts.when(
      data: (data) {
        if (data.items.isEmpty) {
          return const SizedBox.shrink();
        }

        final contentWidget = Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: true,
            leading: const Icon(Symbols.push_pin),
            title: Text('pinnedPosts'.tr()),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            children: [
              SizedBox(
                height: 400,
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: data.items.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: SingleChildScrollView(
                            child: Card(
                              child: PostActionableItem(
                                item: data.items[index],
                                borderRadius: 8,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          data.items.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == currentPage.value
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.primary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (!isWideScreen(context)) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: contentWidget,
          );
        }

        return Card.outlined(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: contentWidget,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

final realmOverviewProvider = FutureProvider.autoDispose
    .family<SnRealm, String>((ref, realmSlug) async {
      final client = ref.watch(solarNetworkClientProvider);
      return await client.realms.getRealm(realmSlug);
    });

final realmBoostStatusProvider = FutureProvider.autoDispose
    .family<RealmBoostStatus, String>((ref, realmSlug) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.realms.getBoostStatus(realmSlug);
      return RealmBoostStatus.fromJson(response);
    });

final realmBoostLeaderboardProvider = FutureProvider.autoDispose
    .family<List<RealmBoostLeaderboardEntry>, String>((ref, realmSlug) async {
      final client = ref.watch(solarNetworkClientProvider);
      final data = await client.realms.getBoostLeaderboard(
        slug: realmSlug,
        take: 20,
      );
      return data
          .map(
            (e) => RealmBoostLeaderboardEntry.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    });

final realmLabelsProvider = FutureProvider.autoDispose
    .family<List<RealmLabel>, String>((ref, realmSlug) async {
      final client = ref.watch(solarNetworkClientProvider);
      final labels = await client.realms.getLabels(realmSlug);
      return labels.map((e) => RealmLabel.fromJson(e.toJson())).toList();
    });

final realmIdentityProvider = FutureProvider.autoDispose
    .family<SnRealmMember?, String>((ref, realmSlug) async {
      try {
        final client = ref.watch(solarNetworkClientProvider);
        return await client.realms.getMyMembership(realmSlug);
      } catch (err) {
        if (err is DioException && err.response?.statusCode == 404) {
          return null;
        }
        rethrow;
      }
    });

final realmChatRoomsProvider = FutureProvider.autoDispose
    .family<List<SnChatRoom>, String>((ref, realmSlug) async {
      final client = ref.watch(solarNetworkClientProvider);
      final response = await client.realms.getRealmChat(realmSlug);
      return response;
    });

class _RealmBasisWidget extends HookConsumerWidget {
  final SnRealm data;
  final String slug;

  const _RealmBasisWidget({required this.data, required this.slug});

  String _getFirstLine(String text) {
    final lines = text.split('\n');
    if (lines.isEmpty) return '';
    return lines.first.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDescExpanded = useState(false);
    final theme = Theme.of(context);
    final realmIdentity = ref.watch(realmIdentityProvider(slug));

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
                  child: data.background != null
                      ? CloudImageWidget(
                          file: data.background!,
                          fit: BoxFit.cover,
                        )
                      : Container(color: theme.colorScheme.primaryContainer),
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
                    file: data.picture,
                    radius: 32,
                    fallbackIcon: Symbols.group,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (!data.isPublic)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'private',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ).tr(),
                      ),
                  ],
                ),
                const Gap(4),
                if (data.description.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isDescExpanded.value
                              ? MarkdownTextContent(
                                  content: data.description,
                                  key: const ValueKey('expanded'),
                                )
                              : Text(
                                  _getFirstLine(data.description),
                                  key: const ValueKey('collapsed'),
                                ),
                        ),
                      ),
                      if (data.description.contains('\n'))
                        InkWell(
                          onTap: () =>
                              isDescExpanded.value = !isDescExpanded.value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              isDescExpanded.value
                                  ? 'collapse'.tr()
                                  : 'expand'.tr(),
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
                realmIdentity.when(
                  data: (identity) {
                    if (identity == null) {
                      if (!data.isCommunity) return const SizedBox.shrink();
                      return FilledButton.icon(
                        onPressed: () async {
                          try {
                            final client = ref.read(solarNetworkClientProvider);
                            await client.realms.joinRealm(slug);
                            ref.invalidate(realmIdentityProvider(slug));
                            ref.invalidate(realmOverviewProvider(slug));
                            ref.invalidate(realmsJoinedProvider);
                            showSnackBar('realmJoinSuccess'.tr());
                          } catch (err) {
                            showErrorAlert(err);
                          }
                        },
                        icon: const Icon(Symbols.add),
                        label: Text('realmJoin').tr(),
                        style: ButtonStyle(
                          visualDensity: VisualDensity(vertical: -2),
                        ),
                      ).padding(top: 12);
                    }
                    return const SizedBox.shrink();
                  },
                  loading: () => const SizedBox(
                    height: 40,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ).padding(top: 12),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

@RoutePage()
class RealmDetailScreen extends HookConsumerWidget {
  final String slug;

  const RealmDetailScreen({super.key, @PathParam("slug") required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realmState = ref.watch(realmOverviewProvider(slug));
    final overviewOrNull = realmState.asData?.value;

    final realmIdentity = ref.watch(realmIdentityProvider(slug));
    final realmChatRooms = ref.watch(realmChatRoomsProvider(slug));
    final realmBoostStatus = ref.watch(realmBoostStatusProvider(slug));
    final realmLabels = ref.watch(realmLabelsProvider(slug));
    final boostFallback = RealmBoostStatus(
      boostPoints: overviewOrNull?.boostPoints ?? 0,
      boostLevel: overviewOrNull?.boostLevel ?? 0,
      labelCap: 0,
      expiresAfterDays: 30,
      supportedCurrencies: const ['golds', 'points'],
      defaultCurrency: 'golds',
    );

    Widget realmBoostWidget(SnRealm realm, RealmBoostStatus boost) {
      final nextThreshold = boost.boostLevel >= _realmBoostThresholds.length - 1
          ? null
          : _realmBoostThresholds[boost.boostLevel + 1];
      final progress = boost.boostPoints / (nextThreshold ?? 1);

      return Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RealmBoost'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Boost leaderboard',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      builder: (_) =>
                          _RealmBoostLeaderboardSheet(realmSlug: slug),
                    );
                  },
                  visualDensity: VisualDensity(vertical: -3),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  icon: const Icon(Symbols.leaderboard),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      builder: (_) => _RealmBoostSheet(
                        realmSlug: slug,
                        realmName: realm.name,
                      ),
                    );
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity(vertical: -3),
                  ),
                  icon: const Icon(Symbols.volunteer_activism),
                  label: Text('Boost'.tr()),
                ),
              ],
            ),
            const Gap(12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Icon(Symbols.rocket_launch, size: 17, fill: 1),
                    Text(
                      'boostLevel'.tr(
                        namedArgs: {'level': boost.boostLevel.toString()},
                      ),
                    ).fontSize(12),
                  ],
                ),
                const Gap(4),

                Row(
                  spacing: 6,
                  children: [
                    Icon(Symbols.label, size: 17, fill: 1),
                    Text(
                      'labelCap'.tr(
                        namedArgs: {'cap': boost.labelCap.toString()},
                      ),
                    ).fontSize(12),
                  ],
                ),
              ],
            ),
            const Gap(4),
            Row(
              spacing: 6,
              children: [
                Icon(Symbols.local_fire_department, size: 17, fill: 1),
                Text(
                  nextThreshold == null
                      ? 'BoostMax'.tr()
                      : '${boost.boostPoints}/$nextThreshold boosts',
                ).fontSize(12),
              ],
            ),
            const Gap(12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [LinearProgressIndicator(value: progress)],
                  ),
                ),
              ],
            ),
            const Gap(8),
            Text(
              boost.boostLevel >= 3
                  ? 'BoostAllUnlocked'.tr()
                  : switch (boost.boostLevel) {
                      0 => 'BoostLevel1Hint'.tr(),
                      1 => 'BoostLevel2Hint'.tr(),
                      2 => 'BoostLevel3Hint'.tr(),
                      _ => 'BoostProgressAvailable'.tr(),
                    },
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(6),
            Text(
              'boostInfo'.tr(
                namedArgs: {
                  'days': boost.expiresAfterDays.toString(),
                  'currencies': boost.supportedCurrencies.join(', '),
                },
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ).padding(all: 16),
      );
    }

    Widget realmIdentityWidget(SnRealm realm, SnRealmMember identity) {
      final userInfo = ref.watch(userInfoProvider);

      return Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RealmIdentity'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit realm identity',
                  visualDensity: VisualDensity(vertical: -3),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      builder: (_) => _RealmIdentityEditorSheet(
                        realmSlug: slug,
                        identity: identity,
                      ),
                    );
                  },
                  icon: const Icon(Symbols.edit),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child:
                      Text(
                            identity.role >= 100
                                ? 'permissionOwner'
                                : identity.role >= 50
                                ? 'permissionModerator'
                                : 'permissionMember',
                          )
                          .tr()
                          .fontSize(10)
                          .textColor(
                            Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                ),
              ],
            ),
            const Gap(12),
            if (identity.nick?.isNotEmpty ?? false)
              AccountName(
                textOverride: identity.nick,
                account: userInfo.value!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (identity.bio?.isNotEmpty ?? false)
              Text(
                identity.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            if ((identity.bio?.isEmpty ?? true) &&
                (identity.nick?.isEmpty ?? true))
              Text(
                realm.boostLevel >= 1
                    ? 'NoRealmSpecSet'.tr()
                    : 'RealmBoostFunction'.tr(),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (identity.labelId != null) ...[
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.secondaryFixedDim,
                  ),
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      spacing: 4,
                      children: [
                        Icon(
                          Symbols.label,
                          size: 16,
                          fill: 1,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSecondaryContainer,
                        ),
                        Text('RealmLabel'.tr())
                            .fontSize(12)
                            .textColor(
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                            ),
                      ],
                    ),
                    Row(
                      spacing: 8,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((identity.label?.icon ?? '').isNotEmpty)
                          Text(identity.label!.icon!),
                        RealmLabelWidget(label: identity.label!, fontSize: 11),
                        if ((identity.label?.description ?? '').isNotEmpty)
                          Expanded(
                            child: Text(
                              identity.label!.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ).padding(top: 2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Gap(12),
            _RealmExperienceCard(identity: identity),
          ],
        ).padding(all: 16),
      );
    }

    Widget realmLabelsWidget(
      SnRealm realm,
      SnRealmMember identity,
      RealmBoostStatus boost,
    ) {
      if (identity.role < 50) return const SizedBox.shrink();

      return Card(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'RealmLabels'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh labels',
                  visualDensity: VisualDensity(vertical: -3),
                  onPressed: () => ref.invalidate(realmLabelsProvider(slug)),
                  icon: const Icon(Symbols.refresh),
                ),
                FilledButton.tonalIcon(
                  onPressed: boost.boostLevel < 1
                      ? null
                      : () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            builder: (_) =>
                                _RealmLabelEditorSheet(realmSlug: slug),
                          );
                        },
                  icon: const Icon(Symbols.add),
                  label: Text('Add'.tr()),
                ),
              ],
            ),
            const Gap(8),
            Text(
              boost.boostLevel < 1
                  ? 'boostRequiredToUnlockLabels'.tr()
                  : 'labelsUsage'.tr(
                      namedArgs: {
                        'used': (realmLabels.asData?.value.length ?? 0)
                            .toString(),
                        'total': boost.labelCap.toString(),
                      },
                    ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(12),
            realmLabels.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text(
                'Error: $error',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              data: (labels) {
                if (labels.isEmpty) {
                  return Text(
                    'NoLabelsCreated'.tr(),
                    style: Theme.of(context).textTheme.bodySmall,
                  );
                }
                return Column(
                  children: labels.map((label) {
                    final labelColor = label.color?.parseHexColor();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            (labelColor ??
                                    Theme.of(context).colorScheme.primary)
                                .withOpacity(0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if ((label.icon ?? '').isNotEmpty) ...[
                            Text(label.icon!),
                            const Gap(8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  label.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: labelColor,
                                  ),
                                ),
                                if ((label.description ?? '').isNotEmpty)
                                  Text(
                                    label.description!,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit label',
                            onPressed: boost.boostLevel < 1
                                ? null
                                : () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useRootNavigator: true,
                                      builder: (_) => _RealmLabelEditorSheet(
                                        realmSlug: slug,
                                        label: label,
                                      ),
                                    );
                                  },
                            icon: const Icon(Symbols.edit),
                          ),
                          IconButton(
                            tooltip: 'Delete label',
                            onPressed: boost.boostLevel < 1
                                ? null
                                : () {
                                    showConfirmAlert(
                                      'Delete this label?',
                                      label.name,
                                      isDanger: true,
                                    ).then((confirm) async {
                                      if (confirm != true) return;
                                      try {
                                        final client = ref.read(
                                          solarNetworkClientProvider,
                                        );
                                        await client.realms.deleteLabel(
                                          slug: slug,
                                          labelId: label.id,
                                        );
                                        ref.invalidate(
                                          realmLabelsProvider(slug),
                                        );
                                        ref.invalidate(
                                          realmMemberListNotifierProvider(slug),
                                        );
                                        ref.invalidate(
                                          realmIdentityProvider(slug),
                                        );
                                      } catch (err) {
                                        showErrorAlert(err);
                                      }
                                    });
                                  },
                            icon: const Icon(Symbols.delete),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ).padding(all: 16),
      );
    }

    Widget realmChatRoomListWidget(SnRealm realm) => Card(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'chatTabGroup',
          ).tr().bold().padding(horizontal: 24, top: 12, bottom: 4),
          realmChatRooms.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (rooms) {
              if (rooms.isEmpty) {
                return Text(
                  'dataEmpty',
                ).tr().padding(horizontal: 24, bottom: 12);
              }
              return Column(
                children: [
                  for (final room in rooms)
                    ChatRoomListTile(
                      room: room,
                      onTap: () {
                        context.router.navigate(ChatRoomRoute(id: room.id));
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );

    return AppScaffold(
      isNoBackground: false,
      appBar: isWideScreen(context)
          ? realmState.when(
              data: (overview) => AppBar(
                leading: AutoLeadingButton(),
                title: Text(overview.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.people),
                    onPressed: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (context) =>
                            _RealmMemberListSheet(realmSlug: slug),
                      );
                    },
                  ),
                  _RealmActionMenu(realmSlug: slug),
                  const Gap(8),
                ],
              ),
              error: (_, _) => AppBar(leading: AutoLeadingButton()),
              loading: () => AppBar(leading: AutoLeadingButton()),
            )
          : null,
      body: realmState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (overview) => isWideScreen(context)
            ? Row(
                spacing: 12,
                children: [
                  Flexible(
                    flex: 3,
                    child: Card(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      margin: const EdgeInsets.fromLTRB(12, 8, 0, 0),
                      child: CustomScrollView(
                        slivers: [
                          const SliverGap(12),
                          SliverToBoxAdapter(
                            child: _RealmPinnedPostsPageView(
                              realmSlug: slug,
                            ).padding(horizontal: 8),
                          ),
                          SliverPostList(
                            query: PostListQuery(realm: slug, pinned: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: ListView(
                      padding: const EdgeInsets.only(top: 8),
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _RealmBasisWidget(data: overview, slug: slug),
                            const Gap(8),
                            realmBoostStatus.when(
                              data: (boost) =>
                                  realmBoostWidget(overview, boost),
                              loading: () =>
                                  realmBoostWidget(overview, boostFallback),
                              error: (_, _) =>
                                  realmBoostWidget(overview, boostFallback),
                            ),
                            const Gap(8),
                            realmIdentity.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                              data: (identity) {
                                if (identity != null) {
                                  return realmIdentityWidget(
                                    overview,
                                    identity,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                            const Gap(8),
                            realmIdentity.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                              data: (identity) {
                                if (identity == null) {
                                  return const SizedBox.shrink();
                                }
                                return realmBoostStatus.when(
                                  data: (boost) => realmLabelsWidget(
                                    overview,
                                    identity,
                                    boost,
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                );
                              },
                            ),
                          ],
                        ),
                        const Gap(8),
                        realmChatRoomListWidget(overview),
                        const Gap(8),
                      ],
                    ),
                  ),
                ],
              ).padding(horizontal: 8)
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    leading: AutoLeadingButton(),
                    title: Text(overview.name),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.people),
                        onPressed: () {
                          showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (context) =>
                                _RealmMemberListSheet(realmSlug: slug),
                          );
                        },
                      ),
                      _RealmActionMenu(realmSlug: slug),
                      const Gap(8),
                    ],
                  ),
                  const SliverGap(12),
                  SliverToBoxAdapter(
                    child: _RealmBasisWidget(
                      data: overview,
                      slug: slug,
                    ).padding(horizontal: 12),
                  ),
                  const SliverGap(12),
                  SliverToBoxAdapter(
                    child: Column(
                      spacing: 12,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        realmBoostStatus.when(
                          data: (boost) => realmBoostWidget(overview, boost),
                          loading: () =>
                              realmBoostWidget(overview, boostFallback),
                          error: (_, _) =>
                              realmBoostWidget(overview, boostFallback),
                        ),
                        realmIdentity.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (identity) {
                            if (identity != null) {
                              return realmIdentityWidget(overview, identity);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        realmIdentity.when(
                          loading: () => const SizedBox.shrink(),
                          error: (_, _) => const SizedBox.shrink(),
                          data: (identity) {
                            if (identity == null) {
                              return const SizedBox.shrink();
                            }
                            return realmBoostStatus.when(
                              data: (boost) =>
                                  realmLabelsWidget(overview, identity, boost),
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            );
                          },
                        ),
                      ],
                    ).padding(horizontal: 12),
                  ),
                  SliverToBoxAdapter(
                    child: realmChatRoomListWidget(
                      overview,
                    ).padding(horizontal: 12, vertical: 12),
                  ),
                  SliverToBoxAdapter(
                    child: _RealmPinnedPostsPageView(realmSlug: slug),
                  ),
                  SliverPostList(
                    query: PostListQuery(realm: slug, pinned: false),
                  ),
                ],
              ),
      ),
    );
  }
}

class _RealmActionMenu extends HookConsumerWidget {
  final String realmSlug;

  const _RealmActionMenu({required this.realmSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realmIdentity = ref.watch(realmIdentityProvider(realmSlug));
    final isModerator = realmIdentity.when(
      data: (identity) => (identity?.role ?? 0) >= 50,
      loading: () => false,
      error: (_, _) => false,
    );

    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        if (isModerator)
          PopupMenuItem(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                builder: (_) => _RealmEditSheet(slug: realmSlug),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
                const Gap(12),
                const Text('editRealm').tr(),
              ],
            ),
          ),
        realmIdentity.when(
          data: (identity) => (identity?.role ?? 0) >= 100
              ? PopupMenuItem(
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const Gap(12),
                      const Text(
                        'deleteRealm',
                        style: TextStyle(color: Colors.red),
                      ).tr(),
                    ],
                  ),
                  onTap: () {
                    showConfirmAlert(
                      'deleteRealmHint'.tr(),
                      'deleteRealm'.tr(),
                      isDanger: true,
                    ).then((confirm) {
                      if (confirm) {
                        final client = ref.watch(solarNetworkClientProvider);
                        client.realms.deleteRealm(realmSlug);
                        ref.invalidate(realmsJoinedProvider);
                        ref.invalidate(realmOverviewProvider(realmSlug));
                        if (context.mounted) {
                          context.router.pop(true);
                        }
                      }
                    });
                  },
                )
              : PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(
                        Icons.exit_to_app,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const Gap(12),
                      Text(
                        'leaveRealm',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ).tr(),
                    ],
                  ),
                  onTap: () {
                    showConfirmAlert(
                      'leaveRealmHint'.tr(),
                      'leaveRealm'.tr(),
                    ).then((confirm) async {
                      if (confirm) {
                        final client = ref.watch(solarNetworkClientProvider);
                        await client.realms.leaveRealm(realmSlug);
                        ref.invalidate(realmsJoinedProvider);
                        ref.invalidate(realmIdentityProvider(realmSlug));
                        ref.invalidate(realmOverviewProvider(realmSlug));
                        if (context.mounted) {
                          context.router.pop(true);
                        }
                      }
                    });
                  },
                ),
          loading: () => const PopupMenuItem(
            enabled: false,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => PopupMenuItem(
            child: Row(
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Theme.of(context).colorScheme.error,
                ),
                const Gap(12),
                Text(
                  'leaveRealm',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ).tr(),
              ],
            ),
            onTap: () {
              showConfirmAlert('leaveRealmHint'.tr(), 'leaveRealm'.tr()).then((
                confirm,
              ) async {
                if (confirm) {
                  final client = ref.watch(solarNetworkClientProvider);
                  await client.realms.leaveRealm(realmSlug);
                  ref.invalidate(realmsJoinedProvider);
                  ref.invalidate(realmIdentityProvider(realmSlug));
                  ref.invalidate(realmOverviewProvider(realmSlug));
                  if (context.mounted) {
                    context.router.pop(true);
                  }
                }
              });
            },
          ),
        ),
      ],
    );
  }
}

final realmMemberListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family(RealmMemberListNotifier.new);

class RealmMemberListNotifier
    extends AsyncNotifier<PaginationState<SnRealmMember>>
    with AsyncPaginationController<SnRealmMember> {
  String arg;
  RealmMemberListNotifier(this.arg);

  static const int pageSize = 20;

  @override
  Future<List<SnRealmMember>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final result = await client.realms.getMembers(
      slug: arg,
      offset: fetchedCount,
      take: pageSize,
    );

    totalCount = result.totalCount;
    return result.items;
  }
}

class _RealmMemberListSheet extends HookConsumerWidget {
  final String realmSlug;
  const _RealmMemberListSheet({required this.realmSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberListProvider = realmMemberListNotifierProvider(realmSlug);

    final memberListState = ref.watch(memberListProvider);
    final memberListNotifier = ref.watch(memberListProvider.notifier);
    final realmIdentity = ref.watch(realmIdentityProvider(realmSlug));

    Future<void> invitePerson() async {
      final result = await showModalBottomSheet(
        isScrollControlled: true,
        useRootNavigator: true,
        context: context,
        builder: (context) => const AccountPickerSheet(),
      );
      if (result == null) return;
      try {
        final client = ref.watch(solarNetworkClientProvider);
        await client.realms.dio.post(
          '/passport/realms/invites/$realmSlug',
          data: {'related_user_id': result.id, 'role': 0},
        );
        // Refresh the provider
        memberListNotifier.refresh();
      } catch (err) {
        showErrorAlert(err);
      }
    }

    Widget buildMemberListHeader() {
      return Padding(
        padding: EdgeInsets.only(top: 16, left: 20, right: 16, bottom: 12),
        child: Row(
          children: [
            Consumer(
              builder: (context, ref, _) {
                return Text(
                  'members'.plural(memberListState.value?.totalCount ?? 0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                );
              },
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Symbols.person_add),
              onPressed: invitePerson,
              style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
            ),
            IconButton(
              icon: const Icon(Symbols.refresh),
              onPressed: () {
                // Refresh the provider
                ref.invalidate(memberListProvider);
              },
            ),
            IconButton(
              icon: const Icon(Symbols.close),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(minimumSize: const Size(36, 36)),
            ),
          ],
        ),
      );
    }

    Widget buildMemberListContent() {
      return Expanded(
        child: PaginationList(
          provider: memberListProvider,
          notifier: memberListProvider.notifier,
          itemBuilder: (context, index, member) {
            return ListTile(
              contentPadding: EdgeInsets.only(left: 16, right: 12),
              leading: AccountPfcRegion(
                uname: member.account!.name,
                child: ProfilePictureWidget(
                  file: member.account!.profile.picture,
                ),
              ),
              title: Row(
                spacing: 6,
                children: [
                  Flexible(
                    child: Text(
                      member.account!.nick,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (member.status != null)
                    AccountStatusLabel(status: member.status!),
                  if (member.label != null)
                    RealmLabelWidget(label: member.label!, fontSize: 10),
                  if (member.joinedAt == null)
                    const Icon(Symbols.pending_actions, size: 20),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    member.role >= 100
                        ? 'permissionOwner'
                        : member.role >= 50
                        ? 'permissionModerator'
                        : 'permissionMember',
                  ).tr(),
                  Text('·').bold().padding(horizontal: 6),
                  Expanded(child: Text("@${member.account!.name}")),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((realmIdentity.value?.role ?? 0) >= 50)
                    IconButton(
                      icon: const Icon(Symbols.label),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => _RealmMemberLabelSheet(
                            realmSlug: realmSlug,
                            member: member,
                          ),
                        ).then((value) {
                          if (value != null) {
                            ref.invalidate(memberListProvider);
                            ref.invalidate(realmIdentityProvider(realmSlug));
                          }
                        });
                      },
                    ),
                  if ((realmIdentity.value?.role ?? 0) >= 50)
                    IconButton(
                      icon: const Icon(Symbols.edit),
                      onPressed: () {
                        showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (context) => _RealmMemberRoleSheet(
                            realmSlug: realmSlug,
                            member: member,
                          ),
                        ).then((value) {
                          if (value != null) {
                            // Refresh the provider
                            ref.invalidate(memberListProvider);
                          }
                        });
                      },
                    ),
                  if ((realmIdentity.value?.role ?? 0) >= 50)
                    IconButton(
                      icon: const Icon(Symbols.delete),
                      onPressed: () {
                        showConfirmAlert(
                          'removeRealmMemberHint'.tr(),
                          'removeRealmMember'.tr(),
                        ).then((confirm) async {
                          if (confirm != true) return;
                          try {
                            final client = ref.watch(
                              solarNetworkClientProvider,
                            );
                            await client.realms.kickMember(
                              slug: realmSlug,
                              accountId: member.accountId,
                            );
                            // Refresh the provider
                            ref.invalidate(memberListProvider);
                          } catch (err) {
                            showErrorAlert(err);
                          }
                        });
                      },
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          buildMemberListHeader(),
          const Divider(height: 1),
          buildMemberListContent(),
        ],
      ),
    );
  }
}

class _RealmMemberRoleSheet extends HookConsumerWidget {
  final String realmSlug;
  final SnRealmMember member;

  const _RealmMemberRoleSheet({required this.realmSlug, required this.member});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleController = useTextEditingController(
      text: member.role.toString(),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 16,
                bottom: 12,
              ),
              child: Row(
                children: [
                  Text(
                    'memberRoleEdit'.tr(args: [member.account!.name]),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Symbols.close),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      minimumSize: const Size(36, 36),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Autocomplete<int>(
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return const [100, 50, 0];
                    }
                    final int? value = int.tryParse(textEditingValue.text);
                    if (value == null) return const [100, 50, 0];
                    return [100, 50, 0].where(
                      (option) =>
                          option.toString().contains(textEditingValue.text),
                    );
                  },
                  onSelected: (int selection) {
                    roleController.text = selection.toString();
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'memberRole'.tr(),
                            helperText: 'memberRoleHint'.tr(),
                          ),
                          onTapOutside: (event) => focusNode.unfocus(),
                        );
                      },
                ),
                const Gap(16),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      final newRole = int.parse(roleController.text);
                      if (newRole < 0 || newRole > 100) {
                        throw 'Role must be between 0 and 100';
                      }

                      final client = ref.read(solarNetworkClientProvider);
                      await client.realms.updateMemberRole(
                        slug: realmSlug,
                        accountId: member.accountId,
                        role: newRole,
                      );

                      if (context.mounted) Navigator.pop(context, true);
                    } catch (err) {
                      showErrorAlert(err);
                    }
                  },
                  icon: const Icon(Symbols.save),
                  label: const Text('saveChanges').tr(),
                ),
              ],
            ).padding(vertical: 16, horizontal: 24),
          ],
        ),
      ),
    );
  }
}

class _RealmIdentityEditorSheet extends HookConsumerWidget {
  const _RealmIdentityEditorSheet({
    required this.realmSlug,
    required this.identity,
  });

  final String realmSlug;
  final SnRealmMember identity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickController = useTextEditingController(text: identity.nick ?? '');
    final bioController = useTextEditingController(text: identity.bio ?? '');

    return SheetScaffold(
      heightFactor: 0.6,
      titleText: 'Edit Realm Identity',
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nickController,
              maxLength: 1024,
              decoration: InputDecoration(labelText: 'nickname'.tr()),
            ),
            const Gap(12),
            TextField(
              controller: bioController,
              maxLines: 4,
              maxLength: 4096,
              decoration: InputDecoration(labelText: 'bio'.tr()),
            ),
            const Gap(16),
            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      try {
                        final client = ref.read(solarNetworkClientProvider);
                        await client.realms.updateMyMembership(
                          slug: realmSlug,
                          data: {
                            'nick': nickController.text.trim().isEmpty
                                ? null
                                : nickController.text.trim(),
                            'bio': bioController.text.trim().isEmpty
                                ? null
                                : bioController.text.trim(),
                          },
                        );
                        ref.invalidate(realmIdentityProvider(realmSlug));
                        ref.invalidate(
                          realmMemberListNotifierProvider(realmSlug),
                        );
                        if (context.mounted) {
                          showSnackBar('saveChanges'.tr());
                          Navigator.pop(context, true);
                        }
                      } catch (err) {
                        showErrorAlert(err);
                      }
                    },
                    icon: const Icon(Symbols.save),
                    label: const Text('saveChanges').tr(),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      identity.nick?.isNotEmpty != true &&
                          identity.bio?.isNotEmpty != true
                      ? null
                      : () async {
                          final confirm = await showConfirmAlert(
                            'clearRealmIdentityHint'.tr(),
                            'clearRealmIdentity'.tr(),
                            isDanger: true,
                          );
                          if (confirm != true) return;
                          try {
                            final client = ref.read(solarNetworkClientProvider);
                            await client.realms.dio.delete(
                              '/passport/realms/$realmSlug/members/me/profile',
                            );
                            ref.invalidate(realmIdentityProvider(realmSlug));
                            ref.invalidate(
                              realmMemberListNotifierProvider(realmSlug),
                            );
                            if (context.mounted) {
                              showSnackBar('cleared'.tr());
                              Navigator.pop(context, true);
                            }
                          } catch (err) {
                            showErrorAlert(err);
                          }
                        },
                  icon: const Icon(Symbols.delete_forever),
                  label: const Text('clear').tr(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RealmMemberLabelSheet extends HookConsumerWidget {
  const _RealmMemberLabelSheet({required this.realmSlug, required this.member});

  final String realmSlug;
  final SnRealmMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(realmLabelsProvider(realmSlug));
    final selectedLabelId = useState<String?>(null);

    return SheetScaffold(
      titleText: 'Assign Label',
      heightFactor: 0.5,
      child: labels.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (items) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                member.account?.nick ?? member.accountId,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(12),
              DropdownButtonFormField<String?>(
                value: selectedLabelId.value,
                decoration: const InputDecoration(labelText: 'Label'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('No label'),
                  ),
                  ...items.map(
                    (label) => DropdownMenuItem<String?>(
                      value: label.id,
                      child: Text(label.name),
                    ),
                  ),
                ],
                onChanged: (value) => selectedLabelId.value = value,
              ),
              const Gap(16),
              FilledButton.icon(
                onPressed: () async {
                  try {
                    final client = ref.read(solarNetworkClientProvider);
                    if (selectedLabelId.value == null) {
                      await client.realms.assignLabel(
                        slug: realmSlug,
                        accountId: member.accountId,
                        labelId: null,
                      );
                    } else {
                      await client.realms.assignLabel(
                        slug: realmSlug,
                        accountId: member.accountId,
                        labelId: selectedLabelId.value!,
                      );
                    }
                    if (context.mounted) Navigator.pop(context, true);
                  } catch (err) {
                    showErrorAlert(err);
                  }
                },
                icon: const Icon(Symbols.save),
                label: const Text('saveChanges').tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealmLabelEditorSheet extends HookConsumerWidget {
  const _RealmLabelEditorSheet({required this.realmSlug, this.label});

  final String realmSlug;
  final RealmLabel? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: label?.name ?? '');
    final descriptionController = useTextEditingController(
      text: label?.description ?? '',
    );
    final colorController = useTextEditingController(text: label?.color ?? '');
    final iconController = useTextEditingController(text: label?.icon ?? '');

    return SheetScaffold(
      titleText: label == null ? 'Create Label' : 'Edit Label',
      heightFactor: 0.6,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const Gap(12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const Gap(12),
            TextField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: 'Color',
                hintText: '#FFB347',
              ),
            ),
            const Gap(12),
            TextField(
              controller: iconController,
              decoration: const InputDecoration(
                labelText: 'Icon',
                hintText: 'emoji or short symbol',
              ),
            ),
            const Gap(16),
            FilledButton.icon(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  showSnackBar('Name is required.');
                  return;
                }

                try {
                  final client = ref.read(solarNetworkClientProvider);
                  if (label == null) {
                    await client.realms.createLabel(
                      slug: realmSlug,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim().isEmpty
                          ? null
                          : descriptionController.text.trim(),
                      color: colorController.text.trim().isEmpty
                          ? null
                          : colorController.text.trim(),
                    );
                  } else {
                    await client.realms.updateLabel(
                      slug: realmSlug,
                      labelId: label!.id,
                      data: {
                        'name': nameController.text.trim(),
                        'description': descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                        'color': colorController.text.trim().isEmpty
                            ? null
                            : colorController.text.trim(),
                        'icon': iconController.text.trim().isEmpty
                            ? null
                            : iconController.text.trim(),
                      },
                    );
                  }
                  ref.invalidate(realmLabelsProvider(realmSlug));
                  if (context.mounted) Navigator.pop(context, true);
                } catch (err) {
                  showErrorAlert(err);
                }
              },
              icon: const Icon(Symbols.save),
              label: Text(label == null ? 'create'.tr() : 'saveChanges'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealmBoostSheet extends HookConsumerWidget {
  const _RealmBoostSheet({required this.realmSlug, required this.realmName});

  final String realmSlug;
  final String realmName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boostStatus = ref.watch(realmBoostStatusProvider(realmSlug));
    final sharesController = useTextEditingController(text: '1');
    final shares = useState<int>(1);
    final selectedCurrency = useState<String?>(null);

    // Listen to text changes and update shares dynamically
    useEffect(() {
      void listener() {
        final parsed = int.tryParse(sharesController.text.trim());
        shares.value = (parsed != null && parsed > 0) ? parsed : 0;
      }

      sharesController.addListener(listener);
      return () => sharesController.removeListener(listener);
    }, [sharesController]);

    final status = boostStatus.asData?.value;
    selectedCurrency.value ??= status?.defaultCurrency ?? 'golds';
    final currency = selectedCurrency.value ?? 'golds';
    final amount = switch (currency) {
      'points' => shares.value * 1000,
      _ => shares.value,
    };

    return SheetScaffold(
      titleText: 'Boost Realm',
      heightFactor: 0.7,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    realmName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'Choose a wallet currency before creating the boost order. Shares stay active for 30 days after payment is applied.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Gap(16),
            TextField(
              controller: sharesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Enter number of shares...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            const Gap(12),
            DropdownButtonFormField<String>(
              value: currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              items: (status?.supportedCurrencies ?? const ['golds', 'points'])
                  .map(
                    (item) => DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        'walletCurrencyShort${item.capitalizeEachWord()}',
                      ).tr(),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  selectedCurrency.value = value;
                }
              },
            ),
            const Gap(16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${shares.value} share${shares.value == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$amount $currency',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Symbols.local_atm),
                ],
              ),
            ),
            const Gap(24),
            FilledButton.tonalIcon(
              onPressed: () async {
                final value = int.tryParse(sharesController.text.trim());
                if (value == null || value <= 0) {
                  showSnackBar('Please enter a valid share count.');
                  return;
                }

                try {
                  showLoadingModal(context);

                  final client = ref.read(solarNetworkClientProvider);
                  final response = await client.realms.boostRealm(
                    slug: realmSlug,
                    shares: value,
                    currency: selectedCurrency.value,
                  );

                  final orderId = response['order_id'] as String;
                  final order = await client.wallet.getOrder(orderId);

                  if (!context.mounted) return;
                  hideLoadingModal(context);

                  final paidOrder = await PaymentOverlay.show(
                    context: context,
                    order: order,
                    enableBiometric: true,
                  );

                  if (paidOrder != null && context.mounted) {
                    ref.invalidate(realmBoostStatusProvider(realmSlug));
                    ref.invalidate(realmBoostLeaderboardProvider(realmSlug));
                    ref.invalidate(realmLabelsProvider(realmSlug));
                    ref.invalidate(realmOverviewProvider(realmSlug));
                    showSnackBar(
                      'Boost payment completed. Active boost points will update after the order event is processed.',
                    );
                    Navigator.of(context).pop();
                  }
                } catch (err) {
                  if (context.mounted) {
                    hideLoadingModal(context);
                    showErrorAlert(err);
                  }
                }
              },
              icon: const Icon(Symbols.volunteer_activism),
              label: const Text('Donate boost'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RealmEditSheet extends HookConsumerWidget {
  final String? slug;

  const _RealmEditSheet({this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SheetScaffold(
      titleText: slug == null ? 'createRealm'.tr() : 'editRealm'.tr(),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: RealmFormContent(
          slug: slug,
          isInSheet: true,
          onSubmit: () {
            if (slug == null) {
              ref.invalidate(realmsJoinedProvider);
            } else {
              ref.invalidate(realmOverviewProvider(slug!));
            }
          },
        ),
      ),
    );
  }
}

class _RealmBoostLeaderboardSheet extends ConsumerWidget {
  const _RealmBoostLeaderboardSheet({required this.realmSlug});

  final String realmSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(
      realmBoostLeaderboardProvider(realmSlug),
    );

    return SheetScaffold(
      titleText: 'Boost Leaderboard',
      child: leaderboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Text(
            'Failed to load boost leaderboard',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.leaderboard, size: 40),
                  const Gap(12),
                  Text(
                    'No boosts yet',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final rank = index + 1;
              final rankColor = switch (rank) {
                1 => Colors.amber,
                2 => Colors.grey,
                3 => Colors.brown,
                _ => Theme.of(context).colorScheme.onSurfaceVariant,
              };

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: rankColor.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const Gap(12),
                      if (entry.account?.profile.picture != null)
                        ProfilePictureWidget(
                          file: entry.account!.profile.picture,
                          radius: 18,
                        )
                      else
                        CircleAvatar(
                          radius: 18,
                          child: Text(
                            entry.account?.nick.substring(0, 1).toUpperCase() ??
                                '?',
                          ),
                        ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.account != null)
                              AccountName(
                                account: entry.account!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            else
                              Text(
                                entry.accountId,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            Text(
                              '${entry.boosts} boost order${entry.boosts == 1 ? '' : 's'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            if (entry.lastBoostedAt != null)
                              Text(
                                'Last boosted ${DateFormat.yMd().add_jm().format(entry.lastBoostedAt!.toLocal())}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.amountGolds.toStringAsFixed(0)} golds',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (entry.amountPoints > 0)
                            Text(
                              '${entry.amountPoints.toStringAsFixed(0)} points',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          Text(
                            '${entry.shares.toStringAsFixed(0)} shares',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
