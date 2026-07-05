import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/badge.dart';
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/layouts/attention_modal_scaffold.dart';
import 'package:island/posts/activity_heatmap.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'publisher_profile.g.dart';

Future<void> showPublisherProfileAttentionModal(String name) async {
  showAttentionModal(
    id: 'publisher-profile:$name',
    replaceIfExists: true,
    barrierDismissible: true,
    builder: (context, dismiss) =>
        PublisherProfileAttentionModal(name: name, onDismiss: dismiss),
  );
}

class PublisherProfileAttentionModal extends StatelessWidget {
  final String name;
  final VoidCallback onDismiss;

  const PublisherProfileAttentionModal({
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
            context.router.push(PublisherProfileRoute(name: name));
          },
          icon: const Icon(Symbols.open_in_new),
          tooltip: 'open'.tr(),
        ),
      ],
      child: PublisherProfileContent(name: name, isEmbedded: true),
    );
  }
}

class _PinnedPostsPageView extends HookConsumerWidget {
  final String pubName;

  const _PinnedPostsPageView({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: 'publisher-$pubName-pinned',
        initialFilter: PostListQuery(pubName: pubName, pinned: true),
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
            margin: EdgeInsets.only(top: 16, bottom: 8),
            child: contentWidget,
          );
        }

        return Card.outlined(
          margin: EdgeInsets.only(top: 16, bottom: 8),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: contentWidget,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PublisherBasisWidget extends HookWidget {
  final SnPublisher data;
  final AsyncValue<SnPublisherSubscriptionStatus?> subStatus;
  final AsyncValue<SnPublisherRatingOverview?> ratingOverview;
  final ValueNotifier<bool> subscribing;
  final VoidCallback subscribe;
  final VoidCallback unsubscribe;
  final void Function(bool currentNotify) toggleNotify;

  const _PublisherBasisWidget({
    required this.data,
    required this.subStatus,
    required this.ratingOverview,
    required this.subscribing,
    required this.subscribe,
    required this.unsubscribe,
    required this.toggleNotify,
  });

  String _getFirstLine(String bio) {
    final lines = bio.split('\n');
    if (lines.isEmpty) return '';
    return lines.first.trim();
  }

  String _formatRating(double rating) {
    if (rating >= 1000000) {
      return '${(rating / 1000000).toStringAsFixed(1)}M';
    } else if (rating >= 1000) {
      return '${(rating / 1000).toStringAsFixed(1)}K';
    }
    return rating.toStringAsFixed(0);
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
                    file: data.background,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: -24,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    shape: data.type == 0
                        ? BoxShape.circle
                        : BoxShape.rectangle,
                    borderRadius: data.type == 0
                        ? null
                        : BorderRadius.all(Radius.circular(12)),
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3,
                    ),
                  ),
                  child: ProfilePictureWidget(
                    file: data.picture,
                    radius: 32,
                    borderRadius: data.type == 0 ? null : 12,
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
                const Gap(16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Flexible(
                      child: data.account != null && data.type == 0
                          ? AccountName(
                              account: data.account!,
                              textOverride: data.nick,
                              hideVerificationMark: true,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              suffixWidgets: [
                                if (data.isModerateSubscription)
                                  Tooltip(
                                    message: 'publisherGatekeptHintShort'.tr(),
                                    child: Icon(
                                      Symbols.lock,
                                      size: 14,
                                      fill: 1,
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                              ],
                            )
                          : Text(
                              data.nick,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    if (data.verification != null)
                      VerificationMark(mark: data.verification!),
                    // Rating grade indicator
                    ratingOverview.when(
                      data: (overview) {
                        if (overview == null) return const SizedBox.shrink();
                        final textColor = switch (overview.grade) {
                          'S++' => theme.colorScheme.tertiary,
                          'S+' => theme.colorScheme.tertiary,
                          'S' => theme.colorScheme.primary,
                          'A++' => theme.colorScheme.primary,
                          'A+' => theme.colorScheme.primary,
                          'A' => theme.colorScheme.primary,
                          'A-' => theme.colorScheme.primary,
                          'B+' => theme.colorScheme.secondary,
                          'B' => theme.colorScheme.secondary,
                          'C' => theme.colorScheme.onSurfaceVariant,
                          'D' => theme.colorScheme.error,
                          _ => theme.colorScheme.onSurfaceVariant,
                        };
                        return Tooltip(
                          message:
                              '${overview.rating.toStringAsFixed(1)} · ${'ratingPercentile'.tr(args: [overview.percentile.toStringAsFixed(1)])}',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: switch (overview.grade) {
                                'S++' => theme.colorScheme.tertiaryContainer,
                                'S+' => theme.colorScheme.tertiaryContainer,
                                'S' => theme.colorScheme.primaryContainer,
                                'A++' => theme.colorScheme.primaryContainer,
                                'A+' => theme.colorScheme.primaryContainer,
                                'A' => theme.colorScheme.primaryContainer,
                                'A-' => theme.colorScheme.primaryContainer,
                                'B+' => theme.colorScheme.secondaryContainer,
                                'B' => theme.colorScheme.secondaryContainer,
                                'C' =>
                                  theme.colorScheme.surfaceContainerHighest,
                                'D' => theme.colorScheme.errorContainer,
                                _ => theme.colorScheme.surfaceContainerHighest,
                              },
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  switch (overview.grade) {
                                    'S++' => Symbols.emoji_events,
                                    'S+' => Symbols.emoji_events,
                                    'S' => Symbols.star,
                                    'A++' => Symbols.trending_up,
                                    'A+' => Symbols.trending_up,
                                    'A' => Symbols.trending_up,
                                    'A-' => Symbols.trending_up,
                                    'B+' => Symbols.thumb_up,
                                    'B' => Symbols.thumb_up,
                                    'C' => Symbols.remove,
                                    'D' => Symbols.trending_down,
                                    _ => Symbols.remove,
                                  },
                                  size: 14,
                                  color: textColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${overview.grade} ${_formatRating(overview.rating)}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                    // Handle chip - responsive layout
                    if (isWideScreen(context))
                      Flexible(
                        child: HandleChip(
                          handle: data.name,
                          allowCopy: true,
                          maxLines: 1,
                        ),
                      ),
                  ],
                ),
                if (!isWideScreen(context))
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                    child: HandleChip(
                      handle: data.name,
                      allowCopy: true,
                      maxLines: 1,
                    ),
                  ),
                if (data.account != null && data.type == 0) ...[
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(
                                Symbols.person,
                                size: 18,
                                color: theme.colorScheme.onSecondaryContainer,
                                fill: 1,
                              ),
                              Text(
                                'publisherBelongsTo'.tr(
                                  args: ['@${data.account!.name}'],
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          context.router.push(
                            AccountProfileRoute(name: data.account!.name),
                          );
                        },
                      ).padding(top: 8, bottom: 4),
                    ],
                  ),
                ],
                if (data.realm != null) ...[
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer
                                .withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 8,
                            children: [
                              Icon(
                                Symbols.public,
                                size: 18,
                                color: theme.colorScheme.onTertiaryContainer,
                                fill: 1,
                              ),
                              Text(
                                'publisherBelongsToRealm'.tr(
                                  args: [data.realm!.name],
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          context.router.push(
                            RealmDetailRoute(slug: data.realm!.slug),
                          );
                        },
                      ).padding(top: 8, bottom: 4),
                    ],
                  ),
                ],
                const Gap(4),
                if (data.account != null && data.type == 0)
                  AccountStatusWidget(
                    uname: data.account!.name,
                    padding: EdgeInsets.zero,
                  ),
                subStatus
                    .when(
                      data: (status) {
                        if (status == null) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FilledButton.icon(
                                onPressed: subscribing.value ? null : subscribe,
                                icon: const Icon(Symbols.add_circle),
                                label: Text('subscribe').tr(),
                                style: ButtonStyle(
                                  visualDensity: VisualDensity(vertical: -2),
                                ),
                              ),
                              if (data.isGatekept)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'publisherFollowRequiresApprovalHint'.tr(),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          );
                        }
                        if (status.isPending) {
                          return OutlinedButton.icon(
                            onPressed: subscribing.value ? null : unsubscribe,
                            icon: const Icon(Symbols.hourglass_top),
                            label: Text('publisherFollowPendingHint'.tr()),
                            style: ButtonStyle(
                              visualDensity: VisualDensity(vertical: -2),
                            ),
                          );
                        }
                        final isFollowing =
                            status.status == 'following' ||
                            status.status == 'subscribed' ||
                            status.subscription?.isActive == true;
                        final currentNotify =
                            status.subscription?.notify ?? true;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 8,
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: subscribing.value
                                    ? null
                                    : (isFollowing ? unsubscribe : subscribe),
                                icon: Icon(
                                  isFollowing
                                      ? Symbols.remove_circle
                                      : Symbols.add_circle,
                                ),
                                label: Text(
                                  isFollowing ? 'unsubscribe' : 'subscribe',
                                ).tr(),
                                style: ButtonStyle(
                                  visualDensity: VisualDensity(vertical: -2),
                                ),
                              ),
                            ),
                            if (isFollowing)
                              IconButton(
                                onPressed: () => toggleNotify(currentNotify),
                                icon: Icon(
                                  currentNotify
                                      ? Symbols.notifications
                                      : Symbols.notifications_off,
                                ),
                                tooltip: currentNotify
                                    ? 'notificationsEnabled'.tr()
                                    : 'notificationsDisabled'.tr(),
                              ),
                          ],
                        );
                      },
                      error: (_, _) => const SizedBox(),
                      loading: () => const SizedBox(
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    )
                    .padding(vertical: 12),
                // Bio section
                if (data.bio.isNotEmpty) ...[
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
                                      content: data.bio,
                                      linesMargin: EdgeInsets.zero,
                                    )
                                  : Text(
                                      _getFirstLine(data.bio),
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

class _PublisherBadgesWidget extends StatelessWidget {
  final SnPublisher data;
  final AsyncValue<List<SnAccountBadge>> badges;

  const _PublisherBadgesWidget({required this.data, required this.badges});

  @override
  Widget build(BuildContext context) {
    return (badges.value?.isNotEmpty ?? false)
        ? Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BadgeList(badges: badges.value!),
            ),
          )
        : const SizedBox.shrink();
  }
}

