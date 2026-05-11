import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html2md/html2md.dart' as html2md;
import 'package:island/accounts/widgets/account/handle_chip.dart';
import 'package:island/core/network.dart';
import 'package:island/accounts/screens/me/account_settings.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_item_skeleton.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/shared/widgets/pagination_list.dart';
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
      final client = ref.watch(solarNetworkClientProvider);
      final isHandle = idOrHandle.contains('@');

      try {
        final resp = await client.dio.get(
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

final fediverseActorRelationshipProvider = FutureProvider.autoDispose
    .family<FediverseActorRelationship?, String>((ref, actorId) async {
      final client = ref.watch(solarNetworkClientProvider);
      try {
        final resp = await client.dio.get(
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

final fediverseActorPostsProvider = AsyncNotifierProvider.autoDispose
    .family<FediverseActorPostsNotifier, PaginationState<SnPost>, String>(
      FediverseActorPostsNotifier.new,
    );

class FediverseActorPostsNotifier extends AsyncNotifier<PaginationState<SnPost>>
    with AsyncPaginationController<SnPost> {
  static const int pageSize = 20;

  final String actorId;

  FediverseActorPostsNotifier(this.actorId);

  @override
  Future<PaginationState<SnPost>> build() async {
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
  Future<List<SnPost>> fetch() async {
    final client = ref.read(solarNetworkClientProvider);

    final response = await client.dio.get(
      "/sphere/fediverse/actors/$actorId/posts",
      queryParameters: {'offset': fetchedCount, 'take': pageSize},
    );

    totalCount = response.data is List ? (response.data as List).length : 0;
    if (response.data is List) {
      return (response.data as List)
          .map((json) => SnPost.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class _ActorBasisWidget extends HookWidget {
  final SnActivityPubActor data;
  final AsyncValue<FediverseActorRelationship?> relationship;
  final ValueNotifier<bool> acting;
  final VoidCallback follow;
  final VoidCallback unfollow;
  final bool hasFediverseIdentity;

  const _ActorBasisWidget({
    required this.data,
    required this.relationship,
    required this.acting,
    required this.follow,
    required this.unfollow,
    required this.hasFediverseIdentity,
  });

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
              // Banner/background image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: data.headerUrl != null
                      ? CachedNetworkImage(
                          imageUrl: data.headerUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                          ),
                        )
                      : Container(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                ),
              ),
              // Profile picture positioned at bottom left
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
                  child: CircleAvatar(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        data.displayName ?? data.username,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
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
                          color: data.isBot
                              ? theme.colorScheme.tertiaryContainer
                              : theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'BOT',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: data.isBot
                                ? theme.colorScheme.onTertiaryContainer
                                : theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    HandleChip(
                      handle: data.username,
                      domain: data.instance.domain,
                      isRemote: true,
                      allowCopy: true,
                      maxLines: 1,
                    ),
                  ],
                ),
                const Gap(12),
                relationship.when(
                  data: (rel) {
                    return FilledButton.icon(
                      onPressed: acting.value
                          ? null
                          : hasFediverseIdentity
                          ? (rel?.isFollowing == true ? unfollow : follow)
                          : () => showFediverseInteractionHint(
                              context,
                              'fediverseFollowHint',
                            ),
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
                    );
                  },
                  error: (_, _) {
                    return FilledButton.icon(
                      onPressed: acting.value
                          ? null
                          : hasFediverseIdentity
                          ? follow
                          : () => showFediverseInteractionHint(
                              context,
                              'fediverseFollowHint',
                            ),
                      icon: const Icon(Icons.person_add_outlined),
                      label: Text('follow').tr(),
                      style: ButtonStyle(
                        visualDensity: VisualDensity(vertical: -2),
                      ),
                    );
                  },
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
                if (data.bio?.isNotEmpty ?? false) ...[
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
                                      content: html2md.convert(data.bio!),
                                      linesMargin: EdgeInsets.zero,
                                    )
                                  : Text(
                                      html2md.convert(data.bio!),
                                      key: const ValueKey('collapsed'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                      textAlign: TextAlign.left,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

class _ActorTagsWidget extends StatelessWidget {
  final SnActivityPubActor data;

  const _ActorTagsWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final metadata = data.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final tagList = metadata['tag'];
    if (tagList is! List || tagList.isEmpty) return const SizedBox.shrink();

    final emojis = <Map<String, dynamic>>[];
    final hashtags = <Map<String, dynamic>>[];
    for (final item in tagList) {
      if (item is! Map<String, dynamic>) continue;
      final type = item['type'] as String?;
      if (type == 'Emoji') {
        emojis.add(item);
      } else if (type == 'Hashtag') {
        hashtags.add(item);
      }
    }

    if (emojis.isEmpty && hashtags.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emojis.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: emojis.map((emoji) {
                  final icon = emoji['icon'] as Map<String, dynamic>?;
                  final url = icon?['url'] as String?;
                  final name = emoji['name'] as String? ?? '';
                  return Tooltip(
                    message: name,
                    child: url != null
                        ? CachedNetworkImage(
                            imageUrl: url,
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Text(
                              name,
                              style: const TextStyle(fontSize: 16),
                            ),
                            errorWidget: (context, url, error) => Text(
                              name,
                              style: const TextStyle(fontSize: 16),
                            ),
                          )
                        : Text(name, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
              ),
            ],
            if (emojis.isNotEmpty && hashtags.isNotEmpty) const Gap(8),
            if (hashtags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: hashtags.map((tag) {
                  final href = tag['href'] as String?;
                  final name = tag['name'] as String? ?? '';
                  return ActionChip(
                    label: Text(
                      name,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    avatar: const Icon(Symbols.tag, size: 14),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onPressed: href != null
                        ? () => launchUrlString(href)
                        : null,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActorAttachmentsWidget extends StatelessWidget {
  final SnActivityPubActor data;

  const _ActorAttachmentsWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final metadata = data.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final attachments = metadata['attachment'];
    if (attachments is! List || attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    final validAttachments = attachments
        .whereType<Map<String, dynamic>>()
        .where((a) => a['type'] == 'PropertyValue')
        .toList();

    if (validAttachments.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('profileFields'.tr(), style: theme.textTheme.titleSmall),
            const Gap(8),
            ...validAttachments.map((attachment) {
              final name = attachment['name'] as String? ?? '';
              final value = attachment['value'] as String? ?? '';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: _PropertyValueRenderer(html: value)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _PropertyValueRenderer extends StatelessWidget {
  final String html;

  const _PropertyValueRenderer({required this.html});

  @override
  Widget build(BuildContext context) {
    final plainText = _stripHtml(html);
    final uri = _extractFirstLink(html);

    final child = Text(
      plainText,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: uri != null ? Theme.of(context).colorScheme.primary : null,
      ),
    );

    if (uri != null) {
      return InkWell(
        onTap: () => launchUrlString(uri),
        borderRadius: BorderRadius.circular(4),
        child: child.padding(horizontal: 2),
      );
    }
    return child;
  }

  String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
  }

  String? _extractFirstLink(String input) {
    final match = RegExp(r'href="([^"]*)"').firstMatch(input);
    return match?.group(1);
  }
}

class _FollowedMessageWidget extends StatelessWidget {
  final SnActivityPubActor data;

  const _FollowedMessageWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final metadata = data.metadata;
    if (metadata == null) return const SizedBox.shrink();

    final message = metadata['_misskey_followedMessage'] as String?;
    if (message == null || message.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.favorite,
              size: 16,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const Gap(8),
            Expanded(
              child: MarkdownTextContent(
                content: message,
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActorPostsWidget extends ConsumerWidget {
  final String actorId;

  const _ActorPostsWidget({required this.actorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = fediverseActorPostsProvider(actorId);

    return PaginationList(
      provider: provider,
      notifier: provider.notifier,
      isRefreshable: false,
      isSliver: true,
      footerSkeletonChild: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: PostItemSkeleton(maxWidth: double.infinity),
      ),
      itemBuilder: (context, index, post) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: PostActionableItem(
            item: post,
            borderRadius: 8,
            onTap: !post.isCached && post.fediverseUri != null
                ? () => launchUrlString(post.fediverseUri!)
                : null,
          ),
        );
      },
    );
  }
}

@RoutePage()
class FediverseActorProfileScreen extends HookConsumerWidget {
  final String id;
  final String? fullHandle;

  const FediverseActorProfileScreen({
    super.key,
    @PathParam("id") required this.id,
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
      final client = ref.watch(solarNetworkClientProvider);
      acting.value = true;
      try {
        await client.dio.post(
          "/sphere/fediverse/actors/${actorData.id}/follow",
        );
        ref.invalidate(fediverseActorRelationshipProvider(actorData.id));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        acting.value = false;
      }
    }

    Future<void> unfollow(SnActivityPubActor actorData) async {
      final client = ref.watch(solarNetworkClientProvider);
      acting.value = true;
      try {
        await client.dio.post(
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
        final hasFediverseIdentity = ref.watch(hasFediverseIdentityProvider);

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
                          const SliverGap(12),
                          _ActorPostsWidget(actorId: data.id),
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
                                hasFediverseIdentity: hasFediverseIdentity,
                              ),
                              if (data.metadata?['_misskey_followedMessage'] !=
                                  null)
                                _FollowedMessageWidget(data: data),
                              _FediverseHintWidget(data: data),
                              _ActorTagsWidget(data: data),
                              _ActorAttachmentsWidget(data: data),
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
                      child: _ActorBasisWidget(
                        data: data,
                        relationship: relationship,
                        acting: acting,
                        follow: () => follow(data),
                        unfollow: () => unfollow(data),
                        hasFediverseIdentity: hasFediverseIdentity,
                      ),
                    ),
                    const SliverGap(12),
                    SliverToBoxAdapter(child: _FediverseHintWidget(data: data)),
                    if (data.metadata?['_misskey_followedMessage'] != null) ...[
                      const SliverGap(12),
                      SliverToBoxAdapter(
                        child: _FollowedMessageWidget(data: data),
                      ),
                    ],
                    const SliverGap(12),
                    SliverToBoxAdapter(child: _ActorTagsWidget(data: data)),
                    const SliverGap(12),
                    SliverToBoxAdapter(
                      child: _ActorAttachmentsWidget(data: data),
                    ),
                    const SliverGap(12),
                    _ActorPostsWidget(actorId: data.id),
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
