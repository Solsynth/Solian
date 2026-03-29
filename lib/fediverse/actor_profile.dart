import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FediverseActorRelationship {
  final String actorId;
  final String actorUsername;
  final String? actorInstance;
  final String actorHandle;
  final bool isFollowing;
  final bool isFollowedBy;
  final bool isPending;

  FediverseActorRelationship({
    required this.actorId,
    required this.actorUsername,
    this.actorInstance,
    required this.actorHandle,
    required this.isFollowing,
    required this.isFollowedBy,
    required this.isPending,
  });

  factory FediverseActorRelationship.fromJson(Map<String, dynamic> json) =>
      FediverseActorRelationship(
        actorId: json['actor_id'] as String,
        actorUsername: json['actor_username'] as String,
        actorInstance: json['actor_instance'] as String?,
        actorHandle: json['actor_handle'] as String,
        isFollowing: json['is_following'] as bool? ?? false,
        isFollowedBy: json['is_followed_by'] as bool? ?? false,
        isPending: json['is_pending'] as bool? ?? false,
      );
}

final fediverseActorProvider =
    FutureProvider.family<SnActivityPubActor, String>((ref, idOrHandle) async {
      final apiClient = ref.watch(apiClientProvider);
      final isHandle = idOrHandle.contains('@');

      try {
        final resp = await apiClient.get(
          '/sphere/fediverse/actors/$idOrHandle',
        );
        return SnActivityPubActor.fromJson(resp.data);
      } catch (err) {
        if (err is DioException &&
            err.response?.statusCode == 404 &&
            !isHandle) {
          rethrow;
        }
        rethrow;
      }
    });

final fediverseActorRelationshipProvider =
    FutureProvider.family<FediverseActorRelationship?, String>((
      ref,
      actorId,
    ) async {
      final apiClient = ref.watch(apiClientProvider);
      try {
        final resp = await apiClient.get(
          "/sphere/fediverse/actors/$actorId/relationship",
        );
        return FediverseActorRelationship.fromJson(resp.data);
      } catch (err) {
        if (err is DioException) {
          if (err.response?.statusCode == 404) return null;
          rethrow;
        }
      }
      return null;
    });

final fediverseActorPostsProvider = FutureProvider.family<List<SnPost>, String>(
  (ref, actorId) async {
    final apiClient = ref.watch(apiClientProvider);
    final resp = await apiClient.get(
      "/sphere/fediverse/actors/$actorId/posts",
      queryParameters: {'take': 20, 'offset': 0},
    );
    final data = resp.data;
    if (data is List) {
      return data.map((json) => SnPost.fromJson(json)).toList();
    }
    return [];
  },
);

class _ActorBasisWidget extends HookWidget {
  final SnActivityPubActor data;
  final AsyncValue<FediverseActorRelationship?> relationship;
  final ValueNotifier<bool> acting;
  final VoidCallback follow;
  final VoidCallback unfollow;

  const _ActorBasisWidget({
    required this.data,
    required this.relationship,
    required this.acting,
    required this.follow,
    required this.unfollow,
  });

