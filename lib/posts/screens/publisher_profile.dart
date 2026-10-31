import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:island/shared/hooks/material_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/accounts/widgets/account/account_name.dart';
import 'package:island/accounts/widgets/account/badge.dart';
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/creators/screens/stickers/stickers.dart';
import 'package:island/creators/screens/survey/survey_list.dart';
import 'package:island/stickers/models/sticker.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:island/posts/widgets/fediverse_publisher_info.dart';
import 'package:island/posts/widgets/publisher_collection_info.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/attention_modal.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/shared/widgets/pagination_list.dart';
import 'package:island/shared/widgets/profile_header_app_bar.dart';
import 'package:island/shared/widgets/sliver_floating_tab_bar.dart';
import 'package:island/shared/widgets/response.dart';
import 'package:island/posts/activity_heatmap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/theme.dart';
import 'package:island/discovery/widgets/explore_card.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:island/shared/widgets/empty_state.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

part 'publisher_profile.g.dart';

/// Opens the profile of a publisher, local or remote.
///
/// Remote fediverse actors have no local handle, so they navigate to the
/// actor deep link; local publishers push the full publisher profile route.
void openPublisherProfile(BuildContext context, SnPublisher publisher) {
  if (publisher.isFediverse || publisher.name.isEmpty) {
    context.router.push(
      FediverseActorProfileRoute(
        id: publisher.id,
        fullHandle: publisher.activitypub?.fullHandle,
      ),
    );
    return;
  }
  context.router.push(PublisherProfileRoute(name: publisher.name));
}

/// The publisher's pinned posts, as an explore-style section card.
///
/// Mirrors a discovery section of the explore feed: a floating [ExploreCard]
/// holding a header band (icon, title, collapse affordance) and, under it, a
/// horizontally scrolling strip of post cards. Each post sits one tone deeper
/// than the section — `surfaceContainerLowest` inside `Low` — so the strip
/// reads as cards on a well rather than a card inside a card.
class PinnedPostsSection extends HookConsumerWidget {
  final String pubName;

  /// Height of one pinned post card in the strip.
  static const double _stripHeight = 280;

  /// Width of one pinned post card in the strip.
  static const double _cardWidth = 320;