class _PublisherVerificationWidget extends StatelessWidget {
  final SnPublisher data;

  const _PublisherVerificationWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return (data.verification != null)
        ? Card(
            margin: EdgeInsets.zero,
            child: VerificationStatusCard(mark: data.verification!),
          )
        : const SizedBox.shrink();
  }
}

class _PublisherHeatmapWidget extends StatelessWidget {
  final AsyncValue<SnHeatmap?> heatmap;
  final bool forceDense;

  const _PublisherHeatmapWidget({
    required this.heatmap,
    this.forceDense = false,
  });

  @override
  Widget build(BuildContext context) {
    return heatmap.when(
      data: (data) => data != null
          ? ActivityHeatmapWidget(heatmap: data, forceDense: forceDense)
          : const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

@riverpod
Future<SnPublisher> publisher(Ref ref, String uname) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.sphere.getPublisher(uname);
}

@riverpod
Future<List<SnAccountBadge>> publisherBadges(Ref ref, String pubName) async {
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.type != 0 || pub.account == null) return [];
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get(
    "/passport/accounts/${pub.account!.name}/badges",
  );
  return List<SnAccountBadge>.from(
    resp.data.map((x) => SnAccountBadge.fromJson(x)),
  );
}

@riverpod
Future<SnPublisherSubscriptionStatus?> publisherSubscriptionStatus(
  Ref ref,
  String pubName,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    final resp = await client.dio.get(
      "/sphere/publishers/$pubName/subscription",
    );
    return SnPublisherSubscriptionStatus.fromJson(resp.data);
  } catch (err) {
    if (err is DioException) {
      if (err.response?.statusCode == 404) return null;
      rethrow;
    }
  }
  return null;
}