  @override
  Widget build(BuildContext context) {
    final isBioExpanded = useState(false);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: data.avatarUrl != null
                      ? CachedNetworkImageProvider(data.avatarUrl!)
                      : null,
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  child: data.avatarUrl == null
                      ? Icon(
                          Symbols.person,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          Flexible(
                            child: Text(
                              data.displayName ?? data.username,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (data.isBot)
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
                        ],
                      ),
                      Row(
                        spacing: 6,
                        children: [
                          Icon(
                            Symbols.alternate_email,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          Text(
                            data.fullHandle,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const Gap(4),
                      Row(
                        spacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 4,
                              children: [
                                Icon(
                                  Symbols.public,
                                  size: 12,
                                  color: theme.colorScheme.onSecondaryContainer,
                                ),
                                Text(
                                  data.instance.name ?? data.instance.domain,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (data.instance.software != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                data.instance.software!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Gap(12),
                      relationship.when(
                        data: (rel) => FilledButton.icon(
                          onPressed: acting.value
                              ? null
                              : (rel?.isFollowing == true ? unfollow : follow),
                          icon: Icon(
                            rel?.isFollowing == true
                                ? Symbols.remove_circle
                                : Icons.person_add_outlined,
                          ),
                          label: Text(
                            rel?.isFollowing == true ? 'unfollow' : 'follow',
                          ).tr(),
                          style: ButtonStyle(
                            visualDensity: VisualDensity(vertical: -2),
                          ),
                        ),
                        error: (_, _) => FilledButton.icon(
                          onPressed: acting.value ? null : follow,
                          icon: const Icon(Icons.person_add_outlined),
                          label: Text('follow').tr(),
                          style: ButtonStyle(
                            visualDensity: VisualDensity(vertical: -2),
                          ),
                        ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (data.summary?.isNotEmpty ?? false) ...[
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
                                  content: data.summary!,
                                  linesMargin: EdgeInsets.zero,
                                )
                              : Text(
                                  data.summary!,
                                  key: const ValueKey('collapsed'),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ).alignment(Alignment.centerLeft),
                      ),
                      InkWell(
                        onTap: () {
                          isBioExpanded.value = !isBioExpanded.value;
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
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
    );
  }
}

class _ActorStatsWidget extends StatelessWidget {
  final SnActivityPubActor data;

  const _ActorStatsWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: 'posts'.tr(),
              value:
                  data.totalPostCount?.toString() ??
                  data.recentPosts?.length.toString() ??
                  '0',
            ),
            _StatItem(
              label: 'followers'.tr(),
              value: data.followersCount?.toString() ?? '0',
            ),
            _StatItem(
              label: 'following'.tr(),
              value: data.followingCount?.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _FediverseHintWidget extends StatelessWidget {
  final SnActivityPubActor data;

  const _FediverseHintWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: data.webUrl != null ? () => launchUrlString(data.webUrl!) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Symbols.hub, size: 20, color: theme.colorScheme.primary),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'fediverseProfileHint'.tr(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (data.webUrl != null) ...[
                      const Gap(4),
                      Text(
                        'viewOnOriginalSite'.tr(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (data.webUrl != null)
                Icon(
                  Symbols.open_in_new,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UncachedPostItem extends StatelessWidget {
  final SnPost post;

  const _UncachedPostItem({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        if (post.fediverseUri != null) {
          launchUrlString(post.fediverseUri!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: post.actor?.avatarUrl != null
                      ? CachedNetworkImageProvider(post.actor!.avatarUrl!)
                      : null,
                  backgroundColor: theme.colorScheme.surfaceContainer,
                  child: post.actor?.avatarUrl == null
                      ? Icon(
                          Symbols.person,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : null,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    post.actor?.displayName ?? post.actor?.username ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Symbols.open_in_new,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            if (post.content != null && post.content!.isNotEmpty) ...[
              const Gap(8),
              Text(
                post.content!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
            const Gap(8),
            Row(
              children: [
                Icon(
                  Symbols.schedule,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const Gap(4),
                Text(
                  post.publishedAt != null
                      ? _formatDate(post.publishedAt!)
                      : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  Symbols.cloud,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const Gap(4),
                Text(
                  'tapToViewOriginal'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 30) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'justNow'.tr();
    }
  }
}

class _ActorPostsWidget extends ConsumerWidget {
  final String actorId;

  const _ActorPostsWidget({required this.actorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actorPosts = ref.watch(fediverseActorPostsProvider(actorId));

    return actorPosts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Symbols.article,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const Gap(8),
                    Text(
                      'noPosts'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Column(
          children: posts.map((post) {
            if (!post.isCached && post.fediverseUri != null) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: _UncachedPostItem(post: post),
              );
            }
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: PostActionableItem(item: post, borderRadius: 8),
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(child: Text(err.toString())),
        ),
      ),
    );
  }
}

@RoutePage()
class FediverseActorProfileScreen extends HookConsumerWidget {
  final String id;
  final String? fullHandle;

  const FediverseActorProfileScreen({
    super.key,
    required this.id,
    this.fullHandle,
  });

  String get requestKey {
    if (id.contains('@')) return id;
    if (fullHandle != null && fullHandle!.contains('@')) return fullHandle!;
    return id;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(fediverseActorProvider(requestKey));

    final acting = useState(false);

    Future<void> follow(SnActivityPubActor actorData) async {
      final apiClient = ref.watch(apiClientProvider);
      acting.value = true;
      try {
        await apiClient.post("/sphere/fediverse/actors/${actorData.id}/follow");
        ref.invalidate(fediverseActorRelationshipProvider(actorData.id));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        acting.value = false;
      }
    }

    Future<void> unfollow(SnActivityPubActor actorData) async {
      final apiClient = ref.watch(apiClientProvider);
      acting.value = true;
      try {
        await apiClient.post(
          "/sphere/fediverse/actors/${actorData.id}/unfollow",
        );
        ref.invalidate(fediverseActorRelationshipProvider(actorData.id));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        acting.value = false;
      }
    }

    return actor.when(
      data: (data) {
        final relationship = ref.watch(
          fediverseActorRelationshipProvider(data.id),
        );

        return AppScaffold(
          isNoBackground: false,
          appBar: AppBar(
            leading: AutoLeadingButton(),
            title: Text(data.displayName ?? data.username),
          ),
          body: isWideScreen(context)
              ? Row(
                  spacing: 12,
                  children: [
                    Flexible(
                      flex: 4,
                      child: CustomScrollView(
                        slivers: [
                          const SliverGap(16),
                          SliverToBoxAdapter(
                            child: _ActorPostsWidget(actorId: data.id),
                          ),
                          SliverGap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            spacing: 12,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _ActorBasisWidget(
                                data: data,
                                relationship: relationship,
                                acting: acting,
                                follow: () => follow(data),
                                unfollow: () => unfollow(data),
                              ),
                              _ActorStatsWidget(data: data),
                              _FediverseHintWidget(data: data),
                              if (data.lastActivityAt != null)
                                Card(
                                  margin: EdgeInsets.zero,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Symbols.schedule,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            'lastActive'.tr(
                                              args: [
                                                _formatDate(
                                                  data.lastActivityAt!,
                                                ),
                                              ],
                                            ),
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).padding(horizontal: 12)
              : CustomScrollView(
                  slivers: [
                    const SliverGap(12),
                    SliverToBoxAdapter(
                      child: data.headerUrl != null
                          ? CachedNetworkImage(
                              imageUrl: data.headerUrl!,
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                height: 180,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                              errorWidget: (_, _, _) => Container(
                                height: 180,
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                    SliverToBoxAdapter(
                      child: _ActorBasisWidget(
                        data: data,
                        relationship: relationship,
                        acting: acting,
                        follow: () => follow(data),
                        unfollow: () => unfollow(data),
                      ),
                    ),
                    const SliverGap(12),
                    SliverToBoxAdapter(child: _ActorStatsWidget(data: data)),
                    const SliverGap(12),
                    SliverToBoxAdapter(child: _FediverseHintWidget(data: data)),
                    const SliverGap(12),
                    SliverToBoxAdapter(
                      child: _ActorPostsWidget(actorId: data.id),
                    ),
                    SliverGap(MediaQuery.of(context).padding.bottom + 16),
                  ],
                ).padding(horizontal: 8),
        );
      },
      error: (error, stackTrace) => AppScaffold(
        isNoBackground: false,
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: Center(child: Text(error.toString())),
      ),
      loading: () => AppScaffold(
        isNoBackground: false,
        appBar: AppBar(leading: const AutoLeadingButton()),
        body: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'justNow'.tr();
    }
  }
}