  const PinnedPostsSection({super.key, required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = postListProvider(
      PostListQueryConfig(
        id: 'publisher-$pubName-pinned',
        initialFilter: PostListQuery(pubName: pubName, pinned: true),
      ),
    );
    final pinnedPosts = ref.watch(provider);
    final isExpanded = useState(true);
    final theme = Theme.of(context);

    return pinnedPosts.when(
      data: (data) {
        if (data.items.isEmpty) {
          return const SizedBox.shrink();
        }

        return ExploreCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The whole band toggles the section, so the strip can be put
              // away without hunting for the chevron.
              InkWell(
                onTap: () => isExpanded.value = !isExpanded.value,
                child:
                    Row(
                      children: [
                        Icon(
                          Symbols.push_pin,
                          size: 19,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const Gap(SolSpace.sm),
                        Expanded(
                          child: Text(
                            'pinnedPosts'.tr(),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Icon(
                          isExpanded.value
                              ? Symbols.expand_less
                              : Symbols.expand_more,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ).padding(
                      horizontal: SolSpace.lg,
                      top: SolSpace.md + 2,
                      bottom: SolSpace.sm,
                    ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: Visibility(
                  visible: isExpanded.value,
                  child:
                      SizedBox(
                        height: _stripHeight,
                        child: SuperListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.items.length,
                          separatorBuilder: (context, index) =>
                              const Gap(SolSpace.md),
                          padding: const EdgeInsets.symmetric(
                            vertical: SolSpace.xxs,
                          ),
                          itemBuilder: (context, index) => Container(
                            width: _cardWidth,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: SolRadius.cardRadius,
                            ),
                            child: SingleChildScrollView(
                              child: PostActionableItem(
                                item: data.items[index],
                                isCompact: true,
                                padding: const EdgeInsets.fromLTRB(
                                  SolSpace.lg,
                                  SolSpace.md + 2,
                                  SolSpace.lg,
                                  SolSpace.md,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ).padding(
                        left: SolSpace.md,
                        right: SolSpace.md,
                        bottom: SolSpace.md,
                      ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

/// Remote actors keep their header on the home instance, addressed by the
/// file reference url; local publishers store a cloud file.
Widget _publisherHeaderImage(BuildContext context, SnPublisher data) {
  final headerUrl = data.background?.storageUrl;
  if (data.isFediverse && headerUrl != null && headerUrl.isNotEmpty) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    return CachedNetworkImage(
      imageUrl: headerUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => placeholder,
      errorWidget: (context, url, error) => placeholder,
    );
  }
  return CloudImageWidget(file: data.background, fit: BoxFit.cover);
}

/// Remote actors keep their avatar on the home instance, addressed by the file
/// reference url; local publishers store a cloud file.
Widget _publisherAvatarImage(
  BuildContext context,
  SnPublisher data, {
  double radius = 32,
  double? borderRadius,
}) {
  final avatarUrl = data.picture?.storageUrl;
  if (data.isFediverse && avatarUrl != null && avatarUrl.isNotEmpty) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      backgroundImage: CachedNetworkImageProvider(avatarUrl),
    );
  }
  return ProfilePictureWidget(
    file: data.picture,
    fallbackName: data.nick,
    radius: radius,
    borderRadius: borderRadius,
  );
}

/// Remote actor bios are HTML summaries, local publisher bios are markdown.
String _publisherBio(SnPublisher data) {
  final bio = data.bio;
  if (bio.isEmpty) return '';
  if (data.isFediverse && bio.contains('<')) {
    return html2md.convert(bio);
  }
  return bio;
}

/// Username shown inside the handle chip.
///
/// Mirrored remote actors may carry a fully qualified `user@domain` handle in
/// `username`, so the local part is the only thing the chip renders.
String _publisherUsername(SnPublisher data) {
  final actorUsername = data.activitypub?.username;
  final raw = actorUsername?.isNotEmpty == true ? actorUsername! : data.name;
  return raw.split('@').first;
}

/// Handle copied by the handle chip: `@user` locally, `@user@domain` remotely.
String _publisherFullHandle(SnPublisher data) {
  final username = _publisherUsername(data);
  final domain = data.isFediverse ? data.domain : null;
  return domain == null ? '@$username' : '@$username@$domain';
}

/// The local account owning this publisher, or null when it has none.
///
/// A publisher handle is not an account name. An individual publisher is
/// created with a handle of its own — uniqueness is only checked against other
/// publishers — and organization publishers and mirrored remote actors have no
/// owning account at all. Every account-keyed lookup (the account profile
/// route, the account-status endpoint) has to resolve through this, never
/// through [SnPublisher.name].
String? _publisherAccountName(SnPublisher data) {
  final name = data.account?.name;
  return (name == null || name.isEmpty) ? null : name;
}

class _PublisherBasisWidget extends HookWidget {
  final SnPublisher data;
  final AsyncValue<SnPublisherSubscriptionStatus?> subStatus;
  final AsyncValue<SnPublisherRatingOverview?> ratingOverview;
  final ValueNotifier<bool> subscribing;
  final VoidCallback subscribe;
  final VoidCallback unsubscribe;
  final void Function(bool currentNotify) toggleNotify;

  /// Whether the in-card header image (and overlapping avatar) is drawn.
  /// Narrow layouts pin the header to the app bar instead.
  final bool showHeaderImage;

  const _PublisherBasisWidget({
    required this.data,
    required this.subStatus,
    required this.ratingOverview,
    required this.subscribing,
    required this.subscribe,
    required this.unsubscribe,
    required this.toggleNotify,
    this.showHeaderImage = true,
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

  /// Origin row of a remote actor: the instance mirroring it.
  ///
  /// Remote actors have no account on this server, so the account link a local
  /// publisher shows would point at a name that never resolves.
  Widget _instanceChip(BuildContext context, ThemeData theme) {
    final domain = data.domain;
    if (domain == null) return const SizedBox.shrink();

    return InkWell(
      borderRadius: BorderRadius.circular(SolRadius.sm),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.md,
          vertical: SolSpace.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(SolRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SolSpace.sm,
          children: [
            Icon(
              Symbols.hub,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
              fill: 1,
            ),
            Flexible(
              child: Text(
                'publisherBelongsToInstance'.tr(args: [domain]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () => launchUrlString('https://$domain'),
    );
  }

  /// Origin row of a local publisher: the account owning it.
  ///
  /// [accountName] is the owning account's handle, which is not the publisher
  /// handle — see [_publisherAccountName].
  Widget _accountChip(
    BuildContext context,
    ThemeData theme,
    String accountName,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(SolRadius.sm),
      child: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(
          horizontal: SolSpace.md,
          vertical: SolSpace.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(SolRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SolSpace.sm,
          children: [
            Icon(
              Symbols.person,
              size: 18,
              color: theme.colorScheme.onSecondaryContainer,
              fill: 1,
            ),
            Flexible(
              child: Text(
                'publisherBelongsTo'.tr(args: ['@$accountName']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        context.router.push(AccountProfileRoute(name: accountName));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBioExpanded = useState(false);
    final theme = Theme.of(context);
    // Organization publishers and mirrored remote actors have no owning
    // account, so the account row and status row are skipped instead of
    // falling back to the publisher handle (which resolves to nothing).
    final accountName = _publisherAccountName(data);

    Widget avatarWithBorder() {
      final isCircle = data.type == 0 || data.isFediverse;
      return Container(
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle
              ? null
              : const BorderRadius.all(Radius.circular(SolRadius.sm)),
          border: Border.all(
            color: theme.colorScheme.surfaceContainerLow,
            width: 3,
          ),
        ),
        child: _publisherAvatarImage(
          context,
          data,
          radius: 32,
          borderRadius: isCircle ? null : SolRadius.sm,
        ),
      );
    }

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
                  child: _publisherHeaderImage(context, data),
                ),
              ),
              Positioned(
                bottom: -24,
                left: SolSpace.lg,
                child: avatarWithBorder(),
              ),
            ],
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeaderImage) const Gap(SolSpace.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: SolSpace.md,
              children: [
                if (!showHeaderImage) avatarWithBorder(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                          message: 'publisherGatekeptHintShort'
                                              .tr(),
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
                                    data.effectiveName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                          if (data.activitypub?.isBot ?? false)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'BOT',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                              ),
                            ),
                          if (data.verification != null)
                            VerificationMark(
                              mark: data.verification!,
                              onTap: () => showVerificationMarkSheet(
                                context,
                                data.verification!,
                              ),
                            ),
                          // Only the username: the instance is spelled out by
                          // the origin chip below, and a full remote handle
                          // overflows this row on narrow layouts.
                          Flexible(
                            child: HandleChip(
                              handle: _publisherUsername(data),
                              copyText: _publisherFullHandle(data),
                              isRemote: data.isFediverse,
                              allowCopy: true,
                              maxLines: 1,
                            ),
                          ),
                          // Rating grade indicator
                          ratingOverview.when(
                            data: (overview) {
                              if (overview == null) {
                                return const SizedBox.shrink();
                              }
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
                                      'S++' =>
                                        theme.colorScheme.tertiaryContainer,
                                      'S+' =>
                                        theme.colorScheme.tertiaryContainer,
                                      'S' => theme.colorScheme.primaryContainer,
                                      'A++' =>
                                        theme.colorScheme.primaryContainer,
                                      'A+' =>
                                        theme.colorScheme.primaryContainer,
                                      'A' => theme.colorScheme.primaryContainer,
                                      'A-' =>
                                        theme.colorScheme.primaryContainer,
                                      'B+' =>
                                        theme.colorScheme.secondaryContainer,
                                      'B' =>
                                        theme.colorScheme.secondaryContainer,
                                      'C' =>
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                      'D' => theme.colorScheme.errorContainer,
                                      _ =>
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    },
                                    borderRadius: BorderRadius.circular(
                                      SolRadius.sm,
                                    ),
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
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
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
                        ],
                      ),

                      // A remote actor has no account-status row under the
                      // chip, so the local rhythm (8/4 around the chip, then a
                      // Gap) would leave the follow button drifting away from
                      // the name. An organization publisher has neither an
                      // instance nor an owning account, so it draws no origin
                      // row and no padding at all.
                      if (data.isFediverse)
                        Padding(
                          padding: const .only(top: SolSpace.xs),
                          child: _instanceChip(context, theme),
                        )
                      else if (accountName != null) ...[
                        Padding(
                          padding: const .only(
                            top: SolSpace.sm,
                            bottom: SolSpace.xs,
                          ),
                          child: _accountChip(context, theme, accountName),
                        ),
                        const Gap(SolSpace.xs),
                        AccountStatusWidget(
                          uname: accountName,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (data.realm != null) ...[
              Row(
                children: [
                  Flexible(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(SolRadius.sm),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: SolSpace.md,
                          vertical: SolSpace.sm,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer
                              .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(SolRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: SolSpace.sm,
                          children: [
                            Icon(
                              Symbols.public,
                              size: 18,
                              color: theme.colorScheme.onTertiaryContainer,
                              fill: 1,
                            ),
                            Flexible(
                              child: Text(
                                'publisherBelongsToRealm'.tr(
                                  args: [data.realm!.name],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
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
                    ).padding(top: SolSpace.sm, bottom: SolSpace.xs),
                  ),
                ],
              ),
            ],
            if (!data.isFediverse) const Gap(SolSpace.xs),
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
                            label: Text(
                              data.isFediverse ? 'follow' : 'subscribe',
                            ).tr(),
                            style: ButtonStyle(
                              visualDensity: VisualDensity(vertical: -2),
                            ),
                          ),
                          if (!data.isFediverse && data.isGatekept)
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
                    final currentNotify = status.subscription?.notify ?? true;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: SolSpace.sm,
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
                              data.isFediverse
                                  ? (isFollowing ? 'unfollow' : 'follow')
                                  : (isFollowing ? 'unsubscribe' : 'subscribe'),
                            ).tr(),
                            style: ButtonStyle(
                              visualDensity: VisualDensity(vertical: -2),
                            ),
                          ),
                        ),
                        if (isFollowing && !data.isFediverse)
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
                .padding(
                  vertical: data.isFediverse ? SolSpace.xs : SolSpace.md,
                ),
            // Bio section
            if (_publisherBio(data).isNotEmpty) ...[
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
                                  content: _publisherBio(data),
                                  linesMargin: EdgeInsets.zero,
                                )
                              : Text(
                                  _getFirstLine(_publisherBio(data)),
                                  key: const ValueKey('collapsed'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
        ).padding(all: SolSpace.lg),
      ],
    );

    return ExploreCard(child: content);
  }
}

class _PublisherBadgesWidget extends StatelessWidget {
  final SnPublisher data;
  final AsyncValue<List<SnAccountBadge>> badges;

  const _PublisherBadgesWidget({required this.data, required this.badges});

  @override
  Widget build(BuildContext context) {
    return (badges.value?.isNotEmpty ?? false)
        ? ExploreCard(
            padding: const EdgeInsets.all(SolSpace.card),
            child: BadgeList(badges: badges.value!),
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

enum _PublisherPublicationTab { posts, collections, stickers, surveys }

@riverpod
Future<SnPublisher> publisher(Ref ref, String uname) async {
  final client = ref.watch(solarNetworkClientProvider);
  try {
    return await client.sphere.getPublisher(uname);
  } catch (err) {
    // Remote fediverse actors have no local publisher handle, so they are only
    // reachable through the actor endpoints.
    if (err is DioException && err.response?.statusCode == 404) {
      return await client.sphere.getActor(uname);
    }
    rethrow;
  }
}

@riverpod
Future<List<SnAccountBadge>> publisherBadges(Ref ref, String pubName) async {
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.type != 0 || pub.account == null) return [];
  final client = ref.watch(solarNetworkClientProvider);
  final resp = await client.dio.get(
    "/stargate/accounts/${pub.account!.name}/badges",
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
  // Subscription state only exists for local publishers. The screen reaches
  // this provider by name before a remote actor payload resolves, so the actor
  // check has to happen here rather than at the call site: otherwise opening an
  // actor profile fires a request that can only 404.
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.isFediverse) return null;
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
  // Heatmaps are accumulated from local publishing activity; a remote actor
  // has none, so the request is skipped instead of 404ing.
  final pub = await ref.watch(publisherProvider(uname).future);
  if (pub.isFediverse) return null;
  final client = ref.watch(solarNetworkClientProvider);
  return await client.sphere.getPublisherHeatmap(uname);
}

@riverpod
Future<SnPublisherRatingOverview?> publisherRatingOverview(
  Ref ref,
  String pubName,
) async {
  // Ratings are a local-publisher concept and remote actors expose no rating
  // endpoints, so the actor check gates the request itself.
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.isFediverse) return null;
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

final publisherCollectionsProvider = FutureProvider.autoDispose
    .family<List<SnPostCollection>, String>((ref, pubName) async {
      final client = ref.watch(solarNetworkClientProvider);
      return client.sphere.listPublisherCollections(pubName);
    });

class _PublisherTabBar extends StatelessWidget {
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Color? indicatorColor;

  const _PublisherTabBar({
    this.labelColor,
    this.unselectedLabelColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildLabel(String label, IconData icon) {
      return Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: SolSpace.xs,
          children: [
            Icon(icon, size: 18),
            const Gap(SolSpace.xs),
            Text(label.tr()),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Wide panes have room to divide the strip evenly, which makes each
        // tab a predictable target. On a phone the four icon+label tabs do not
        // fit that way, so they stay scrollable rather than clipping.
        final splitEvenly = constraints.maxWidth >= 380;
        return Material(
          color: Colors.transparent,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.only(
              left: SolSpace.sm,
              right: SolSpace.sm,
              top: SolSpace.sm,
              bottom: SolSpace.xs,
            ),
            child: TabBar(
              isScrollable: !splitEvenly,
              tabAlignment: splitEvenly
                  ? TabAlignment.fill
                  : TabAlignment.center,
              padding: const EdgeInsets.symmetric(horizontal: SolSpace.sm),
              indicator: BoxDecoration(
                color: indicatorColor ?? theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(SolRadius.lg),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerHeight: 0,
              labelColor: labelColor ?? theme.colorScheme.onSecondaryContainer,
              unselectedLabelColor:
                  unselectedLabelColor ?? theme.colorScheme.onSurfaceVariant,
              splashBorderRadius: BorderRadius.circular(SolRadius.lg),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                buildLabel('posts', Symbols.notes),
                buildLabel('collections', Symbols.collections),
                buildLabel('stickers', Symbols.imagesmode),
                buildLabel('surveys', Symbols.quiz),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PublisherTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color backgroundColor;

  /// TabBar (46) plus the bar's own vertical padding: `SolSpace.sm` above,
  /// `SolSpace.xs` below.
  static const double _height = kFloatingTabBarHeight;

  _PublisherTabBarHeaderDelegate({
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
      elevation: overlapsContent ? 1 : 0,
      child: SizedBox(height: _height, child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _PublisherTabBarHeaderDelegate oldDelegate) {
    return child != oldDelegate.child ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}

class _PublisherPostsTab extends HookWidget {
  final String pubName;

  const _PublisherPostsTab({required this.pubName});

  @override
  Widget build(BuildContext context) {
    final categoryTabController = useMaterialTabController(initialLength: 3);
    final queryState = useState(PostListQuery(pubName: pubName, type: 0));

    useEffect(() {
      void onTabChanged() {
        if (categoryTabController.indexIsChanging) return;
        queryState.value = queryState.value.copyWith(
          type: switch (categoryTabController.index) {
            0 => 0,
            1 => 1,
            2 => 2,
            _ => 0,
          },
        );
      }

      categoryTabController.addListener(onTabChanged);
      return () => categoryTabController.removeListener(onTabChanged);
    }, [categoryTabController]);

    final queryId = switch (queryState.value.type) {
      0 => 'posts',
      1 => 'articles',
      2 => 'blogs',
      final value => 'type-$value',
    };

    final gutter = explorePageGutter(context);

    return CustomScrollView(
      slivers: [
        const SliverGap(kExploreCardGap),
        SliverPadding(
          padding: gutter,
          sliver: SliverToBoxAdapter(
            child: PinnedPostsSection(pubName: pubName),
          ),
        ),
        // The strip and the filter card are two separate floating cards, so
        // they need the same one-card gap every other card in the feed uses.
        const SliverGap(kExploreCardGap),
        SliverPadding(
          padding: gutter,
          sliver: SliverToBoxAdapter(
            child: PostFilterWidget(
              categoryTabController: categoryTabController,
              initialQuery: queryState.value,
              onQueryChanged: (newQuery) => queryState.value = newQuery,
              showSearchAtTop: true,
            ),
          ),
        ),
        const SliverGap(kExploreCardGap),
        SliverPadding(
          padding: gutter,
          sliver: SliverPostList(
            key: ValueKey('publisher-$pubName-$queryId'),
            query: queryState.value,
            queryKey: 'publisher-$pubName-$queryId',
            maxWidth: double.infinity,
          ),
        ),
        SliverGap(MediaQuery.paddingOf(context).bottom + kExploreCardGap),
      ],
    );
  }
}

class _PublisherCollectionsTab extends HookConsumerWidget {
  final String pubName;

  const _PublisherCollectionsTab({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(publisherCollectionsProvider(pubName));

    return RefreshIndicator(
      onRefresh: () =>
          ref.refresh(publisherCollectionsProvider(pubName).future),
      child: collections.when(
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              padding: explorePageGutter(
                context,
              ).copyWith(top: kExploreCardGap),
              children: [
                SizedBox(
                  height: 240,
                  child: EmptyState(
                    icon: Symbols.collections,
                    title: 'dataEmpty'.tr(),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: explorePageGutter(context).copyWith(
              top: kExploreCardGap,
              bottom: MediaQuery.paddingOf(context).bottom + kExploreCardGap,
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => const Gap(kExploreCardGap),
            itemBuilder: (context, index) {
              final collection = items[index];
              return _PublisherCollectionCard(
                pubName: pubName,
                collection: collection,
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ResponseErrorWidget(
          error: error,
          onRetry: () => ref.invalidate(publisherCollectionsProvider(pubName)),
        ),
      ),
    );
  }
}

class _PublisherCollectionCard extends StatelessWidget {
  final String pubName;
  final SnPostCollection collection;

  const _PublisherCollectionCard({
    required this.pubName,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = collection.name?.isNotEmpty == true
        ? collection.name!
        : collection.slug;

    return ExploreCard(
      child: InkWell(
        borderRadius: SolRadius.cardRadius,
        onTap: () {
          showAttentionModal(
            id: 'publisher-collection:$pubName:${collection.slug}',
            replaceIfExists: true,
            barrierDismissible: true,
            builder: (_, dismiss) => PublisherCollectionDetailSheet(
              publisherName: pubName,
              collection: collection,
              onDismiss: dismiss,
            ),
          );
        },
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (collection.background != null)
                CloudFileWidget(item: collection.background!, fit: BoxFit.cover)
              else
                Container(color: theme.colorScheme.surfaceContainerHighest),
              Positioned(
                left: SolSpace.lg,
                right: SolSpace.lg,
                bottom: SolSpace.lg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ProfilePictureWidget(
                      file: collection.icon,
                      radius: 24,
                      fallbackIcon: Symbols.collections,
                    ),
                    const Gap(SolSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              shadows: const [
                                Shadow(
                                  color: Colors.black54,
                                  blurRadius: 10,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          if (collection.description?.isNotEmpty ?? false)
                            Text(
                              collection.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 10,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Gap(SolSpace.sm),
                    const Icon(Symbols.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PublisherStickerPacksTab extends HookConsumerWidget {
  final String pubName;

  const _PublisherStickerPacksTab({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationWidget<SnStickerPack>(
      provider: stickerPacksProvider(pubName),
      notifier: stickerPacksProvider(pubName).notifier,
      contentBuilder: (items, footer) {
        if (items.isEmpty) {
          return ListView(
            padding: explorePageGutter(context).copyWith(top: kExploreCardGap),
            children: [
              SizedBox(
                height: 240,
                child: EmptyState(
                  icon: Symbols.imagesmode,
                  title: 'dataEmpty'.tr(),
                ),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: explorePageGutter(context).copyWith(
            top: kExploreCardGap,
            bottom: MediaQuery.paddingOf(context).bottom + kExploreCardGap,
          ),
          itemCount: items.length + 1,
          separatorBuilder: (_, _) => const Gap(kExploreCardGap),
          itemBuilder: (context, index) {
            if (index == items.length) return footer;
            final pack = items[index];
            return ExploreCard(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SolSpace.lg,
                  vertical: SolSpace.sm,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: SolRadius.cardRadius,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(SolRadius.sm),
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: pack.icon != null
                        ? CloudImageWidget(file: pack.icon!, fit: BoxFit.cover)
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                            ),
                            child: const Icon(Symbols.imagesmode),
                          ),
                  ),
                ),
                title: Text(pack.name),
                subtitle: pack.description.isNotEmpty
                    ? Text(
                        pack.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : null,
                trailing: const Icon(Symbols.chevron_right),
                onTap: () {
                  context.router.navigate(
                    StickerMarketplacePackDetailRoute(id: pack.id),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class _PublisherSurveysTab extends HookConsumerWidget {
  final String pubName;

  const _PublisherSurveysTab({required this.pubName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaginationWidget<SnSurveyWithStats>(
      provider: surveyListNotifierProvider(pubName),
      notifier: surveyListNotifierProvider(pubName).notifier,
      contentBuilder: (items, footer) {
        if (items.isEmpty) {
          return ListView(
            padding: explorePageGutter(context).copyWith(top: kExploreCardGap),
            children: [
              SizedBox(
                height: 240,
                child: EmptyState(icon: Symbols.quiz, title: 'dataEmpty'.tr()),
              ),
            ],
          );
        }

        return ListView.separated(
          padding: explorePageGutter(context).copyWith(
            top: kExploreCardGap,
            bottom: MediaQuery.paddingOf(context).bottom + kExploreCardGap,
          ),
          itemCount: items.length + 1,
          separatorBuilder: (_, _) => const Gap(kExploreCardGap),
          itemBuilder: (context, index) {
            if (index == items.length) return footer;
            final survey = items[index];
            return ExploreCard(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: SolSpace.lg,
                  vertical: SolSpace.sm,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: SolRadius.cardRadius,
                ),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(SolRadius.sm),
                  ),
                  child: Icon(
                    Symbols.quiz,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                title: Text(survey.title ?? 'Untitled survey'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (survey.description?.isNotEmpty ?? false)
                      Text(
                        survey.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    Text(
                      '${survey.questions.length} question${survey.questions.length == 1 ? '' : 's'}',
                    ),
                  ],
                ),
                trailing: const Icon(Symbols.chevron_right),
                onTap: () =>
                    context.router.push(SurveySubmitRoute(surveyId: survey.id)),
              ),
            );
          },
        );
      },
    );
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
    final narrow =
        !isWideScreen(context) || MediaQuery.sizeOf(context).width < 900;

    return AppScaffold(
      isNoBackground: false,
      appBar: narrow
          ? null
          : AppBar(
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

  const PublisherProfileContent({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));
    final publisherData = publisher.value;
    // Remote actors have no local publisher handle, so every request that is
    // keyed by publisher name has to go through the actor id instead.
    final isFediverse = publisherData?.isFediverse ?? false;
    final actorId = publisherData?.id ?? name;

    final fediverseRelationship = isFediverse
        ? ref.watch(fediverseActorRelationshipProvider(actorId))
        : const AsyncValue<FediverseActorRelationship?>.data(null);
    final subStatus = isFediverse
        ? fediverseRelationship.whenData(
            (relationship) => SnPublisherSubscriptionStatus(
              status: relationship == null
                  ? 'none'
                  : relationship.isFollowing
                  ? 'following'
                  : relationship.isPending
                  ? 'pending'
                  : 'none',
              isActive: relationship?.isFollowing ?? false,
              isPending: relationship?.isPending ?? false,
              requiresApproval: true,
            ),
          )
        : ref.watch(publisherSubscriptionStatusProvider(name));
    final badges = ref.watch(publisherBadgesProvider(name));
    // Rating, heatmap and subscription status are local-publisher endpoints:
    // each provider resolves the publisher first and resolves to `null` for a
    // remote actor without a round trip. Guarding this watch with `isFediverse`
    // would be too late — while the actor payload is still loading the name is
    // all this screen has, and the request would already be gone.
    final heatmap = ref.watch(publisherHeatmapProvider(name));
    final ratingOverview = ref.watch(publisherRatingOverviewProvider(name));
    final serverUrl = ref.watch(serverUrlProvider);

    final subscribing = useState(false);
    final collapsed = useState(false);
    final headerTint = useState<Color?>(null);

    Future<void> subscribe() async {
      final client = ref.watch(solarNetworkClientProvider);
      subscribing.value = true;
      try {
        if (isFediverse) {
          await client.sphere.followActor(actorId);
          ref.invalidate(fediverseActorRelationshipProvider(actorId));
        } else {
          await client.sphere.subscribeToPublisher(name);
          ref.invalidate(publisherSubscriptionStatusProvider(name));
          ref.invalidate(publisherFollowRequestProvider(name));
        }
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
        if (isFediverse) {
          await client.sphere.unfollowActor(actorId);
          ref.invalidate(fediverseActorRelationshipProvider(actorId));
        } else {
          await client.sphere.unsubscribeFromPublisher(name);
          ref.invalidate(publisherSubscriptionStatusProvider(name));
        }
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    Future<void> toggleNotify(bool currentNotify) async {
      if (isFediverse) return;
      try {
        final client = ref.watch(solarNetworkClientProvider);
        await client.sphere.updateSubscriptionNotify(
          name,
          notify: !currentNotify,
        );
        ref.invalidate(publisherSubscriptionStatusProvider(name));
      } catch (err) {
        showErrorAlert(err);
      }
    }

    return DefaultTabController(
      length: _PublisherPublicationTab.values.length,
      child: publisher.when(
        data: (data) {
          if (data.isFediverse) {
            return _buildFediverseLayout(
              context,
              data,
              subStatus,
              subscribing,
              subscribe,
              unsubscribe,
              collapsed,
              headerTint,
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width;
              final useWideLayout =
                  isWideScreen(context) &&
                  availableWidth >= _wideLayoutMinWidth;

              final publicationViews = [
                _PublisherPostsTab(pubName: name),
                _PublisherCollectionsTab(pubName: name),
                _PublisherStickerPacksTab(pubName: name),
                _PublisherSurveysTab(pubName: name),
              ];

              final tabBar = const _PublisherTabBar();

              if (!useWideLayout) {
                final headerColors = profileHeaderColors(
                  Theme.of(context),
                  headerTint.value,
                );
                // NestedScrollView lets the tall profile header scroll away on
                // short/narrow viewports instead of overflowing the Column.
                final headerAppBar = ProfileHeaderAppBar(
                  title: data.effectiveName,
                  background: _publisherHeaderImage(context, data),
                  samplingProvider: data.background != null
                      ? CloudImageWidget.provider(
                          file: data.background!,
                          serverUrl: serverUrl,
                        )
                      : null,
                  leading: const AutoLeadingButton(),
                  collapsed: collapsed,
                  tintNotifier: headerTint,
                );
                final scrollView = NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    headerAppBar,
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Gap(kExploreCardGap),
                          Padding(
                            padding: explorePageGutter(context),
                            child: _PublisherBasisWidget(
                              data: data,
                              subStatus: subStatus,
                              ratingOverview: ratingOverview,
                              subscribing: subscribing,
                              subscribe: subscribe,
                              unsubscribe: unsubscribe,
                              toggleNotify: toggleNotify,
                              showHeaderImage: false,
                            ),
                          ),
                          const Gap(kExploreCardGap),
                          if (data.account?.badges.isNotEmpty ?? false) ...[
                            Padding(
                              padding: explorePageGutter(context),
                              child: _PublisherBadgesWidget(
                                data: data,
                                badges: badges,
                              ),
                            ),
                            const Gap(kExploreCardGap),
                          ],
                          Padding(
                            padding: explorePageGutter(context),
                            child: _PublisherHeatmapWidget(heatmap: heatmap),
                          ),
                          const Gap(kExploreCardGap),
                        ],
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      // The tab bar takes the header color only once the header
                      // is fully scrolled and the bar is snapped under the app
                      // bar (`innerBoxIsScrolled`) — not while it is still
                      // travelling up through the profile content.
                      delegate: _PublisherTabBarHeaderDelegate(
                        child: _PublisherTabBar(
                          labelColor: innerBoxIsScrolled
                              ? headerColors.onPrimary
                              : null,
                          unselectedLabelColor: innerBoxIsScrolled
                              ? headerColors.onPrimary.withOpacity(0.7)
                              : null,
                          indicatorColor: innerBoxIsScrolled
                              ? headerColors.onPrimary.withOpacity(0.22)
                              : null,
                        ),
                        backgroundColor: innerBoxIsScrolled
                            ? headerColors.primary
                            : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                  body: TabBarView(children: publicationViews),
                );

                return ProfileHeaderScrollListener(
                  collapsed: collapsed,
                  threshold: profileHeaderCollapseThreshold(context, 220),
                  child: scrollView,
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
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface,
                            child: tabBar,
                          ),
                        ],
                        body: TabBarView(children: publicationViews),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        0,
                        kExploreCardGap,
                        SolSpace.md,
                        kExploreCardGap,
                      ),
                      child: Column(
                        spacing: kExploreCardGap,
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
                            _PublisherBadgesWidget(data: data, badges: badges),
                          _PublisherHeatmapWidget(
                            heatmap: heatmap,
                            forceDense: true,
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

  /// Layout for remote fediverse actors: same basis card as a local publisher,
  /// fediverse-only info cards, and the actor posts timeline instead of the
  /// local publishing tabs.
  Widget _buildFediverseLayout(
    BuildContext context,
    SnPublisher data,
    AsyncValue<SnPublisherSubscriptionStatus?> subStatus,
    ValueNotifier<bool> subscribing,
    Future<void> Function() subscribe,
    Future<void> Function() unsubscribe,
    ValueNotifier<bool> collapsed,
    ValueNotifier<Color?> headerTint,
  ) {
    final actorId = data.id;
    final cards = FediversePublisherInfoCards(data: data);
    final availableWidth = MediaQuery.of(context).size.width;
    final useWideLayout =
        isWideScreen(context) && availableWidth >= _wideLayoutMinWidth;
    final bottomInset = MediaQuery.paddingOf(context).bottom + kExploreCardGap;
    final showHeaderImage = useWideLayout;
    final basis = _PublisherBasisWidget(
      data: data,
      subStatus: subStatus,
      ratingOverview: const AsyncValue<SnPublisherRatingOverview?>.data(null),
      subscribing: subscribing,
      subscribe: subscribe,
      unsubscribe: unsubscribe,
      toggleNotify: (bool current) {},
      showHeaderImage: showHeaderImage,
    );

    if (!useWideLayout) {
      final headerAppBar = ProfileHeaderAppBar(
        title: data.effectiveName,
        background: _publisherHeaderImage(context, data),
        samplingProvider: (data.background?.storageUrl?.isNotEmpty ?? false)
            ? CachedNetworkImageProvider(data.background!.storageUrl!)
            : null,
        leading: const AutoLeadingButton(),
        collapsed: collapsed,
        tintNotifier: headerTint,
      );
      final scrollView = CustomScrollView(
        slivers: [
          headerAppBar,
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(kExploreCardGap),
                Padding(padding: explorePageGutter(context), child: basis),
                const Gap(kExploreCardGap),
                Padding(padding: explorePageGutter(context), child: cards),
                const Gap(kExploreCardGap),
              ],
            ),
          ),
          SliverPadding(
            padding: explorePageGutter(context),
            sliver: FediverseActorPostsWidget(actorId: actorId),
          ),
          SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
        ],
      );

      return ProfileHeaderScrollListener(
        collapsed: collapsed,
        threshold: profileHeaderCollapseThreshold(context, 220),
        child: scrollView,
      );
    }

    return Row(
      spacing: SolSpace.sm,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.only(left: SolSpace.md, top: kExploreCardGap),
            child: CustomScrollView(
              slivers: [
                FediverseActorPostsWidget(actorId: actorId),
                SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
              ],
            ),
          ),
        ),
        Flexible(
          flex: 3,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              0,
              kExploreCardGap,
              SolSpace.md,
              kExploreCardGap,
            ),
            child: Column(
              spacing: kExploreCardGap,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [basis, cards],
            ),
          ),
        ),
      ],
    );
  }
}