@riverpod
Future<SnPublisherSubscriptionStatus?> publisherFollowRequest(
  Ref ref,
  String pubName,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    return await client.sphere.getPublisherSubscriptionStatus(pubName);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@riverpod
Future<Map<String, bool>> publisherFeatures(Ref ref, String? uname) async {
  if (uname == null) return {};
  final client = ref.watch(solarNetworkClientProvider);
  final response = await client.dio.get('/sphere/publishers/$uname/features');
  return Map<String, bool>.from(response.data);
}

@riverpod
Future<SnHeatmap?> publisherHeatmap(Ref ref, String uname) async {
  final client = ref.watch(solarNetworkClientProvider);
  return await client.sphere.getPublisherHeatmap(uname);
}

@riverpod
Future<SnPublisherRatingOverview?> publisherRatingOverview(
  Ref ref,
  String pubName,
) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    return await client.sphere.getPublisherRatingOverview(pubName);
  } catch (err) {
    if (err is DioException && err.response?.statusCode == 404) {
      return null;
    }
    rethrow;
  }
}

@RoutePage()
class PublisherProfileScreen extends HookConsumerWidget {
  final String name;

  const PublisherProfileScreen({
    super.key,
    @PathParam("name") required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));

    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(
        leading: const AutoLeadingButton(),
        title: Text(publisher.value?.nick ?? '@$name'),
      ),
      body: PublisherProfileContent(name: name),
    );
  }
}

