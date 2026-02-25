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
import 'package:island/accounts/widgets/account/status.dart';
import 'package:island/livestreams/livestream.dart';
import 'package:island/drive/widgets/cloud_files.dart';
import 'package:island/posts/pods/post_list.dart';
import 'package:island/core/config.dart';
import 'package:island/core/network.dart';
import 'package:island/posts/widgets/compose/filters/post_filter.dart';
import 'package:island/posts/widgets/compose/post_item.dart';
import 'package:island/posts/widgets/compose/post_list.dart';
import 'package:island/core/services/color.dart';
import 'package:island/core/services/responsive.dart';
import 'package:island/route.gr.dart';
import 'package:island/shared/widgets/alert.dart';
import 'package:island/shared/widgets/app_scaffold.dart' hide PageBackButton;
import 'package:island/shared/widgets/content/markdown.dart';
import 'package:island/posts/activity_heatmap.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:island/core/services/color_extraction.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:solar_network_sdk/solar_network_sdk.dart';

part 'publisher_profile.g.dart';

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

        return Card(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Theme(
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
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _PublisherBasisWidget extends StatelessWidget {
  final SnPublisher data;
  final AsyncValue<SnPublisherSubscription?> subStatus;
  final AsyncValue<SnLiveStream?> liveStatus;
  final ValueNotifier<bool> subscribing;
  final VoidCallback subscribe;
  final VoidCallback unsubscribe;

  const _PublisherBasisWidget({
    required this.data,
    required this.subStatus,
    required this.liveStatus,
    required this.subscribing,
    required this.subscribe,
    required this.unsubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Builder(
        builder: (context) {
          final hasBackground = data.background != null;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isWideScreen(context) && hasBackground)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
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
                      child: GestureDetector(
                        child: Badge(
                          isLabelVisible: data.type == 0,
                          padding: EdgeInsets.all(3),
                          label: Icon(
                            Symbols.launch,
                            size: 12,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          offset: Offset(0, 48),
                          child: ProfilePictureWidget(
                            file: data.picture,
                            radius: 32,
                            borderRadius: data.type == 0 ? null : 12,
                          ),
                        ),
                        onTap: () {
                          if (data.account?.name != null) {
                            Navigator.pop(context, true);
                            context.router.push(
                              AccountProfileRoute(name: data.account!.name),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              Builder(
                builder: (context) {
                  final showBackground = isWideScreen(context) && hasBackground;
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: showBackground ? 0 : 20,
                    children: [
                      if (!showBackground)
                        GestureDetector(
                          child: Badge(
                            isLabelVisible: data.type == 0,
                            padding: EdgeInsets.all(4),
                            label: Icon(
                              Symbols.launch,
                              size: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            offset: Offset(0, 48),
                            child: ProfilePictureWidget(
                              file: data.picture,
                              radius: 32,
                              borderRadius: data.type == 0 ? null : 12,
                            ),
                          ),
                          onTap: () {
                            if (data.account?.name != null) {
                              Navigator.pop(context, true);
                              context.router.push(
                                AccountProfileRoute(name: data.account!.name),
                              );
                            }
                          },
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              spacing: 6,
                              children: [
                                if (data.account != null && data.type == 0)
                                  AccountName(
                                    account: data.account!,
                                    textOverride: data.nick,
                                    hideVerificationMark: true,
                                    style: TextStyle(fontSize: 20),
                                  )
                                else
                                  Text(data.nick).fontSize(20),
                                if (data.verification != null)
                                  VerificationMark(mark: data.verification!),
                                liveStatus.when(
                                  data: (stream) => stream == null
                                      ? const SizedBox.shrink()
                                      : InkWell(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          onTap: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    _PublisherLivestreamWatchScreen(
                                                      stream: stream,
                                                    ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.redAccent
                                                  .withOpacity(0.16),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Symbols.circle,
                                                  fill: 1,
                                                  size: 10,
                                                  color: Colors.redAccent,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'LIVE',
                                                  style: TextStyle(
                                                    color: Colors.redAccent,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                                if (isWideScreen(context))
                                  Expanded(
                                    child: Text(
                                      '@${data.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ).fontSize(14).opacity(0.85),
                                  ),
                              ],
                            ),
                            if (!isWideScreen(context))
                              Text(
                                '@${data.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ).fontSize(14).opacity(0.85).padding(bottom: 2.5),
                            if (data.type == 0 && data.account != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 6,
                                children: [
                                  Icon(
                                    data.type == 0
                                        ? Symbols.person
                                        : Symbols.workspaces,
                                    fill: 1,
                                    size: 17,
                                  ),
                                  Text(
                                    'publisherBelongsTo'.tr(
                                      args: ['@${data.account!.name}'],
                                    ),
                                  ).fontSize(14),
                                ],
                              ).opacity(0.85),
                            const Gap(4),
                            if (data.type == 0 && data.account != null)
                              AccountStatusWidget(
                                uname: data.account!.name,
                                padding: EdgeInsets.zero,
                              ),
                            subStatus
                                .when(
                                  data: (status) => FilledButton.icon(
                                    onPressed: subscribing.value
                                        ? null
                                        : (status != null
                                              ? unsubscribe
                                              : subscribe),
                                    icon: Icon(
                                      status != null
                                          ? Symbols.remove_circle
                                          : Symbols.add_circle,
                                    ),
                                    label: Text(
                                      status != null
                                          ? 'unsubscribe'
                                          : 'subscribe',
                                    ).tr(),
                                    style: ButtonStyle(
                                      visualDensity: VisualDensity(
                                        vertical: -2,
                                      ),
                                    ),
                                  ),
                                  error: (_, _) => const SizedBox(),
                                  loading: () => const SizedBox(
                                    height: 36,
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .padding(vertical: 12),
                          ],
                        ),
                      ),
                    ],
                  ).padding(
                    left: 16,
                    right: 16,
                    top: 16 + (showBackground ? 16 : 0),
                  );
                },
              ),
            ],
          );
        },
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
            child: BadgeList(
              badges: badges.value!,
            ).padding(horizontal: 26, vertical: 20),
          ).padding(horizontal: 4)
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
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: VerificationStatusCard(mark: data.verification!),
          )
        : const SizedBox.shrink();
  }
}

class _PublisherBioWidget extends StatelessWidget {
  final SnPublisher data;

  const _PublisherBioWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('bio').tr().bold().fontSize(15).padding(bottom: 8),
          if (data.bio.isEmpty)
            Text('descriptionNone').tr().italic()
          else
            MarkdownTextContent(
              content: data.bio,
              linesMargin: EdgeInsets.zero,
            ),
        ],
      ).padding(horizontal: 20, vertical: 16),
    );
  }
}

class _PublisherLivestreamWatchScreen extends StatelessWidget {
  final SnLiveStream stream;

  const _PublisherLivestreamWatchScreen({required this.stream});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isNoBackground: false,
      appBar: AppBar(title: Text(stream.title ?? 'untitledLivestream'.tr())),
      body: ListView(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: LivestreamEmbedWidget(
              livestreamId: stream.id,
              margin: const EdgeInsets.all(12),
            ),
          ).center(),
        ],
      ),
    );
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
          ? ActivityHeatmapWidget(
              heatmap: data,
              forceDense: forceDense,
            ).padding(horizontal: 8)
          : const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

@riverpod
Future<SnPublisher> publisher(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get("/sphere/publishers/$uname");
  return SnPublisher.fromJson(resp.data);
}

@riverpod
Future<List<SnAccountBadge>> publisherBadges(Ref ref, String pubName) async {
  final pub = await ref.watch(publisherProvider(pubName).future);
  if (pub.type != 0 || pub.account == null) return [];
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get(
    "/pass/accounts/${pub.account!.name}/badges",
  );
  return List<SnAccountBadge>.from(
    resp.data.map((x) => SnAccountBadge.fromJson(x)),
  );
}

@riverpod
Future<SnPublisherSubscription?> publisherSubscriptionStatus(
  Ref ref,
  String pubName,
) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final resp = await apiClient.get(
      "/sphere/publishers/$pubName/subscription",
    );
    return SnPublisherSubscription.fromJson(resp.data);
  } catch (err) {
    if (err is DioException) {
      if (err.response?.statusCode == 404) return null;
      rethrow;
    }
  }
  return null;
}

@riverpod
Future<Color?> publisherAppbarForcegroundColor(Ref ref, String pubName) async {
  try {
    final publisher = await ref.watch(publisherProvider(pubName).future);
    if (publisher.background == null) return null;
    final colors = await ColorExtractionService.getColorsFromImage(
      CloudImageWidget.provider(
        file: publisher.background!,
        serverUrl: ref.watch(serverUrlProvider),
      ),
    );
    if (colors.isEmpty) return null;
    final dominantColor = colors.first;
    return dominantColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  } catch (_) {
    return null;
  }
}

@riverpod
Future<SnHeatmap?> publisherHeatmap(Ref ref, String uname) async {
  final apiClient = ref.watch(apiClientProvider);
  final resp = await apiClient.get('/sphere/publishers/$uname/heatmap');
  return SnHeatmap.fromJson(resp.data);
}

final publisherActiveLivestreamProvider = FutureProvider.family
    .autoDispose<SnLiveStream?, String>((ref, publisherId) async {
      final apiClient = ref.watch(apiClientProvider);
      final resp = await apiClient.get(
        '/sphere/livestreams/publisher/$publisherId',
        queryParameters: {'limit': 50, 'offset': 0},
      );
      final data = resp.data;
      final list = switch (data) {
        List value => value,
        Map value when value['items'] is List => value['items'] as List,
        _ => const <dynamic>[],
      };
      for (final item in list.whereType<Map>()) {
        final stream = SnLiveStream.fromJson(Map<String, dynamic>.from(item));
        if (stream.status == SnLiveStreamStatus.active) {
          return stream;
        }
      }
      return null;
    });

@RoutePage()
class PublisherProfileScreen extends HookConsumerWidget {
  final String name;
  const PublisherProfileScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publisher = ref.watch(publisherProvider(name));
    final badges = ref.watch(publisherBadgesProvider(name));
    final subStatus = ref.watch(publisherSubscriptionStatusProvider(name));
    final heatmap = ref.watch(publisherHeatmapProvider(name));
    final appbarColor = ref.watch(
      publisherAppbarForcegroundColorProvider(name),
    );

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
      final apiClient = ref.watch(apiClientProvider);
      subscribing.value = true;
      try {
        await apiClient.post(
          "/sphere/publishers/$name/subscribe",
          data: {'tier': 0},
        );
        ref.invalidate(publisherSubscriptionStatusProvider(name));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    Future<void> unsubscribe() async {
      final apiClient = ref.watch(apiClientProvider);
      subscribing.value = true;
      try {
        await apiClient.post("/sphere/publishers/$name/unsubscribe");
        ref.invalidate(publisherSubscriptionStatusProvider(name));
        HapticFeedback.heavyImpact();
      } catch (err) {
        showErrorAlert(err);
      } finally {
        subscribing.value = false;
      }
    }

    final appbarShadow = Shadow(
      color: appbarColor.value?.invert ?? Colors.transparent,
      blurRadius: 5.0,
      offset: Offset(1.0, 1.0),
    );

    return publisher.when(
      data: (data) {
        final liveStatus = ref.watch(
          publisherActiveLivestreamProvider(data.id),
        );
        return AppScaffold(
          isNoBackground: false,
          appBar: isWideScreen(context)
              ? AppBar(
                  foregroundColor: appbarColor.value,
                  leading: AutoLeadingButton(),
                  title: Text(
                    data.nick,
                    style: TextStyle(
                      color:
                          appbarColor.value ??
                          Theme.of(context).appBarTheme.foregroundColor,
                      shadows: [appbarShadow],
                    ),
                  ),
                )
              : null,
          body: isWideScreen(context)
              ? Row(
                  children: [
                    Flexible(
                      flex: 4,
                      child: CustomScrollView(
                        slivers: [
                          SliverGap(16),
                          SliverToBoxAdapter(
                            child: _PinnedPostsPageView(pubName: name),
                          ),
                          SliverToBoxAdapter(
                            child: PostFilterWidget(
                              categoryTabController: categoryTabController,
                              initialQuery: queryState.value,
                              onQueryChanged: (newQuery) =>
                                  queryState.value = newQuery,
                            ),
                          ),
                          SliverPostList(
                            query: queryState.value,
                            queryKey: 'publisher-$name',
                          ),
                          SliverGap(MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ).padding(left: 8),
                    ),
                    Flexible(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PublisherBasisWidget(
                                data: data,
                                subStatus: subStatus,
                                liveStatus: liveStatus,
                                subscribing: subscribing,
                                subscribe: subscribe,
                                unsubscribe: unsubscribe,
                              ).padding(horizontal: 4, top: 20),
                              _PublisherBadgesWidget(
                                data: data,
                                badges: badges,
                              ),
                              _PublisherVerificationWidget(data: data),
                              _PublisherBioWidget(data: data),
                              _PublisherHeatmapWidget(
                                heatmap: heatmap,
                                forceDense: true,
                              ).padding(vertical: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      foregroundColor: appbarColor.value,
                      expandedHeight: 180,
                      pinned: true,
                      leading: AutoLeadingButton(),
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: data.background != null
                                ? CloudImageWidget(file: data.background)
                                : Container(
                                    color: Theme.of(
                                      context,
                                    ).appBarTheme.backgroundColor,
                                  ),
                          ),
                          FlexibleSpaceBar(
                            title: Text(
                              data.nick,
                              style: TextStyle(
                                color:
                                    appbarColor.value ??
                                    Theme.of(
                                      context,
                                    ).appBarTheme.foregroundColor,
                                shadows: [appbarShadow],
                              ),
                            ),
                            background:
                                Container(), // Empty container since background is handled by Stack
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: _PublisherBasisWidget(
                        data: data,
                        subStatus: subStatus,
                        liveStatus: liveStatus,
                        subscribing: subscribing,
                        subscribe: subscribe,
                        unsubscribe: unsubscribe,
                      ).padding(horizontal: 4, top: 8),
                    ),
                    SliverToBoxAdapter(
                      child: _PublisherBadgesWidget(data: data, badges: badges),
                    ),
                    SliverToBoxAdapter(
                      child: _PublisherVerificationWidget(data: data),
                    ),
                    SliverToBoxAdapter(child: _PublisherBioWidget(data: data)),
                    SliverToBoxAdapter(
                      child: _PublisherHeatmapWidget(
                        heatmap: heatmap,
                      ).padding(vertical: 4),
                    ),
                    SliverToBoxAdapter(
                      child: _PinnedPostsPageView(pubName: name),
                    ),
                    SliverToBoxAdapter(
                      child: PostFilterWidget(
                        categoryTabController: categoryTabController,
                        initialQuery: queryState.value,
                        onQueryChanged: (newQuery) =>
                            queryState.value = newQuery,
                      ),
                    ),
                    SliverPostList(
                      key: ValueKey(queryState.value),
                      query: queryState.value,
                      queryKey: 'publisher-$name',
                    ),
                    SliverGap(MediaQuery.of(context).padding.bottom + 16),
                  ],
                ),
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
        body: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