class PublisherProfileContent extends HookConsumerWidget {
  static const double _wideLayoutMinWidth = 900;

  final String name;
  final bool isEmbedded;

  const PublisherProfileContent({
    super.key,
    required this.name,
    this.isEmbedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));
    final badges = ref.watch(publisherBadgesProvider(name));
    final subStatus = ref.watch(publisherSubscriptionStatusProvider(name));
    final heatmap = ref.watch(publisherHeatmapProvider(name));
    final ratingOverview = ref.watch(publisherRatingOverviewProvider(name));

    final categoryTabController = useTabController(initialLength: 3);

    final queryState = useState(PostListQuery(pubName: name));

    final subscribing = useState(false);

    useEffect(() {
      final index = switch (queryState.value.type) {
        0 => 1,
        1 => 2,
        _ => 0,
      };
      categoryTabController.index = index;
      return null;
    }, []);

    Future<void> subscribe() async {
      final client = ref.watch(solarNetworkClientProvider);
      subscribing.value = true;
      try {
        await client.sphere.subscribeToPublisher(name);
        ref.invalidate(publisherSubscriptionStatusProvider(name));
        ref.invalidate(publisherFollowRequestProvider(name));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    Future<void> unsubscribe() async {
      final confirm = await showConfirmAlert(
        'publisherUnsubscribeConfirmHint'.tr(),
        'publisherUnsubscribeConfirm'.tr(),
        isDanger: true,
      );
      if (confirm != true) return;

      final client = ref.watch(solarNetworkClientProvider);
      subscribing.value = true;
      try {
        await client.sphere.unsubscribeFromPublisher(name);
        ref.invalidate(publisherSubscriptionStatusProvider(name));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    Future<void> toggleNotify(bool currentNotify) async {
      try {
        final client = ref.watch(solarNetworkClientProvider);
        await client.dio.patch(
          '/sphere/publishers/$name/subscribers/me/notify',
          data: {'notify': !currentNotify},
        );
        ref.invalidate(publisherSubscriptionStatusProvider(name));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return publisher.when(
      data: (data) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width;
            final useWideLayout =
                isWideScreen(context) && availableWidth >= _wideLayoutMinWidth;

            return useWideLayout
                ? Row(
                    spacing: 12,
                    children: [
                      Flexible(
                        flex: 4,
                        child: Card(
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          margin: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                          child: CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: _PinnedPostsPageView(
                                  pubName: name,
                                ).padding(horizontal: 12),
                              ),
                              SliverPostList(
                                maxWidth: double.infinity,
                                itemPadding: EdgeInsets.symmetric(vertical: 4),
                                query: queryState.value,
                                queryKey: 'publisher-$name',
                              ),
                              SliverGap(
                                MediaQuery.of(context).padding.bottom + 16,
                              ),
                            ],
                          ).clipRRect(topRight: 12),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              spacing: 12,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _PublisherBasisWidget(
                                  data: data,
                                  subStatus: subStatus,
                                  ratingOverview: ratingOverview,
                                  subscribing: subscribing,
                                  subscribe: subscribe,
                                  unsubscribe: unsubscribe,
                                  toggleNotify: toggleNotify,
                                ),
                                if (data.account?.badges.isNotEmpty ?? false)
                                  _PublisherBadgesWidget(
                                    data: data,
                                    badges: badges,
                                  ),
                                if (data.verification != null)
                                  _PublisherVerificationWidget(data: data),
                                _PublisherHeatmapWidget(
                                  heatmap: heatmap,
                                  forceDense: true,
                                ),
                                PostFilterWidget(
                                  categoryTabController: categoryTabController,
                                  initialQuery: queryState.value,
                                  onQueryChanged: (newQuery) =>
                                      queryState.value = newQuery,
                                ),
                              ],
                            ),
                          ),
                        ).padding(right: 12),
                      ),
                    ],
                  )
                : CustomScrollView(
                    slivers: [
                      const SliverGap(12),
                      SliverToBoxAdapter(
                        child: _PublisherBasisWidget(
                          data: data,
                          subStatus: subStatus,
                          ratingOverview: ratingOverview,
                          subscribing: subscribing,
                          subscribe: subscribe,
                          unsubscribe: unsubscribe,
                          toggleNotify: toggleNotify,
                        ).padding(horizontal: 12),
                      ),
                      const SliverGap(12),
                      if (data.account?.badges.isNotEmpty ?? false)
                        ...([
                          SliverToBoxAdapter(
                            child: _PublisherBadgesWidget(
                              data: data,
                              badges: badges,
                            ).padding(horizontal: 12),
                          ),
                          const SliverGap(12),
                        ]),
                      if (data.verification != null)
                        ...([
                          SliverToBoxAdapter(
                            child: _PublisherVerificationWidget(
                              data: data,
                            ).padding(horizontal: 12),
                          ),
                          const SliverGap(12),
                        ]),
                      SliverToBoxAdapter(
                        child: _PublisherHeatmapWidget(
                          heatmap: heatmap,
                        ).padding(horizontal: 12),
                      ),
                      const SliverGap(12),
                      SliverToBoxAdapter(
                        child: _PinnedPostsPageView(
                          pubName: name,
                        ).padding(horizontal: 12),
                      ),
                      const SliverGap(12),
                      SliverToBoxAdapter(
                        child: PostFilterWidget(
                          categoryTabController: categoryTabController,
                          initialQuery: queryState.value,
                          onQueryChanged: (newQuery) =>
                              queryState.value = newQuery,
                        ).padding(horizontal: 12),
                      ),
                      const SliverGap(12),
                      SliverPostList(
                        key: ValueKey(queryState.value),
                        query: queryState.value,
                        queryKey: 'publisher-$name',
                        maxWidth: double.infinity,
                        itemPadding: const EdgeInsets.symmetric(vertical: 4),
                      ),
                      SliverGap(MediaQuery.of(context).padding.bottom + 16),
                    ],
                  );
          },
        );
      },
      error: (error, stackTrace) => Center(child: Text(error.toString())),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
